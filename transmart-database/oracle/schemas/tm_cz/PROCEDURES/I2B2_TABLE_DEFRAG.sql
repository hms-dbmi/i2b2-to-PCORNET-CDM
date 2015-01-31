--------------------------------------------------------
--  DDL for Procedure I2B2_TABLE_DEFRAG
--------------------------------------------------------


  CREATE OR REPLACE PROCEDURE "TM_CZ"."I2B2_TABLE_DEFRAG" 
AS
BEGIN
  
  -------------------------------------------------------------
  -- Moves the I2B2 tables to reduce defragmentation
  -- KCR@20090527 - First Rev
  -- JEA@20090923 - Removed I2B2DEMODATA.IDX_OB_FACT_3, Oracle doesn't need to index every column like SQL Server (per Aaron A.)
  -------------------------------------------------------------
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2METADATA.I2B2 MOVE';
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.CONCEPT_COUNTS MOVE';
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.CONCEPT_DIMENSION MOVE';
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT MOVE';
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.PATIENT_DIMENSION MOVE';
  --Rebuild Indexes
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.OB_FACT_PK REBUILD';
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_1 REBUILD';
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_2 REBUILD';  
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM_1 REBUILD';
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM_2 REBUILD';
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.IDX_I2B2_A REBUILD';
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.IDX_I2B2_B REBUILD';

  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.CONCEPT_COUNTS_INDEX1 REBUILD';

END;

 

 
 
 
 


