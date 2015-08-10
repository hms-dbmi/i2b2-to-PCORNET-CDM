 /*** Mapping to Demographics ***/
 
 CREATE TABLE "PCORI_CDMV2"."DEMOGRAPHIC" 
   (	"PATID" VARCHAR2(50 BYTE), 
	"BIRTH_DATE" VARCHAR2(10 BYTE), 
	"BIRTH_TIME" VARCHAR2(5 BYTE), 
	"SEX" VARCHAR2A(2 BYTE), 
	"HISPANIC" VARCHAR2(2 BYTE), 
	"RACE" VARCHAR2(2 BYTE), 
	"BIOBANK_FLAG" VARCHAR2(1 BYTE), 
	"RAW_SEX" VARCHAR2(50 BYTE), 
	"RAW_HISPANIC" VARCHAR2(50 BYTE), 
	"RAW_RACE" VARCHAR2(50 BYTE)
   );
   
insert /* APPEND NOLOGGING */ into "PCORI_CDMV2"."DEMOGRAPHIC" 
select distinct patient_num, NULL,NULL,null,NULL,null,NULL,SEX_CD,NULL,RACE_CD FROM PATIENT_DIMENSION WHERE SOURCESYSTEM_CD LIKE 'PMSREGISTRY%';
  
update "PCORI_CDMV2"."DEMOGRAPHIC" 
set SEX='F'
where RAW_SEX='Female';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set SEX='M'
where RAW_SEX='Male'; 

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='02'
where RAW_RACE='Asian';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='N', RAW_HISPANIC='N'
where RAW_RACE='Asian';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='N', RAW_HISPANIC='N'
where RAW_RACE='Black (Not African American)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='03'
where RAW_RACE='Black (Not African American)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='03'
where RAW_RACE='Black (African American)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='N', RAW_HISPANIC='N'
where RAW_RACE='Black (African American)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='05'
where RAW_RACE='Caucasian (Not Latino/Hispanic)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='N', RAW_HISPANIC='N'
where RAW_RACE='Caucasian (Not Latino/Hispanic)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='06'
where RAW_RACE='Caucasian (Latino/Hispanic)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='Y', RAW_HISPANIC='Y'
where RAW_RACE='Caucasian (Latino/Hispanic)';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='NI'
where RAW_RACE='No information';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='NI', RAW_HISPANIC='NI'
where RAW_RACE='No information';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set RACE='OT'
where RAW_RACE='Other';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set hispanic='OT', RAW_HISPANIC='OT'
where RAW_RACE='Other';

update "PCORI_CDMV2"."DEMOGRAPHIC" 
set raw_hispanic=RAW_RACE;  

/*** Mapping to PRO_CM ***/

 CREATE TABLE "PCORI_CDMV2"."PRO_CM" 
   (	"PATID" VARCHAR2(20 BYTE), 
	"ENCOUNTERID" VARCHAR2(20 BYTE), 
	"CM_ITEM" VARCHAR2(20 BYTE), 
	"CM_LOINC" VARCHAR2(20 BYTE), 
	"CM_DATE" VARCHAR2(20 BYTE), 
	"CM_TIME" VARCHAR2(20 BYTE), 
	"CM_RESPONSE" NUMBER(38,0), 
	"CM_METHOD" VARCHAR2(20 BYTE), 
	"CM_MODE" VARCHAR2(20 BYTE), 
	"CM_CAT" VARCHAR2(20 BYTE), 
	"RAW_CM_CODE" VARCHAR2(20 BYTE), 
	"RAW_CM_RESPONSE" VARCHAR2(200 BYTE)
   );
   
   /* Create a PRO_CM Staging table which contains following fields where 
   c_basecode contains only the concept codes of 5 PRO being mapped out of 23 PRO 
   CM_ITEM, CM_LOINC, CM_RESPONSE, CM_METHOD, CM_MODE, CM_CAT contains the number's listed in PRO_CM table of PCORI_CDMV2 
    */
   
     CREATE TABLE "PCORI_CDMV2"."PRO_CM_STAGING" 
   (	"CM_ITEM" VARCHAR2(20 BYTE), 
	"CM_LOINC" VARCHAR2(20 BYTE), 
	"CM_RESPONSE" NUMBER(38,0), 
	"CM_METHOD" VARCHAR2(20 BYTE), 
	"CM_MODE" VARCHAR2(20 BYTE), 
	"CM_CAT" VARCHAR2(20 BYTE), 
	"C_BASECODE" VARCHAR2(20 BYTE), 
	"RAW_CM_RESPONSE" VARCHAR2(200 BYTE)
   );
   
   insert /*+ APPEND NOLOGGING */ INTO "PCORI_CDMV2"."PRO_CM" 
    select a.patient_num,null,b.cm_item,b.cm_loinc,null,null,b.cm_response,b.cm_method,b.cm_mode,b.cm_cat,null,b.raw_cm_response
   from
   (OBSERVATION_FACT)a,
   ("PCORI_CDMV2"."PRO_CM_STAGING")b
   where a.concept_cd=b.c_basecode;
   
   / *** Mapping Condition table ***/
   
   /* Instead of Diagnosis for our PPRN Condition table should be mapped */
   create table PCORI_CDMV2.DIAGNOSIS
(
PATID VARCHAR2(50),
ENCOUNTERID VARCHAR2(50),
ENC_TYPE VARCHAR2(50),
ADMIT_DATE VARCHAR2(50),
PROVIDERID VARCHAR2(50),
DX VARCHAR2(500),
DX_TYPE VARCHAR2(50),
DX_SOURCE VARCHAR2(50),
PDX VARCHAR2(50),
RAW_DX VARCHAR2(500),
RAW_DX_TYPE VARCHAR2(50),
RAW_DX_SOURCE VARCHAR2(50),
RAW_PDX VARCHAR2(50));

insert  /*+ APPEND NOLOGGING */ into PCORI_CDMV2.DIAGNOSIS
select distinct patient_num,encounter_num,'OT',null,null,concept_cd,'09','OT','OT',CONCEPT_CD,'09','OT','OT' from observation_fact where sourcesystem_cd like 'ICD9%'

insert /*+ APPEND NOLOGGING */  into PCORI_CDMV2.DIAGNOSIS
select distinct patient_num,encounter_num,'OT',null,null,substr(concept_cd,5),'SM','OT','OT',substr(concept_cd,5),'SM','OT','OT' from observation_fact where sourcesystem_cd like 'SNOMED%' and concept_cd like 'SNO:%'

insert /*+ APPEND NOLOGGING */  into PCORI_CDMV2.DIAGNOSIS
select distinct patient_num,encounter_num,'OT',null,null,substr(concept_cd,4),'OT','OT','OT',substr(concept_cd,4),'OT','OT','OT' from observation_fact where sourcesystem_cd like 'HPO%'
   
      create table PCORI_CDMV2.CONDITION
	  (
	  PATID VARCHAR2(50),
	  ENCOUNTERID VARCHAR2(50),
	  REPORT_DATE VARCHAR2(50),
	  RESOLVE_DATE VARCHAR2(50),
	  CONDITION_STATUS TEXT(2),
	  CONDITION TEXT(18),
	  CONDITION_TYPE TEXT(2),
	  CONDITION_SOURCE TEXT(2),
	  RAW_CONIDITION_STATUS TEXT(50),
	  RAW_CONDIITON TEXT(50),
	  RAW_CONDIITON_TYPE TEXT(50),
	  RAW_CONDITION_SOURCE TEXT(50)
	  );   
	  
	 insert /*+ APPEND NOLOGGING */  into PCORI_CDMV2.CONDITION
     select distinct patient_num,encounter_num,null,null,null,concept_cd,'09',null,null,null,null,null from observation_fact where sourcesystem_cd like 'ICD9%'

	 insert /*+ APPEND NOLOGGING */  into PCORI_CDMV2.CONDITION
     select distinct patient_num,encounter_num,null,null,null,concept_cd,'SM',null,null,null,null,null from observation_fact where sourcesystem_cd like 'SNOMED%'
	 
	 insert /*+ APPEND NOLOGGING */ into PCORI_CDMV2.CONDITION
     select distinct patient_num,encounter_num,null,null,null,concept_cd,'OT',null,null,null,null,null from observation_fact where sourcesystem_cd like 'HPO%'

	  
	  
   