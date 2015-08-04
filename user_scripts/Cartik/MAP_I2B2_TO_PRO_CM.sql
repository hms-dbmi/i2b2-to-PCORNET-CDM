--------------------------------------------------------
--  File created - Wednesday-June-17-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table PRO_CM_STAGING
--------------------------------------------------------

  CREATE TABLE "PCORI_CDMV3"."PRO_CM_STAGING" 
   (	"CM_ITEM" VARCHAR2(20 BYTE), 
	"CM_LOINC" VARCHAR2(20 BYTE), 
	"CM_RESPONSE" NUMBER(38,0), 
	"CM_METHOD" VARCHAR2(20 BYTE), 
	"CM_MODE" VARCHAR2(20 BYTE), 
	"CM_CAT" VARCHAR2(20 BYTE), 
	"C_BASECODE" VARCHAR2(20 BYTE), 
	"RAW_CM_RESPONSE" VARCHAR2(200 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS NOLOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
 ;

REM INSERTING into PCORI_CDMV3.PRO_CM_STAGING
SET DEFINE OFF;
--Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAA');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0012','75416-8',4,'EC','PR','N','103655','The patient has been diagnosed with depression or bipolar/manic depression');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0005','61967-6',5,'EC','PR','N','103661','The patient has been diagnosed with depression or bipolar/manic depression ');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0005','61967-6',1,'EC','PR','N','103662','The patient has never been diagnosed with depression neither bipolar/manic depression');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0006','61998-1',1,'EC','PR','N','103659','The patient never experienced any of these symptoms neither insomnia ');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0006','61998-1',5,'EC','PR','N','103647','The patient experienced insomnia in adolescence/adulthood ');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0007','75417-6',3,'EC','PR','N','103653','The patient''s interest in social interaction increased in adulthood');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0007','75417-6',2,'EC','PR','N','103667','The patient''s interest in social interaction decreased in adulthood');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0017','61949-4',1,'EC','PR','N','103663','The patient has never been diagnosed with anxiety disorder or panic attacks or obsessive compulsive disorder neither exhibited anxiety ');
Insert into PCORI_CDMV3.PRO_CM_STAGING (CM_ITEM,CM_LOINC,CM_RESPONSE,CM_METHOD,CM_MODE,CM_CAT,C_BASECODE,RAW_CM_RESPONSE) values ('PN_0017','61949-4',5,'EC','PR','N','103656','The patient has been diagnosed with anxiety disorder or panic attacks or obsessive compulsive disorder; or the patient repeatedly exhibited anxiety');

--------------------------------------------------------
--  File created - Tuesday-August-04-2015   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Table PRO_CM
--------------------------------------------------------

  
CREATE TABLE PCORI_CDMV3.PRO_CM 
(	
  PRO_CM_ID VARCHAR2(200 BYTE), /* New Column */
  PATID VARCHAR2(20 BYTE), 
	ENCOUNTERID VARCHAR2(20 BYTE), 
	CM_ITEM VARCHAR2(20 BYTE), 
	CM_LOINC VARCHAR2(20 BYTE), 
	CM_DATE VARCHAR2(20 BYTE), 
	CM_TIME VARCHAR2(20 BYTE), 
	CM_RESPONSE NUMBER(38,0), 
	CM_METHOD VARCHAR2(20 BYTE), 
	CM_MODE VARCHAR2(20 BYTE), 
	CM_CAT VARCHAR2(20 BYTE), 
	RAW_CM_CODE VARCHAR2(20 BYTE), 
	RAW_CM_RESPONSE VARCHAR2(200 BYTE)
);

