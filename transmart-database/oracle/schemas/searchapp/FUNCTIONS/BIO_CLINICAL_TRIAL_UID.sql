--------------------------------------------------------
--  DDL for Function BIO_CLINICAL_TRIAL_UID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "SEARCHAPP"."BIO_CLINICAL_TRIAL_UID" (
  TRIAL_NUMBER VARCHAR2,
  TITLE VARCHAR2,
  CONDITION VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
  RETURN nvl(TRIAL_NUMBER || '|', '') || nvl(TITLE || '|', '') || nvl(CONDITION, '');
END BIO_CLINICAL_TRIAL_UID;
 
 
 
 
 
 
 
 
 

/
