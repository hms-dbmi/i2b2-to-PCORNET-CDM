--------------------------------------------------------
--  DDL for Procedure I2B2_TABLE_BKP
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_TABLE_BKP" 
AS
BEGIN
  
  -------------------------------------------------------------
  -- Backup the I2B2 tables.
  -- KCR@20090518 - First Rev
  -------------------------------------------------------------
  --Drop existing backups
  
  execute immediate('drop table i2b2metadata.i2b2_bkp');
  execute immediate('drop table i2b2demodata.concept_counts_bkp');
  execute immediate('drop table i2b2demodata.concept_dimension_bkp');
  execute immediate('drop table i2b2demodata.observation_fact_bkp');
  execute immediate('drop table i2b2demodata.patient_dimension_bkp');

  --Backup tables
  EXECUTE IMMEDIATE 'CREATE TABLE I2B2METADATA.I2B2_BKP AS SELECT * FROM I2B2METADATA.I2B2';
  EXECUTE IMMEDIATE 'CREATE TABLE I2B2DEMODATA.CONCEPT_COUNTS_BKP AS SELECT * FROM I2B2DEMODATA.CONCEPT_COUNTS';
  EXECUTE IMMEDIATE 'CREATE TABLE I2B2DEMODATA.CONCEPT_DIMENSION_BKP AS SELECT * FROM I2B2DEMODATA.CONCEPT_DIMENSION';
  EXECUTE IMMEDIATE 'CREATE TABLE I2B2DEMODATA.OBSERVATION_FACT_BKP AS SELECT * FROM I2B2DEMODATA.OBSERVATION_FACT';
  EXECUTE IMMEDIATE 'CREATE TABLE I2B2DEMODATA.PATIENT_DIMENSION_BKP AS SELECT * FROM I2B2DEMODATA.PATIENT_DIMENSION';
END;

/
