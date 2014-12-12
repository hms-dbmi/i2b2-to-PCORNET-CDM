--------------------------------------------------------
--  DDL for Function BIO_COMPOUND_UID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "TM_CZ"."BIO_COMPOUND_UID" 
( CAS_REGISTRY IN VARCHAR2,
  JNJ_NUMBER IN VARCHAR2,
  CNTO_NUMBER IN VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
  -- $Id$
  -- Function to create compound_uid.

  RETURN 'COM:' || nvl(CAS_REGISTRY, nvl(JNJ_NUMBER, nvl(CNTO_NUMBER, 'ERROR')));
END BIO_COMPOUND_UID;
 
 
 
 
 
 
 
 

/
