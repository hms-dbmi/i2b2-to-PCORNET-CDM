--------------------------------------------------------
--  DDL for Function BIO_CURATION_DATASET_UID
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION "BIOMART"."BIO_CURATION_DATASET_UID" (
  BIO_CURATION_TYPE VARCHAR2
) RETURN VARCHAR2 AS
BEGIN
  -- $Id$
  -- Creates uid for bio_experiment.

  RETURN 'BCD:' || nvl(BIO_CURATION_TYPE, 'ERROR');
END BIO_CURATION_DATASET_UID;

 
 
 
 
 
 
 
 
 
 

/