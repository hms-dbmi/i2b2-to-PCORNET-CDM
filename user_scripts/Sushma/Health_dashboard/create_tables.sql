CREATE TABLE BIOMART.COMPUTE_STATS 
   (	"C_FULLNAME" VARCHAR2(4000 BYTE) NOT NULL ENABLE, 
	"DISTINCT_PATIENTS" NUMBER, 
	"DISTINCT_CONCEPTS" NUMBER, 
	"NUMBER_OF_FACTS" NUMBER
   );
   
 CREATE TABLE "BIOMART"."CONCEPT_STATS" 
   (	"SOURCESYSTEM_CD" VARCHAR2(50 BYTE), 
	"COUNT_OF_CONCEPTS" NUMBER
   );
   
 CREATE TABLE "BIOMART"."OBSERVATION_STATS" 
   (	"SOURCESYSTEM_CD" VARCHAR2(100 BYTE), 
	"NB_OBSERVATION_FACT" NUMBER, 
	"DISTINCT_PATIENT_NUM" NUMBER, 
	"DISTINT_CONCEPT_CD" NUMBER, 
	"MIN_START_DATE" DATE, 
	"MAX_START_DATE" DATE
   );
   
 CREATE TABLE "BIOMART"."SCHEMA_STATS" 
   (	"OWNER" VARCHAR2(30 BYTE), 
	"GB" VARCHAR2(9 BYTE)
   );
 
GRANT SELECT ANY DICTIONARY TO biomart;
grant all on "I2B2METADATA"."I2B2" to "BIOMART" ;
grant all on "I2B2DEMODATA"."CONCEPT_DIMENSION"  to "BIOMART" ;
grant all on "I2B2DEMODATA"."OBSERVATION_FACT"  to "BIOMART" ;

 CREATE TABLE "BIOMART"."WEB_LINKS" 
   (	"NAME" VARCHAR2(100 BYTE), 
	"URL" VARCHAR2(500 BYTE), 
	"ID" NUMBER
   );
create sequence biomart.web_id;