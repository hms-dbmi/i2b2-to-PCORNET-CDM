--------------------------------------------------------
--  DDL for Procedure I2B2_CREATE_SECURITY_FOR_TRIAL
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_CREATE_SECURITY_FOR_TRIAL" 
(
  trial_id VARCHAR2
 ,secured_study varchar2 := 'N'
 ,currentJobID NUMBER := null
)
AS
  TrialID varchar2(100);
  securedStudy varchar2(5);
  
  --Audit variables
  newJobFlag INTEGER(1);
  databaseName VARCHAR(100);
  procedureName VARCHAR(100);
  jobID number(18,0);
  stepCt number(18,0);

BEGIN
  TrialID := upper(trial_id);
  securedStudy := secured_study;


  -------------------------------------------------------------
  -- Create the security data needed for I2B2 per Trial
  -- KCR@20090520 - First Rev
  -- JEA@20091118 - Added auditing
  -- JEA@20091204 - Added study_type input variable so that Public Studies security can be properly set
  -- JEA@20100111 - Changed security for all \Internal Studies\ and \Experimental Medicine Study\Normals\ to be EXP:PUBLIC
  -- JEA@20120120 - Added insert/delete of patient to observation_fact with concept_cd of SECURITY, insert/delete to patient_trial (replaces
  --				i2b2_create_patient_trial and embedded code
  --
  -------------------------------------------------------------
  
	--Set Audit Parameters
	newJobFlag := 0; -- False (Default)
	jobID := currentJobID;

	SELECT sys_context('USERENV', 'CURRENT_SCHEMA') INTO databaseName FROM dual;
	procedureName := $$PLSQL_UNIT;

	--Audit JOB Initialization
	--If Job ID does not exist, then this is a single procedure run and we need to create it
	IF(jobID IS NULL or jobID < 1)
	THEN
		newJobFlag := 1; -- True
		cz_start_audit (procedureName, databaseName, jobID);
	END IF;
  
   
	stepCt := 0;
  
	delete from i2b2demodata.observation_fact
	where sourcesystem_cd like '%' || TrialID || '%'
	  and concept_cd = 'SECURITY';
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete security records for trial from I2B2DEMODATA observation_fact',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;

	insert into i2b2demodata.observation_fact
    (patient_num
	,concept_cd
	,provider_id
	,modifier_cd
	,valtype_cd
	,tval_char
	,valueflag_cd
	,location_cd
	,update_date
	,download_date
	,import_date
	,sourcesystem_cd
	)
	select patient_num
		  ,'SECURITY'
		  ,'@'
		  ,TrialID
		  ,'T'
		  ,decode(securedStudy,'N','EXP:PUBLIC','EXP:' || trialID)
		  ,'@'
		  ,'@'
		  ,sysdate
		  ,sysdate
		  ,sysdate
		  ,sourcesystem_cd
	from patient_dimension
	where sourcesystem_cd like '%' || TrialID || '%';
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert security records for trial from I2B2DEMODATA observation_fact',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
	
	--	insert patients to patient_trial table
	
	delete from patient_trial
	where trial  = TrialID;
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Delete data for trial from I2B2DEMODATA patient_trial',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
  
	insert into i2b2demodata.patient_trial
	(patient_num
	,trial
	,secure_obj_token
	)
	select patient_num, 
		   TrialID,
		   decode(securedStudy,'Y','EXP:' || TrialID,'EXP:PUBLIC')
	from patient_dimension
	where sourcesystem_cd like TrialID || '%';
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert data for trial into I2B2DEMODATA patient_trial',SQL%ROWCOUNT,stepCt,'Done');
	
	commit;
     
    ---Cleanup OVERALL JOB if this proc is being run standalone
  IF newJobFlag = 1
  THEN
    cz_end_audit (jobID, 'SUCCESS');
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    --Handle errors.
    cz_error_handler (jobID, procedureName);
    --End Proc
    cz_end_audit (jobID, 'FAIL');
	
END;

/
