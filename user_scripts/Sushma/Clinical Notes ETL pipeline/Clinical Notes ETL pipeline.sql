/* Clinical Notes is exported to table i2b2demodata.Export_465_Clinical_Notes  through sqlldr*/
delete from i2b2demodata.Observation_fact_465_Notes;

insert/*+ APPEND NOLOGGING */ into i2b2demodata.Observation_fact_465_Notes
select distinct a.code as CONCEPT_CODE, b.* 
from 
i2b2demodata.Export_465_Clinical_Notes b, UMLS_TOP5.MRCONSO a 
where 
a.CUI=b.concept_cd and 
a.ispref='Y' and a.stt='PF' and a.ts='P' and
a.sab='SNOMEDCT_US' and 
a.lat='ENG';

ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT 
SPLIT PARTITION PUBLIC_STUDIES VALUES ('SNOMEDCT') 
INTO 
    ( PARTITION SNOMEDCT,
      PARTITION PUBLIC_STUDIES);

delete from i2b2demodata.observation_fact_temp;

insert /*APPEND NOLOGGING */ into i2b2demodata.observation_fact_temp
select  encounter_num,patient_num,concept_code,provider_id,NULL,modifier_cd,valtype_cd,tval_char,NULL,valueflag_cd,NULL,units_cd,NULL,location_cd,NULL,sysdate,sysdate,sysdate,'SNOMEDCT',NULL,observation_blob,instance_num,'SNOMEDCT' from i2b2demodata.Observation_fact_465_Notes;

/* Insert into observation_fact  */
ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT
EXCHANGE PARTITION SNOMEDCT WITH TABLE i2b2demodata.observation_fact_temp
WITHOUT VALIDATION; 

/* Insert into table patient_dimension */
insert /*+ APPEND NOLOGGING */ into patient_dimension
select distinct patient_num,null,null,null,'Unknown',null,null,'Unknown',null,null,null,null,sysdate,sysdate,sysdate,'SNOMEDCT:'||patient_num,null,null,null from i2b2demodata.Observation_fact_465_Notes;

delete from i2b2metadata.i2b2_leaves;

insert into i2b2metadata.i2b2_leaves
SELECT * FROM I2B2METADATA.I2B2_SNOMED_FULL  WHERE C_BASECODE IN (SELECT DISTINCT CONCEPT_CODE FROM i2b2demodata.Observation_fact_465_Notes);

CREATE INDEX "I2B2METADATA"."I2B2_LEAVES_CFULLNAME" ON i2b2metadata.i2b2_leaves("C_FULLNAME");

delete from i2b2metadata.i2b2_folders;
delete from I2B2METADATA.I2B2_TEMP;

exec PRUNE_I2B2();

insert /*+ APPEND NOLOGGING */ INTO I2B2METADATA.I2B2_TEMP
select  c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,c_basecode,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_dimcode,c_tooltip,sysdate,sysdate,sysdate,'SNOMED',null,0,null,null,null,null from i2b2metadata.i2b2_leaves;

insert /*+ APPEND NOLOGGING */ INTO I2B2METADATA.I2B2_TEMP
SELECT c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,c_basecode,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_dimcode,c_tooltip,sysdate,sysdate,sysdate,'SNOMED',null,0,null,null,null,null FROM I2B2METADATA.I2B2_SNOMED_FULL  where c_fullname in (select distinct c_fullname from  i2b2metadata.i2b2_folders where c_fullname not in (select c_fullname from i2b2metadata.i2b2_leaves));

update I2B2METADATA.I2B2_TEMP
set c_hlevel=c_hlevel+2;

update I2B2METADATA.I2B2_TEMP
set c_fullname='\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED'||c_fullname;

update i2b2metadata.i2b2_leaves
set c_fullname='\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED'||c_fullname;

update I2B2METADATA.I2B2_TEMP
set c_dimcode=c_fullname;

insert into I2B2METADATA.I2B2_TEMP values(2,'\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\','01 SNOMED','N','FA',null,'SNO:001',null,'concept_cd','concept_dimension','concept_path','T','LIKE','\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\',null,'\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\',sysdate,sysdate,sysdate,'SNOMED',NULL,0,NULL,NULL,NULL,NULL);

/* Insert into i2b2 table */
insert /*+ APPEND NOLOGGING */ INTO i2b2metadata.i2b2
select c_hlevel,c_fullname,c_name,c_synonym_cd,c_visualattributes,null,c_basecode,null,c_facttablecolumn,c_tablename,c_columnname,c_columndatatype,c_operator,c_dimcode,null,c_tooltip,sysdate,sysdate,sysdate,'SNOMED',null,0,null,null,null,null from I2B2METADATA.I2B2_TEMP;

/* Convert leaf to folder nodes */

update i2b2
set c_visualattributes='FA'
where c_fullname like '\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%' and c_visualattributes='LA' and c_synonym_cd='N';

exec GENERATE_MODIFIERS_I2B2();

/* insert into table concept_dimension */

insert /*+ APPEND NOLOGGING */ into i2b2demodata.concept_dimension
select c_basecode,c_fullname,c_name,null,sysdate,sysdate,sysdate,'SNOMED',null,'CONCEPT_DIMENSION' from I2B2METADATA.I2B2_TEMP;

 
INSERT INTO I2B2DEMODATA.OBSERVATION_FACT_COUNTS 
select distinct encounter_num,patient_num,concept_cd from observation_fact where sourcesystem_cd='SNOMED' and modifier_cd='CUSTOM:POLARITY:' and tval_char='1';
 
delete from i2b2demodata.concept_counts_temp;

delete from i2b2demodata.concept_counts_temp2;

insert into i2b2demodata.concept_counts_temp
select a.c_fullname,b.patient_num,b.encounter_num,a.c_name from I2B2METADATA.I2B2_TEMP a, I2B2DEMODATA.OBSERVATION_FACT_COUNTS b where a.c_basecode=b.concept_cd;

exec I2B2_CREATE_CONCEPT_COUNTS();

/* Finished */

 
