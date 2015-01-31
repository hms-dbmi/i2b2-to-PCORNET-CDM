--------------------------------------------------------
--  DDL for Procedure I2B2_MOVE_STUDY
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_MOVE_STUDY" 
(
  old_path VARCHAR2,
  new_path VARCHAR2,
 -- topNode	varchar2,
  currentJobID NUMBER := null
)
AS

  root_node		varchar2(2000);
  root_level	int;
 
  --Audit variables
  newJobFlag INTEGER(1);
  databaseName VARCHAR(100);
  procedureName VARCHAR(100);
  jobID number(18,0);
  stepCt number(18,0);
  
BEGIN

 
  -------------------------------------------------------------
  --	I2B2_MOVE_STUDY is used to move an entire study to a new location in the ontology
  --	
  --	JEA@20120127	New, cloned from i2b2_move_node
  -------------------------------------------------------------
  
	stepCt := 0;
	
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

	stepCt := stepCt + 1;
	cz_write_audit(jobId,databaseName,procedureName,'Start i2b2_move_node',0,stepCt,'Done');  
	
	select parse_nth_value(new_path, 2, '\') into root_node from dual;
	
	select c_hlevel into root_level
	from table_access
	where c_name = root_node;
	
	if old_path != ''  or old_path != '%' or new_path != ''  or new_path != '%'
	then 
      --CONCEPT DIMENSION
		update concept_dimension
		set CONCEPT_PATH = replace(concept_path, old_path, new_path)
		where concept_path like old_path || '%';
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Update concept_dimension with new path',SQL%ROWCOUNT,stepCt,'Done'); 
		COMMIT;
    
		--I2B2
		update i2b2
		set c_fullname = replace(c_fullname, old_path, new_path)
			,c_dimcode = replace(c_fullname, old_path, new_path)
			,c_tooltip = replace(c_fullname, old_path, new_path)
			,c_hlevel =  (length(replace(c_fullname, old_path, new_path)) - nvl(length(replace(replace(c_fullname, old_path, new_path), '\')),0)) / length('\') - 2 + root_level
		where c_fullname like old_path || '%';
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Update i2b2 with new path',SQL%ROWCOUNT,stepCt,'Done'); 
		COMMIT;
		
		--	concept_counts
		
		update concept_counts
		set concept_path = replace(concept_path, old_path, new_path)
		   ,parent_concept_path = replace(parent_concept_path, old_path, new_path)
		where concept_path like old_path || '%';
		
		--	fill in any upper levels
		
		i2b2_fill_in_tree(null, new_path, jobID);
		
/*
		--update level data
		UPDATE I2B2
		set c_hlevel = (length(c_fullname) - nvl(length(replace(c_fullname, '\')),0)) / length('\') - 2 + root_level
		where c_fullname like new_path || '%';
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Update i2b2 with new level',SQL%ROWCOUNT,stepCt,'Done'); 
		COMMIT;
		
		--Update tooltip and dimcode
		update i2b2
		set c_dimcode = c_fullname,
		c_tooltip = c_fullname
		where c_fullname like new_path || '%';
		stepCt := stepCt + 1;
		cz_write_audit(jobId,databaseName,procedureName,'Update i2b2 with new dimcode and tooltip',SQL%ROWCOUNT,stepCt,'Done'); 
		COMMIT;

		if topNode != '' then
			i2b2_fill_in_tree
			i2b2_create_concept_counts(topNode,jobId);
		end if;
*/
	end if;
	
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


