--------------------------------------------------------
--  File created - Friday-January-03-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Index IDX_OB_FACT_1
--------------------------------------------------------

  CREATE INDEX "I2B2DEMODATA"."IDX_OB_FACT_1" ON "I2B2DEMODATA"."OBSERVATION_FACT" ("CONCEPT_CD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS COMPRESS 1 NOLOGGING 
  STORAGE(INITIAL 6291456 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATA" ;
