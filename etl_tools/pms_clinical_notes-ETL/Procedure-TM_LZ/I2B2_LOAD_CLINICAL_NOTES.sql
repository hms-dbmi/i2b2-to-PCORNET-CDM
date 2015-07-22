create or replace PROCEDURE                                                                                        I2B2_LOAD_CLINICAL_NOTES 
(
sab in varchar2,
top_node in varchar2,
study_id in varchar2,
FactSet in varchar2,
umls_table varchar2,
i2b2_full_table varchar2
)

AS 
  databaseName VARCHAR(100);
  procedureName VARCHAR(100);
  stepCt number(18,0) := 0; /* Calculates step count */
  hlevel number(18,0);
 
  
 sab_val varchar(20);
 name_char varchar(20);
 top_node_var varchar(100);
BEGIN

 --SET Database name.
	SELECT sys_context('USERENV', 'CURRENT_SCHEMA') INTO databaseName FROM dual;
	procedureName := $$PLSQL_UNIT;
  
sab_val := upper(sab);


select length(top_node) - length(replace(top_node,'\','')) -1 into hlevel from dual;

execute immediate 'truncate table Observation_fact_PMS_Notes';
commit;




IF FactSet = 'HMS_PMS_NLP_SNO' then
execute immediate 'INSERT /*+ APPEND NOLOGGING */ INTO  Observation_fact_PMS_Notes
select distinct a.code as CONCEPT_CODE, to_number(b.encounter_num), to_number(b.patient_num),b.concept_cd,b.provider_id,b.start_date,b.modifier_cd,to_number(b.instance_num),b.valtype_cd,dbms_lob.substr( b.tval_char, 4000, 1 ),b.nval_num,b.VALUEFLAG_CD,b.CONCEPT_CD,b.units_cd,b.end_date,b.location_cd,b.instance_num,null,b.OBSERVATION_BLOB
from
"Export_PMS_Clinical_Notes" b, ' || umls_table || '  a
where
a.CUI=b.concept_cd and  
a.sab= :sab_val and a.stt=''PF'' and
a.lat=''ENG'' and a.ts=''P'' and ispref=''Y''' 
USING sab_val;

elsif FactSet = 'HMS_PMS_NLP_HPO' then

INSERT /*+ APPEND NOLOGGING */ INTO Observation_fact_PMS_Notes
select distinct concept_cd,to_number(encounter_num),to_number(patient_num),concept_cd,provider_id,start_date,modifier_cd,instance_num,valtype_cd,dbms_lob.substr( tval_char, 4000, 1 ),nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,sourcesystem_cd,observation_blob from "Export_PMS_Clinical_Notes"  where concept_cd like 'HP%' ;

ELSE

/* Join tables umls.mrconso and staging table on concept_cd */
execute immediate 'INSERT /*+ APPEND NOLOGGING */ INTO  Observation_fact_PMS_Notes
select distinct a.code as CONCEPT_CODE, to_number(b.encounter_num), to_number(b.patient_num),b.concept_cd,b.provider_id,b.start_date,b.modifier_cd,to_number(b.instance_num),b.valtype_cd,dbms_lob.substr( b.tval_char, 4000, 1 ),b.nval_num,b.VALUEFLAG_CD,b.CONCEPT_CD,b.units_cd,b.end_date,b.location_cd,b.instance_num,null,b.OBSERVATION_BLOB
from
"Export_PMS_Clinical_Notes" b,' || umls_table || '  a
where
a.CUI=b.concept_cd and 
a.sab=:sab_val and a.stt=''PF'' and
a.lat=''ENG'' and a.ts=''P'''
USING sab_val;

end if;

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'tables umls.mrconco and pms_clinical_notes joined','Done');

commit;

execute immediate 'truncate table "OBSERVATION_FACT_TEMP"';
commit;

execute immediate  'alter index tm_lz.conceptcd_obpms rebuild';

commit;



insert /*APPEND NOLOGGING */ into observation_fact_temp(encounter_num,patient_num,concept_cd,provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,sourcesystem_cd,upload_id,observation_blob,instance_num)
select distinct to_number(encounter_num),patient_num,concept_code,provider_id,null,modifier_cd,valtype_cd,tval_char,NULL,valueflag_cd,null,quantity_num,null,location_cd,confidence_num,null,null,null,FactSet,null,observation_blob,instance_num from Observation_fact_PMS_Notes;



stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Insert records into observation_fact_temp','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

INSERT /*+ APPEND NOLOGGING */ INTO "OBSERVATION_FACT_TEMP" 
SELECT ENCOUNTER_NUM,PATIENT_NUM,CONCEPT_CD,PROVIDER_ID,START_DATE,'CUSTOM:OBSERVATION_VALID:','T','1',NULL,NULL,NULL,NULL,NULL,NULL,instance_num,SYSDATE,SYSDATE,SYSDATE,FactSet,NULL,OBSERVATION_BLOB,INSTANCE_NUM FROM "OBSERVATION_FACT_TEMP"  WHERE MODIFIER_CD='CUSTOM:POLARITY:' and tval_char='1';
stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Added modifier observation_valid with value 1','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

INSERT /*+ APPEND NOLOGGING */  INTO "OBSERVATION_FACT_TEMP" 
SELECT ENCOUNTER_NUM,PATIENT_NUM,CONCEPT_CD,PROVIDER_ID,START_DATE,'CUSTOM:OBSERVATION_VALID:','T','-1',NULL,NULL,NULL,NULL,NULL,NULL,instance_num,SYSDATE,SYSDATE,SYSDATE,FactSet,NULL,OBSERVATION_BLOB,INSTANCE_NUM FROM "OBSERVATION_FACT_TEMP"  WHERE MODIFIER_CD='CUSTOM:POLARITY:' and tval_char='-1';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Added modifier observation_valid with value -1','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

INSERT /*+ APPEND NOLOGGING */ INTO "OBSERVATION_FACT_TEMP" 
SELECT ENCOUNTER_NUM,PATIENT_NUM,CONCEPT_CD,PROVIDER_ID,START_DATE,'CUSTOM:OBSERVATION_INVALID_REASON:','T','Negative Polarity',NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,SYSDATE,SYSDATE,FactSet,NULL,OBSERVATION_BLOB,INSTANCE_NUM FROM "OBSERVATION_FACT_TEMP" WHERE MODIFIER_CD='CUSTOM:OBSERVATION_VALID:' and tval_char='-1';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Added modifier observation_invalid_reason with the reason','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

insert /*+ APPEND NOLOGGING */ into "OBSERVATION_FACT_TEMP"
(MODIFIER_CD,VALTYPE_CD, TVAL_CHAR,CONCEPT_CD,PATIENT_NUM,ENCOUNTER_NUM,INSTANCE_NUM,SOURCESYSTEM_CD,PROVIDER_ID)
select 'CUSTOM:HIGHLIGHT:', 'T', OBSERVATION_BLOB,CONCEPT_CD,PATIENT_NUM,ENCOUNTER_NUM,INSTANCE_NUM,FactSet,PROVIDER_ID from "OBSERVATION_FACT_TEMP" O1 where OBSERVATION_BLOB is not null and modifier_cd='CUSTOM:SENT:'
and NOT EXISTS (SELECT * FROM "OBSERVATION_FACT_TEMP" O2 where O1.ENCOUNTER_NUM=O2.ENCOUNTER_NUM AND O1.PATIENT_NUM=O2.PATIENT_NUM AND O1.CONCEPT_CD=O2.CONCEPT_CD AND O1.PROVIDER_ID=O2.PROVIDER_ID AND O2.MODIFIER_CD='CUSTOM:HIGHLIGHT:' AND O2.VALTYPE_CD='T' AND O1.INSTANCE_NUM=O2.INSTANCE_NUM);


stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Added modifier highlight','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

INSERT /*+ APPEND NOLOGGING */ INTO "OBSERVATION_FACT_TEMP"
(MODIFIER_CD,VALTYPE_CD, TVAL_CHAR,CONCEPT_CD,PATIENT_NUM,ENCOUNTER_NUM,INSTANCE_NUM,SOURCESYSTEM_CD,PROVIDER_ID)
select distinct 'CUSTOM:PATIENT_VALID:','T','1',CONCEPT_CD,PATIENT_NUM,null,1,FactSet,PROVIDER_ID from "OBSERVATION_FACT_TEMP" WHERE MODIFIER_CD='CUSTOM:OBSERVATION_VALID:';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Added modifier patient_valid with value 1','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

execute immediate 'UPDATE OBSERVATION_FACT_TEMP O1 SET TVAL_CHAR=''-1'' WHERE MODIFIER_CD=''CUSTOM:PATIENT_VALID:'' 
AND NOT EXISTS (select * FROM OBSERVATION_FACT_TEMP O2 where O1.CONCEPT_CD=O2.CONCEPT_CD AND O1.PATIENT_NUM=O2.PATIENT_NUM AND O2.MODIFIER_CD=''CUSTOM:OBSERVATION_VALID:'' AND O2.TVAL_CHAR=''1'')';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Added modifier patient_valid with value -1','Done');

commit;

execute immediate  'alter index tm_lz.conceptcd_obfact rebuild';

commit;

execute immediate 'truncate table "I2B2_LEAVES"';
commit;

execute immediate 'INSERT /*+ APPEND NOLOGGING */ INTO   "I2B2_LEAVES"
SELECT c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,null,c_basecode,null,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_dimcode,null,c_tooltip,sysdate,sysdate,sysdate,null,null,1,m_applied_path,null,c_path,c_symbol  FROM ' || i2b2_full_table || '  WHERE C_BASECODE IN (SELECT DISTINCT CONCEPT_CD FROM Observation_fact_temp)';



commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into i2b2_leaves','Done');

execute immediate 'truncate table i2b2_folders_fullname';
commit;

PRUNE_I2B2();

commit;

execute immediate 'truncate table i2b2_folders';
commit;


execute immediate 'insert /*+ APPEND NOLOGGING */ INTO i2b2_folders
SELECT distinct a.c_hlevel,a.c_fullname,a.c_name,a.c_synonym_cd,a.c_visualattributes,null,a.c_basecode,null,a.c_facttablecolumn,a.c_tablename,a.c_columnname,a.c_columndatatype,a.c_operator,a.c_dimcode,null,a.c_tooltip,sysdate,sysdate,sysdate,null,null,1,a.m_applied_path,null,a.c_path,a.c_symbol FROM ' || i2b2_full_table || ' a,  I2B2_FOLDERS_FULLNAME  b WHERE a.C_FULLNAME = b.C_FULLNAME';



commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into i2b2_folders','Done');

execute immediate 'truncate table I2B2_TEMP';
commit;

insert /*+ APPEND NOLOGGING */ INTO I2B2_TEMP
select   c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,c_totalnum,c_basecode,c_metadataxml,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator, c_dimcode,c_comment,c_tooltip,sysdate,sysdate,sysdate,null,null,0,null,null,null,null from i2b2_leaves;

commit;

select substr(top_node,instr(top_node,'\',-2,1)+1,length(top_node)+1-(instr(top_node,'\',-2,1)+1)) into name_char from dual;


execute immediate 'insert /*+ APPEND NOLOGGING */ INTO I2B2_TEMP
SELECT c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,null,c_basecode,null,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_dimcode,null,c_tooltip,sysdate,sysdate,sysdate,null,null,0,null,null,null,null FROM ' || i2b2_full_table || ' where c_fullname in (select distinct c_fullname from i2b2_folders where c_fullname not in (select c_fullname from i2b2_leaves))';

commit;

execute immediate 'update I2B2_TEMP set c_hlevel=c_hlevel + :hlevel'
USING hlevel;

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Updated c_hlevel in i2b2_temp table','Done');

execute immediate 'update I2B2_TEMP set c_fullname = :top_node||c_fullname'
USING top_node;

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Updated c_fullname in i2b2_temp table','Done');

execute immediate 'update I2B2_TEMP set c_dimcode = c_fullname';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Updated c_dimcode in i2b2_temp table','Done');

execute immediate 'update I2B2_TEMP set c_tooltip = c_fullname';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Updated c_tooltip in i2b2_temp table','Done');

select top_node||'\' into top_node_var from dual;

insert into I2B2_TEMP values(hlevel,top_node_var,name_char,'N','FA',null,sab_val||':001',null,'concept_cd','concept_dimension','concept_path','T','LIKE',top_node,null,top_node,sysdate,sysdate,sysdate,FactSet,NULL,0,NULL,NULL,NULL,NULL);

commit;


stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into i2b2_temp','Done');



execute immediate 
'update I2B2_TEMP
set C_VISUALATTRIBUTES=''FA''
where C_VISUALATTRIBUTES=''LA'' and c_synonym_cd=''N''';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Update c_visualattrinutes LA to FA','Done');

GENERATE_MODIFIERS_I2B2(top_node_var);

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Generated Modifiers','Done');

commit;

insert /*+ APPEND NOLOGGING */ INTO i2b2metadata.i2b2
select c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,null,c_basecode,null,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_fullname,null,c_tooltip,sysdate,sysdate,sysdate,FactSet,null,0,null,null,null,null from I2B2_TEMP;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into i2b2 table','Done');

commit;

/* LATER insert into table concept_dimension */
insert /*+ APPEND NOLOGGING */ into I2B2DEMODATA.concept_dimension
select c_basecode,c_fullname,c_name,null,sysdate,sysdate,sysdate,FactSet,null,'CONCEPT_DIMENSION' from I2B2_TEMP;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into concept_dimension table','Done');
commit;


execute immediate 'truncate table  concept_counts_temp';

execute immediate 'truncate table  concept_counts_temp2';

execute immediate 'truncate table polarity_positive';

commit;

insert /*+ APPEND NOLOGGING */ into polarity_positive
select  * from observation_fact_temp where modifier_cd='CUSTOM:POLARITY:' and tval_char='1';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into polarity_positive table','Done');

execute immediate 'alter index tm_lz.concept_cd_polarity rebuild';

commit;

execute immediate 'insert /*+APPEND NOLOGGING */ into concept_counts_temp
select b.encounter_num,b.patient_num,a.c_fullname from I2B2_TEMP a, polarity_positive b where a.c_basecode=b.concept_cd';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into concept_counts_temp table','Done');

commit;



I2B2_CREATE_CONCEPT_COUNTS();


stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Call procedure concept counts and Inserted data into concept_counts_temp2 table','Done');

commit;

execute immediate 'insert /*+ APPEND NOLOGGING */ INTO "NODE_METADATA_TEMP"
select b.c_fullname AS concept_path,SUBSTR(b.c_fullname,1,INSTR(b.c_fullname,''\'',-2,1)) as parent_concept_path,count(distinct a.patient_num) as value,''PATIENT_COUNT'' as type,6 as node_metadata_id from concept_counts_temp2 a, i2b2_temp b where b.c_fullname=a.c_fullname group by b.c_fullname, SUBSTR(b.c_fullname,1,INSTR(b.c_fullname,''\'',-2,1))';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into node_metadata_temp table - PATIENT_COUNT','Done');

commit;

execute immediate 'truncate table  concept_counts_temp';

execute immediate 'truncate table concept_counts_temp2';

commit;

execute immediate 'insert /*+APPEND NOLOGGING */ into concept_counts_temp
select distinct b.encounter_num,b.patient_num,a.c_fullname from I2B2_TEMP a, observation_fact_temp b where a.c_basecode=b.concept_cd';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into concept_counts_temp table','Done');

I2B2_CREATE_CONCEPT_COUNTS();

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Call procedure concept counts and Inserted data into concept_counts_temp2 table','Done');

commit;

execute immediate 'insert /*+ APPEND NOLOGGING */ INTO "NODE_METADATA_TEMP"
select b.c_fullname AS concept_path,SUBSTR(b.c_fullname,1,INSTR(b.c_fullname,''\'',-2,1)) as parent_concept_path,count(distinct a.encounter_num) as value,''DOCUMENT_COUNT'' as type,6 as node_metadata_id from concept_counts_temp2 a, i2b2_temp b where b.c_fullname=a.c_fullname group by b.c_fullname, SUBSTR(b.c_fullname,1,INSTR(b.c_fullname,''\'',-2,1))';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into node_metadata_temp table - DOCUMENT_COUNT','Done');

execute immediate 'update i2b2_leaves set c_fullname = :top_node||c_fullname'
USING top_node;

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'update c_fullname in i2b2metadata.i2b2_leaves','Done');

commit;

execute immediate 'insert /*+APPEND NOLOGGING */ into "NODE_METADATA_TEMP"
select a.c_fullname as concept_path,SUBSTR(a.c_fullname,1,INSTR(a.c_fullname,''\'',-2,1)) as parent_concept_path,count(distinct b.patient_num) as value,''Concept_Count'' as type,13 as node_metadata_id from i2b2_leaves a,polarity_positive b where b.concept_cd=a.c_basecode
group by a.c_fullname,SUBSTR(a.c_fullname,1,INSTR(a.c_fullname,''\'',-2,1))';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into node_metadata_temp table - CONCEPT_COUNT','Done');

commit;

execute immediate 'update "NODE_METADATA_TEMP"
set NODE_METADATA_ID=I2B2DEMODATA.node_metadata_id.NEXTVAL';

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into node_metadata_temp table with nodemetadata id','Done');

commit;

insert /*+ APPEND NOLOGGING */ INTO "I2B2DEMODATA"."NODE_METADATA"
select * from "NODE_METADATA_TEMP" ;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Inserted data into node_metadata table','Done');

commit;

execute immediate 'update OBSERVATION_FACT_TEMP
  set provider_id = I2B2DEMODATA.provider_id_seq.NEXTVAL
  where SOURCESYSTEM_CD= :FactSet'
  USING FactSet;
  
  commit;
    
  stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'updated provider_id ','Done');

commit;

PATID_MAP_REGISTRY_TO_CLINOTES(FactSet,study_id);

  commit;
    
  stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'mapped patient_num to Registry ','Done');

commit;

execute immediate 'ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT
SPLIT PARTITION PUBLIC_STUDIES VALUES (''' || FactSet || ''')
INTO
( PARTITION ' || FactSet ||',
PARTITION PUBLIC_STUDIES)';

commit;

execute immediate 
'ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT
EXCHANGE PARTITION ' || FactSet || ' WITH TABLE observation_fact_temp
WITHOUT VALIDATION';

commit;

stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'exchange partition','Done');


commit;



  stepCt := stepCt +1;
clinical_notes_write_audit(stepCt,databaseName,procedureName,'Load finished, rebuild index ','Done');



commit;
  
  NULL;
END I2B2_LOAD_CLINICAL_NOTES;