create or replace 
PROCEDURE                            DEFRAG_I2B2DEMODATA
AS


BEGIN
--SET serveroutput ON;
 
  dbms_output.enable(100000);
  
  -------------------------------------------------------------
  -- Moves the I2B2 tables to reduce defragmentation
  -- KCR@20090527 - First Rev
  -- JEA@20090923 - Removed I2B2DEMODATA.IDX_OB_FACT_3, Oracle doesn't need to index every column like SQL Server (per Aaron A.)
  -------------------------------------------------------------

   
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.CONCEPT_COUNTS MOVE';
  dbms_output.put_line('MOVE CONCEPT_COUNTS ');
 
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.CONCEPT_DIMENSION MOVE';
  dbms_output.put_line('MOVE CONCEPT_DIMENSION ');
 
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT MOVE';
  dbms_output.put_line('MOVE OBSERVATION_FACT ');
 
  EXECUTE IMMEDIATE 'ALTER TABLE I2B2DEMODATA.PATIENT_DIMENSION MOVE';
  dbms_output.put_line('MOVE PATIENT_DIMENSION ');
 
  --Rebuild Indexes
  
  --Observation Fact
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.OB_FACT_PK REBUILD';
  dbms_output.put_line('REBUILD OB_FACT_PK ');
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_1 REBUILD';
  dbms_output.put_line('REBUILD IDX_OB_FACT_1');
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_2 REBUILD';
  dbms_output.put_line('REBUILD IDX_OB_FACT_2');

  --Removed this, it wasn't being used.
  --EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_ENC REBUILD';
  --dbms_output.put_line('REBUILD IDX_OB_FACT_ENC');
  
  --Removed this, it wasn't being used.
  --EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_MODIFIER rebuild';
  --dbms_output.put_line('REBUILD IDX_MODIFIER');
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.FACT_CNPT_PAT_ENCT_IDX rebuild';
  dbms_output.put_line('REBUILD FACT_CNPT_PAT_ENCT_IDX');
  -------------------
  
  --Concept Dimension
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM_1 REBUILD';
  dbms_output.put_line('REBUILD IDX_CONCEPT_DIM_1');
  
  --Removed this, it wasn't being used.
  --EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM_2 REBUILD';
  --dbms_output.put_line('REBUILD IDX_CONCEPT_DIM_2');
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM3 REBUILD';
  dbms_output.put_line('REBUILD IDX_CONCEPT_DIM3');
  -------------------
  
  --Concept Counts
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.CONCEPT_COUNTS_INDEX1 REBUILD';
  dbms_output.put_line('REBUILD CONCEPT_COUNTS_INDEX1');
  
  -------------------
  
  --Patient Dimension
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.PD_IDX_ALLPATIENTDIM rebuild';
  dbms_output.put_line('REBUILD PD_IDX_ALLPATIENTDIM');
  
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.PATIENT_DIMENSION_INDEX1 rebuild';
  dbms_output.put_line('REBUILD PATIENT_DIMENSION_INDEX1');
  -------------------
  
  --Patient Trial
  EXECUTE IMMEDIATE 'ALTER INDEX I2B2DEMODATA.PATIENT_TRIAL_INDEX1 rebuild';
  dbms_output.put_line('REBUILD PATIENT_TRIAL_INDEX1');
  -------------------
  
  DBMS_STATS.GATHER_SCHEMA_STATS('I2B2DEMODATA');
  dbms_output.put_line('GATHER_SCHEMA_STATS I2B2DEMODATA');

END;