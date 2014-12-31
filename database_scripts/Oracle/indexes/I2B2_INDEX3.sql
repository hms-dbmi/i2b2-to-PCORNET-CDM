--------------------------------------------------------
--  File created - Friday-January-03-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Index I2B2_INDEX3
--------------------------------------------------------

  CREATE INDEX "I2B2METADATA"."I2B2_INDEX3" ON "I2B2METADATA"."I2B2" ("C_BASECODE") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "TRANSMART" ;