--------------------------------------------------------
--  DDL for Procedure CZX_ERROR_HANDLER
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."CZX_ERROR_HANDLER" (JOBID NUMBER,
	PROCEDURENAME NVARCHAR2)
  AUTHID CURRENT_USER
AS
-------------------------------------------------------------------------------------
-- NAME: CZX_ERROR_HANDLER
--
-- Copyright c 2011 Recombinant Data Corp.
--

--------------------------------------------------------------------------------------	
	DATABASENAME NVARCHAR2(100);
	ERRORNUMBER NUMBER(18,0);
	ERRORMESSAGE NVARCHAR2(1000);
	ERRORSTACK NVARCHAR2(4000);
	ERRORBACKTRACE NVARCHAR2(4000);
	STEPNO NUMBER(18,0);

BEGIN
	 --GET DB NAME
	SELECT DATABASE_NAME 
		INTO DATABASENAME
	FROM CZ_JOB_MASTER 
		WHERE JOB_ID=JOBID;
  
	--GET LATEST STEP
	SELECT MAX(STEP_NUMBER) 
		INTO STEPNO 
	FROM CZ_JOB_AUDIT 
		WHERE JOB_ID = JOBID;
  
	--GET ALL ERROR INFO
	ERRORNUMBER := SQLCODE;
	ERRORMESSAGE := SQLERRM;
	ERRORSTACK := DBMS_UTILITY.FORMAT_ERROR_STACK;
	ERRORBACKTRACE := DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;

	--UPDATE THE AUDIT STEP FOR THE ERROR
	CZX_WRITE_AUDIT(JOBID, DATABASENAME,PROCEDURENAME, 'Job Failed: See error log for details',SQL%ROWCOUNT, STEPNO, 'FAIL');

	--WRITE OUT THE ERROR INFO
	CZX_WRITE_ERROR(JOBID, ERRORNUMBER, ERRORMESSAGE, ERRORSTACK, ERRORBACKTRACE);

	--COMPLETE THE JOB WITH FAILURE
	CZX_END_AUDIT (JOBID, 'FAIL');

END;


