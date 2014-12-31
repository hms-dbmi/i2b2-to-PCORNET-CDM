--------------------------------------------------------
--  DDL for Procedure DEFRAG_I2B2METADATA
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "I2B2METADATA"."DEFRAG_I2B2METADATA" 
AS
BEGIN
  
  -------------------------------------------------------------
  -- Moves the I2B2 tables to reduce defragmentation
  -- KCR@20090527 - First Rev
  -- JEA@20090923 - Removed I2B2DEMODATA.IDX_OB_FACT_3, Oracle doesn't need to index every column like SQL Server (per Aaron A.)
  -------------------------------------------------------------
 EXECUTE IMMEDIATE 'ALTER TABLE I2B2METADATA.I2B2 MOVE'; 
 
 --I removed this INDEX because it wasn't being used.  
 --EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.I2B2_IDX1 REBUILD';
 
 EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.I2B2_INDEX1 REBUILD';
 EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.I2B2_INDEX2 REBUILD';
 EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.I2B2_INDEX3 REBUILD';
 EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.META_APPLIED_PATH_I2B2_IDX REBUILD';

 EXECUTE IMMEDIATE 'ALTER TABLE I2B2METADATA.I2B2_SECURE MOVE'; 
   
 EXECUTE IMMEDIATE 'ALTER INDEX I2B2METADATA.I2B2_S_IDX1 REBUILD';

 
DBMS_STATS.GATHER_SCHEMA_STATS('I2B2METADATA');
END;

/