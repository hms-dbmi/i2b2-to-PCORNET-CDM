--------------------------------------------------------
--  File created - Friday-January-03-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Index PATIENT_TRIAL_INDEX1
--------------------------------------------------------

  CREATE INDEX "I2B2DEMODATA"."PATIENT_TRIAL_INDEX1" ON "I2B2DEMODATA"."PATIENT_TRIAL" ("PATIENT_NUM", "TRIAL") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TRANSMART" ;
