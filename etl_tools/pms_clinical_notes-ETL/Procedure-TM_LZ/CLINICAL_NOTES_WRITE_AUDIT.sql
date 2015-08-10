create or replace PROCEDURE                                                          CLINICAL_NOTES_WRITE_AUDIT
(
stepCt in NUMBER,
database_name IN VARCHAR2,
procedure_name IN VARCHAR2,
text IN VARCHAR2,
step_status IN VARCHAR2
)AS 
BEGIN

insert into clinical_notes_log
(step_count,database_name,procedure_name,text,step_status,job_date)
select stepCt,database_name,procedure_name,text,step_status,SYSTIMESTAMP
  from dual;
  NULL;
END CLINICAL_NOTES_WRITE_AUDIT;