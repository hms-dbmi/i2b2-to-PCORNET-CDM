create or replace PROCEDURE              SCILHS_MAPPING AS 
path1 varchar2(1000);
pat_num number;
i number;
y number;
BEGIN

insert into i2b2demodata.concept_dimension
select c_basecode,c_fullname,c_name,null,sysdate,sysdate,sysdate,'HMS_PMS_SCH_CDM',null,'CONCEPT_DIMENSION' from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\SEX\%';
commit;

insert  into i2b2demodata.concept_dimension
select c_basecode,c_fullname,c_name,null,sysdate,sysdate,sysdate,'HMS_PMS_SCH_CDM',null,'CONCEPT_DIMENSION' from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\RACE\%';
commit;

insert  into i2b2demodata.concept_dimension
select c_basecode,c_fullname,c_name,null,sysdate,sysdate,sysdate,'HMS_PMS_SCH_CDM',null,'CONCEPT_DIMENSION' from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\HISPANIC\%';
commit;

/* Sex -Male */

insert  into i2b2demodata.observation_fact
select encounter_num,patient_num,'SEX:M',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\SEX\Male\');
commit;

/* Sex -Female */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'SEX:F',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\SEX\Female\');
commit;

/* Race - Asian */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:02',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Asian\');
commit;

/* Race - Black or African American */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:03',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Black (African American)\');
commit;

/* Race - Black or Not African American */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:03',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Black (Not African American)\');
commit;


/* Race - Latino/Hispanic */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:01',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Caucasian (Latino/Hispanic)\');
commit;

/* Race - Not Latino/Hispanic */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:05',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Caucasian (Not Latino/Hispanic)\');
commit;

/* Race - Native American */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:01',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Native American\');
commit;

/* Race - Other */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'RACE:OT',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Other\');
commit;

/* Ethnicity - Other  */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:OT',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Other\');
commit;

/* Ethnicity - Asian  */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:NOTHISPANIC',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Asian\');
commit;

/* Ethnicity - Black  */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:NOTHISPANIC',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Black (African American)\');
commit;

/* Ethnicity - Black  */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:NOTHISPANIC',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Black (Not African American)\');
commit;

/* Ethnicity - White  */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:NOTHISPANIC',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Caucasian (Not Latino/Hispanic)\');
commit;

/* Ethnicity - Latino/Hispanic  */
insert /*+ APPEND NOLOGGING */ into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:HISPANIC',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Caucasian (Latino/Hispanic)\');
commit;

/* Ethnicity - Native American */
insert  into i2b2demodata.observation_fact
select encounter_num,patient_num,'ETHNICITY:HISPANIC',provider_id,start_date,modifier_cd,valtype_cd,tval_char,nval_num,valueflag_cd,quantity_num,units_cd,end_date,location_cd,confidence_num,update_date,download_date,import_date,'HMS_PMS_SCH_CDM',upload_id,observation_blob,instance_num
from i2b2demodata.observation_fact 
where concept_cd in 
(select c_basecode from i2b2metadata.i2b2 where c_fullname like '\DBMI\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Patient Reported Outcomes\Demographics\RACE\Native American\');
commit;

INSERT  INTO i2b2demodata.concept_counts_temp 
select a.c_fullname as path, b.patient_num as pat_num from i2b2metadata.i2b2 a, observation_fact b where a.c_fullname like '\DBMI\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\%' and a.c_basecode=b.concept_cd ;
commit;

execute immediate('CREATE INDEX i2b2demodata.LEAF_NODE_IDX1 ON i2b2demodata.concept_counts_temp (path)');
execute immediate('CREATE INDEX i2b2demodata.PATIENTNUM_IDX1 ON i2b2demodata.concept_counts_temp (pat_num)');

FOR rec IN (SELECT distinct path,pat_num FROM i2b2demodata.concept_counts_temp)
LOOP
i:=i+1;
DBMS_OUTPUT.ENABLE(1000000);
path1 := rec.path;
pat_num := rec.pat_num;

INSERT  INTO i2b2demodata.concept_counts_temp2 values(path,pat_num);

WHILE path1 != '\'
LOOP
y:=y+1;
path1 := SUBSTR(path1,1,INSTR(path1,'\',-2,1));
INSERT  INTO i2b2demodata.concept_counts_temp2 values(path1,pat_num);

END LOOP;
END LOOP;
commit;
/* Create indexes  */
execute immediate('CREATE INDEX i2b2demodata.LEAF_NODE_IDX ON i2b2demodata.concept_counts_temp2 (path)');
execute immediate('CREATE INDEX i2b2demodata.PATIENTNUM_IDX ON i2b2demodata.concept_counts_temp2 (pat_num)');
commit;
FOR rec IN (SELECT distinct C_FULLNAME FROM I2B2METADATA.I2B2 where c_fullname like '\DBMI\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\%' )
LOOP
path1 := rec.C_FULLNAME;
insert  INTO I2B2DEMODATA.CONCEPT_COUNTS
select path1 AS concept_path,SUBSTR(path1,1,INSTR(path1,'\',-2,1)) as parent_concept_path,count(distinct pat_num) as patient_count from i2b2demodata.concept_counts_temp2  where path1=path;

END LOOP;
commit;


  NULL;
END SCILHS_MAPPING;