--------------------------------------------------------
--  DDL for Procedure I2B2_CREATE_CONCEPT_COUNTS
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_CREATE_CONCEPT_COUNTS" 
(
  path VARCHAR2
 ,FactSet VARCHAR2
 ,currentJobID NUMBER := null
)
AS
  -------------------------------------------------------------
  -- Insert records into the Concept Counts table for new nodes
  -- KCR@20090404 - First Rev
  -- KCR@20090709 - NEXT Rev
  -- JEA@20090817 - Changed processing to eliminate need for cursor
  -- JEA@20091118 - Added auditing
  -- JEA@20100507 - Changed to account for Biomarker mRNA nodes that may have different patient counts from
  --				the Samples & Timepoints concept
  -- JEA220100702 - Remove separate pass for Biomarker mRNA nodes, they now have unique concept codes
  -- JEA@20111025	Exclude samples from being counted as subjects
  -- JEA@20120113	Allow for third character in c_visualattributes
  
  --1. BUILD A TEMP TABLE OF ALL CONCEPT CODES WITH THEIR PATIENTS.
  -- NEED TO INCLUDE ROLLUPS OF INDIRECT RELATIONSHIPS (FOLDERS TO THEIR CHILDREN)
  --Build a cursor of Paths by level
  --iterate through the paths in reverse, so determine max level and go backwards, 
  --this way each folder will have the data needed when you get to it already rolled up

  -------------------------------------------------------------
    
  --Audit variables
  newJobFlag INTEGER(1);
  databaseName VARCHAR(100);
  procedureName VARCHAR(100);
  jobID number(18,0);
  stepCt number(18,0);
  
BEGIN
     
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
  
  delete 
    from concept_counts
  where 
    concept_path like path || '%';
  stepCt := stepCt + 1;
  cz_write_audit(jobId,databaseName,procedureName,'Delete counts for trial from I2B2DEMODATA concept_counts',SQL%ROWCOUNT,stepCt,'Done');
	
  commit;
	
	--	Join each node (folder or leaf) in the path to it's leaf in the work table to count patient numbers
	insert into concept_counts
	(concept_path
	,parent_concept_path
	,patient_count
	)
	select fa.c_fullname
		  ,ltrim(SUBSTR(fa.c_fullname, 1,instr(fa.c_fullname, '\',-1,2)))
		  ,count(distinct tpm.patient_num)
	from i2b2 fa
	    ,i2b2 la
		,observation_fact tpm
		,patient_dimension p
	where fa.c_fullname like path || '%'
	  and fa.c_visualattributes != 'LAH'
	  and la.c_fullname like fa.c_fullname || '%'
	  and la.c_visualattributes like 'L%'
	  and tpm.patient_num = p.patient_num
	  and la.c_basecode = tpm.concept_cd(+)
	group by fa.c_fullname
			,ltrim(SUBSTR(fa.c_fullname, 1,instr(fa.c_fullname, '\',-1,2)));
			
	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Insert counts for trial into I2B2DEMODATA concept_counts',SQL%ROWCOUNT,stepCt,'Done');
		
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


/*	The following code was never implemented in production

  --Truncate temp table
  EXECUTE IMMEDIATE('TRUNCATE TABLE I2B2_PATIENT_ROLLUP');

  --REMOVE RECORDS FROM CONCEPT COUNTS FOR THIS PATH

  --get max level
  SELECT max(c_hlevel) into maxLevel 
    FROM i2b2
      WHERE c_visualattributes not like '%H%' --do not consider Hidden values
      and c_fullname like path || '%';

  --iterate through all paths by level in reverse
  FOR Lpath IN REVERSE 0..maxLevel
  LOOP
    --inner loop through cursor for the particular level
    currentLevel := Lpath;
    FOR r_cPath in cPath Loop
      insert into i2b2_patient_rollup
        SELECT distinct r_cPath.concept_cd, r_cPath.concept_path, b.patient_num, currentLevel
          from concept_dimension a
          join observation_fact b
            on a.concept_cd = b.concept_cd
            and a.concept_cd = r_cPath.concept_cd
        union
        select distinct r_cPath.concept_cd, r_cPath.concept_path, a.patient_num, currentLevel
          from i2b2_patient_rollup a
            where a.concept_path like r_cPath.concept_path || '%'
              and a.c_hlevel = (currentLevel + 1);
    COMMIT;
    END LOOP;  
  END LOOP;
  
  --aggregate the temp table and load into concept_counts  
  INSERT
  INTO CONCEPT_COUNTS
  (
    CONCEPT_PATH,
    PATIENT_COUNT
  )
  SELECT CONCEPT_PATH, COUNT(DISTINCT PATIENT_NUM)
  FROM i2b2_patient_rollup
  GROUP BY CONCEPT_PATH;
  COMMIT;
*/

/
