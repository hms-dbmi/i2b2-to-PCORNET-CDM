--------------------------------------------------------
--  DDL for Procedure CZX_END_AUDIT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."CZX_END_AUDIT" (V_JOB_ID IN NUMBER DEFAULT NULL ,
  V_JOB_STATUS IN VARCHAR2 DEFAULT 'Success')
  AUTHID CURRENT_USER
AS
-------------------------------------------------------------------------------------
-- NAME: CZX_END_AUDIT
--
-- Copyright c 2011 Recombinant Data Corp.
--

--------------------------------------------------------------------------------------	
 PRAGMA AUTONOMOUS_TRANSACTION;
 
  ENDDATE TIMESTAMP;

BEGIN
  DBMS_OUTPUT.PUT_LINE('Job ID = ' || V_JOB_ID || ',' || V_JOB_STATUS);
  
  ENDDATE := SYSTIMESTAMP;
  
	UPDATE CZ_JOB_MASTER
		SET 
			ACTIVE='N',
			END_DATE = ENDDATE,
      TIME_ELAPSED_SECS = 
      EXTRACT (DAY    FROM (ENDDATE - START_DATE))*24*60*60 + 
      EXTRACT (HOUR   FROM (ENDDATE - START_DATE))*60*60 + 
      EXTRACT (MINUTE FROM (ENDDATE - START_DATE))*60 + 
      EXTRACT (SECOND FROM (ENDDATE - START_DATE)),
			JOB_STATUS = V_JOB_STATUS
		WHERE ACTIVE='Y' 
		AND JOB_ID=V_JOB_ID;

COMMIT;

	IF V_JOB_STATUS = 'FAIL'
	THEN
		DBMS_OUTPUT.PUT_LINE('Job Failed - See cz_job_error for details');
	END IF;
  
--EXCEPTION
--	WHEN OTHERS THEN 
--	DBMS_OUTPUT.PUT_LINE('ERROR HERE!');
--    ROLLBACK;  
END;

/
