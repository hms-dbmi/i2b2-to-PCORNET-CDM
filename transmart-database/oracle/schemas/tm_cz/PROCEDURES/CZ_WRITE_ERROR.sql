--------------------------------------------------------
--  DDL for Procedure CZ_WRITE_ERROR
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."CZ_WRITE_ERROR" 
(
	jobId IN NUMBER,
	errorNumber IN NUMBER , 
	errorMessage IN VARCHAR2 , 
	errorStack IN VARCHAR2,
  errorBackTrace IN VARCHAR2
)
AS

BEGIN

	insert into cz_job_error(
		job_id,
		error_number,
		error_message,
		error_stack,
    error_backtrace,
		seq_id)
	select
		jobID,
		errorNumber,
		errorMessage,
		errorStack,
    errorBackTrace,
		max(seq_id) 
  from 
    cz_job_audit 
  where 
    job_id=jobID;
  
  COMMIT;

END;

 
 
 
 

/
