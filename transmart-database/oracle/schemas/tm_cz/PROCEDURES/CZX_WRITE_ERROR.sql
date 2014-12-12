--------------------------------------------------------
--  DDL for Procedure CZX_WRITE_ERROR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."CZX_WRITE_ERROR" (JOBID IN NUMBER,
	ERRORNUMBER IN NUMBER , 
	ERRORMESSAGE IN VARCHAR2 , 
	ERRORSTACK IN VARCHAR2,
  ERRORBACKTRACE IN VARCHAR2)
  AUTHID CURRENT_USER
AS
 PRAGMA AUTONOMOUS_TRANSACTION;
-------------------------------------------------------------------------------------
-- NAME: CZX_WRITE_ERROR
--
-- Copyright c 2011 Recombinant Data Corp.
--

--------------------------------------------------------------------------------------
BEGIN

	INSERT INTO CZ_JOB_ERROR(
		JOB_ID,
		ERROR_NUMBER,
		ERROR_MESSAGE,
		ERROR_STACK,
    ERROR_BACKTRACE,
		SEQ_ID)
	SELECT
		JOBID,
		ERRORNUMBER,
		ERRORMESSAGE,
		ERRORSTACK,
    ERRORBACKTRACE,
		MAX(SEQ_ID) 
  FROM 
    CZ_JOB_AUDIT 
  WHERE 
    JOB_ID=JOBID;
  
  COMMIT;
 
EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
END;
 

/
