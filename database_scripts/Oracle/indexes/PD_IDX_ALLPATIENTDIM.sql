--------------------------------------------------------
--  File created - Friday-January-03-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Index PD_IDX_ALLPATIENTDIM
--------------------------------------------------------

  CREATE INDEX "I2B2DEMODATA"."PD_IDX_ALLPATIENTDIM" ON "I2B2DEMODATA"."PATIENT_DIMENSION" ("PATIENT_NUM", "VITAL_STATUS_CD", "BIRTH_DATE", "DEATH_DATE", "SEX_CD", "AGE_IN_YEARS_NUM", "LANGUAGE_CD", "RACE_CD", "MARITAL_STATUS_CD", "RELIGION_CD", "ZIP_CD", "INCOME_CD") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "I2B2_DATA" ;
