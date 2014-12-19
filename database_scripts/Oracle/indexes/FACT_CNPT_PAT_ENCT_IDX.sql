--------------------------------------------------------
--  File created - Friday-January-03-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Index FACT_CNPT_PAT_ENCT_IDX
--------------------------------------------------------

  CREATE INDEX "I2B2DEMODATA"."FACT_CNPT_PAT_ENCT_IDX" ON "I2B2DEMODATA"."OBSERVATION_FACT" ("CONCEPT_CD", "INSTANCE_NUM", "PATIENT_NUM", "ENCOUNTER_NUM", "VALTYPE_CD", "NVAL_NUM", "TVAL_CHAR") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATA" ;
