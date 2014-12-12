--------------------------------------------------------
--  DDL for Procedure CZX_WRITE_AUDIT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."CZX_WRITE_AUDIT" (JOBID IN NUMBER,
	DATABASENAME IN VARCHAR2 ,
	PROCEDURENAME IN VARCHAR2 ,
	STEPDESC IN VARCHAR2 ,
	RECORDSMANIPULATED IN NUMBER,
	STEPNUMBER IN NUMBER,
	STEPSTATUS IN VARCHAR2)
  AUTHID CURRENT_USER
AS
-------------------------------------------------------------------------------------
-- NAME: CZX_WRITE_AUDIT
--
-- Copyright c 2011 Recombinant Data Corp.
--

--------------------------------------------------------------------------------------
 PRAGMA AUTONOMOUS_TRANSACTION;

  LASTTIME TIMESTAMP;
  v_version_id NUMBER;

BEGIN
  SELECT MAX(JOB_DATE)
    INTO LASTTIME
    FROM CZ_JOB_AUDIT
    WHERE JOB_ID = JOBID;

	INSERT 	INTO CZ_JOB_AUDIT(
		JOB_ID,
		DATABASE_NAME,
 		PROCEDURE_NAME,
 		STEP_DESC,
		RECORDS_MANIPULATED,
		STEP_NUMBER,
		STEP_STATUS,
    JOB_DATE,
    TIME_ELAPSED_SECS
	)
	SELECT
 		JOBID,
		DATABASENAME,
		PROCEDURENAME,
		STEPDESC,
		RECORDSMANIPULATED,
		STEPNUMBER,
		STEPSTATUS,
    SYSTIMESTAMP,
      COALESCE(
      EXTRACT (DAY    FROM (SYSTIMESTAMP - LASTTIME))*24*60*60 +
      EXTRACT (HOUR   FROM (SYSTIMESTAMP - LASTTIME))*60*60 +
      EXTRACT (MINUTE FROM (SYSTIMESTAMP - LASTTIME))*60 +
      EXTRACT (SECOND FROM (SYSTIMESTAMP - LASTTIME))
      ,0)
  FROM DUAL;

  COMMIT;

EXCEPTION
    WHEN OTHERS THEN ROLLBACK;
END;
 

/
