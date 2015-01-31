--------------------------------------------------------
--  DDL for Procedure DELETE_STUDY
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."DELETE_STUDY" 
(
  STUDY_ID IN VARCHAR2  
) AS 

stepCt number(18,0);

BEGIN

stepCt := 0;
  --Deapp

delete from Deapp.de_subject_microarray_data where trial_name=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' Deapp.de_subject_microarray_data ',SQL%ROWCOUNT);
delete from Deapp.de_subject_microarray_logs where trial_name=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' Deapp.de_subject_microarray_logs ',SQL%ROWCOUNT);
delete from Deapp.de_subject_microarray_med where trial_name=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' Deapp.de_subject_microarray_med ',SQL%ROWCOUNT);
delete from Deapp.de_subject_sample_mapping where trial_name=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' Deapp.de_subject_sample_mapping ',SQL%ROWCOUNT);

-- demodata
delete from I2B2DEMODATA.concept_counts where concept_path in(select concept_path from I2B2DEMODATA.concept_dimension where sourcesystem_cd=STUDY_ID);
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2DEMODATA.concept_counts ',SQL%ROWCOUNT);

delete from I2B2DEMODATA.concept_dimension where sourcesystem_cd=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' 2B2DEMODATA.concept_dimension ',SQL%ROWCOUNT);

delete from I2B2DEMODATA.patient_dimension where patient_num in(select patient_num from I2B2DEMODATA.patient_trial where trial=STUDY_ID);
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2DEMODATA.patient_dimension  ',SQL%ROWCOUNT);

delete from I2B2DEMODATA.patient_trial where trial=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2DEMODATA.patient_trial ',SQL%ROWCOUNT);

delete from I2B2DEMODATA.observation_fact where modifier_cd=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2DEMODATA.observation_fact ',SQL%ROWCOUNT);


-- metadata
delete from I2B2METADATA.i2b2_tags where tag=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' 2B2METADATA.i2b2_tags  ',SQL%ROWCOUNT);

delete from I2B2METADATA.i2b2 where sourcesystem_cd=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2METADATA.i2b2  ',SQL%ROWCOUNT);


delete from I2B2METADATA.I2B2_SECURE where sourcesystem_cd = STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2METADATA.I2B2_SECURE ',SQL%ROWCOUNT);



-- metadata
delete from I2B2METADATA.i2b2_tags where tag=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2METADATA.i2b2_tags ',SQL%ROWCOUNT);

delete from I2B2METADATA.i2b2 where sourcesystem_cd=STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' I2B2METADATA.i2b2 ',SQL%ROWCOUNT);

-- LZ ZONE ----
DELETE FROM LZ_SRC_CLINICAL_DATA WHERE STUDY_ID = STUDY_ID;
stepCt := stepCt + 1;
--dbms_output.putline(stepCt,' LZ_SRC_CLINICAL_DATA ',SQL%ROWCOUNT);

--truncate table tm_wz.wt_trial_nodes;

delete from I2B2METADATA.i2b2 where C_FULLNAME in (
'\test\STUDY_ID\');

delete from I2B2METADATA.i2b2_secure where C_FULLNAME in (
'\test\STUDY_ID\');

delete from I2B2METADATA.TABLE_ACCESS where C_FULLNAME in (
'\test\STUDY_ID\');





END DELETE_STUDY;


