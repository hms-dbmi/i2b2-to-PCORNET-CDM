----------------------------------------------------
--COLUMN MODIFICATIONS
----------------------------------------------------
alter table 
   I2B2DEMODATA.OBSERVATION_FACT
modify 
( 
   START_DATE    TIMESTAMP,
   END_DATE    TIMESTAMP,
   UPDATE_DATE   TIMESTAMP,
   DOWNLOAD_DATE TIMESTAMP,
   IMPORT_DATE   TIMESTAMP
);

alter table 
   I2B2DEMODATA.CONCEPT_DIMENSION
modify 
( 
   CONCEPT_PATH    NULL
);

alter table 
   I2B2DEMODATA.PATIENT_DIMENSION
modify 
( 
   BIRTH_DATE    TIMESTAMP,
   DEATH_DATE    TIMESTAMP,
   UPDATE_DATE   TIMESTAMP,
   DOWNLOAD_DATE TIMESTAMP,
   IMPORT_DATE   TIMESTAMP
);

----------------------------------------------------

----------------------------------------------------
--MODIFIER_DIMENSION
----------------------------------------------------
SELECT * FROM TM_LZ.MODIFIER_DIMENSION_I2B2_MTM;
SELECT * FROM I2B2DEMODATA.MODIFIER_DIMENSION;

INSERT INTO I2B2DEMODATA.MODIFIER_DIMENSION
(MODIFIER_PATH, MODIFIER_CD, NAME_CHAR, MODIFIER_BLOB, UPDATE_DATE, DOWNLOAD_DATE, IMPORT_DATE, SOURCESYSTEM_CD, UPLOAD_ID)
SELECT  MODIFIER_PATH,
        MODIFIER_CD,
        NAME_CHAR,
        TO_LOB(MODIFIER_BLOB),
        TO_TIMESTAMP(UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        TO_TIMESTAMP(DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        TO_TIMESTAMP(IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        SOURCESYSTEM_CD,
        UPLOAD_ID
FROM    TM_LZ.MODIFIER_DIMENSION_I2B2_MTM;


SELECT  MODIFIER_PATH,
        MODIFIER_CD,
        NAME_CHAR,
        MODIFIER_BLOB,
        TO_TIMESTAMP(UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        TO_TIMESTAMP(DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        TO_TIMESTAMP(IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        SOURCESYSTEM_CD,
        UPLOAD_ID
FROM    TM_LZ.MODIFIER_DIMENSION_I2B2_MTM;
----------------------------------------------------



----------------------------------------------------
--CONCEPT_DIMENSION
----------------------------------------------------
--2107705
SELECT COUNT(1) FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM; WHERE CONCEPT_PATH LIKE '\i2b2\Allergy\Food Allergy\%';
--2027080
SELECT COUNT(1) FROM I2B2DEMODATA.CONCEPT_DIMENSION WHERE SOURCESYSTEM_CD LIKE 'i2b2::%';

DELETE FROM I2B2DEMODATA.CONCEPT_DIMENSION WHERE SOURCESYSTEM_CD LIKE 'i2b2::%';

INSERT INTO CONCEPT_DIMENSION 
(CONCEPT_CD, CONCEPT_PATH, NAME_CHAR, CONCEPT_BLOB, UPDATE_DATE, DOWNLOAD_DATE, IMPORT_DATE, SOURCESYSTEM_CD, UPLOAD_ID, TABLE_NAME)
SELECT  NVL(CONCEPT_CD,I2B2DEMODATA.CONCEPT_ID.nextval),
        REPLACE(CONCEPT_PATH,'\i2b2\','\Autism\BCH EHR i2b2\'),
        NAME_CHAR,
        CONCEPT_BLOB,
        TO_TIMESTAMP(UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        TO_TIMESTAMP(DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        TO_TIMESTAMP(IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
        'i2b2::' || SOURCESYSTEM_CD,
        UPLOAD_ID,
        'CONCEPT_DIMENSION'
FROM    TM_LZ.CONCEPT_DIMENSION_I2B2_MTM;

SELECT * FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM WHERE CONCEPT_PATH IS NULL;

/*
DROP TABLE TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S;

--CREATE A TABLE FROM A SUBSET OF CONCEPTS.
CREATE TABLE TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S AS
(SELECT  *  
FROM    TM_LZ.CONCEPT_DIMENSION_I2B2_MTM CD
WHERE   CONCEPT_PATH LIKE '\i2b2\Allergy\Food Allergy\%');

SELECT * FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S;

SELECT  CONCEPT_PATH,
        REPLACE(CONCEPT_PATH,'\i2b2\','\BCH The Research Connection - Autism\SFARI Simplex Collection v14\i2b2\')
FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S;


--SELECT ONLY THE CONCEPTS WHERE WE'VE OBSERVED THEM IN PATIENTS.
CREATE TABLE TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S AS
(SELECT  *  
FROM    TM_LZ.CONCEPT_DIMENSION_I2B2_MTM CD
WHERE   CD.CONCEPT_CD IN (SELECT CONCEPT_CD FROM TM_LZ.OBSERVATION_FACT_I2B2_MTM));

SELECT * FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM WHERE CONCEPT_CD NOT IN (SELECT CONCEPT_CD FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S);
SELECT COUNT(1) FROM TM_LZ.CONCEPT_DIMENSION_I2B2_MTM_S;

SELECT * FROM TM_LZ.I2B2_I2B2_MTM WHERE C_VISUALATTRIBUTES LIKE 'FA%';
*/
----------------------------------------------------

----------------------------------------------------
--I2B2
----------------------------------------------------
SELECT * FROM TM_LZ.I2B2_I2B2_MTM;
SELECT * FROM TM_LZ.I2B2_I2B2_MTM WHERE M_APPLIED_PATH != '@';
SELECT * FROM I2B2METADATA.I2B2;
SELECT * FROM I2B2METADATA.I2B2 WHERE SOURCESYSTEM_CD LIKE 'i2b2::%';
--DELETE FROM I2B2METADATA.I2B2 WHERE SOURCESYSTEM_CD LIKE 'i2b2::%';

SELECT DISTINCT SOURCESYSTEM_CD FROM I2B2METADATA.I2B2;

INSERT INTO I2B2METADATA.I2B2
(C_HLEVEL, 
C_FULLNAME, 
C_NAME, 
C_SYNONYM_CD, 
C_VISUALATTRIBUTES, 
C_TOTALNUM, 
C_BASECODE, 
C_METADATAXML, 
C_FACTTABLECOLUMN, 
C_TABLENAME, 
C_COLUMNNAME, 
C_COLUMNDATATYPE, 
C_OPERATOR, 
C_DIMCODE, 
C_COMMENT, 
C_TOOLTIP, 
UPDATE_DATE, 
DOWNLOAD_DATE, 
IMPORT_DATE, 
SOURCESYSTEM_CD, 
VALUETYPE_CD, 
I2B2_ID, 
M_APPLIED_PATH, 
M_EXCLUSION_CD, 
C_PATH, 
C_SYMBOL)
  SELECT  C_HLEVEL+1, 
  REPLACE(C_FULLNAME,'\i2b2\','\Autism\BCH EHR i2b2\'), 
  C_NAME, 
  C_SYNONYM_CD, 
  C_VISUALATTRIBUTES, 
  C_TOTALNUM, 
  C_BASECODE, 
  C_METADATAXML, 
  C_FACTTABLECOLUMN, 
  C_TABLENAME, 
  C_COLUMNNAME, 
  C_COLUMNDATATYPE, 
  C_OPERATOR, 
  REPLACE(C_DIMCODE,'\i2b2\','\Autism\BCH EHR i2b2\'), 
  C_COMMENT, 
  C_TOOLTIP, 
  TO_TIMESTAMP(UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
  TO_TIMESTAMP(DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
  TO_TIMESTAMP(IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
  'i2b2::' || SOURCESYSTEM_CD, 
  VALUETYPE_CD, 
  I2B2_ID, 
  M_APPLIED_PATH, 
  M_EXCLUSION_CD, 
  C_PATH, 
  C_SYMBOL
  FROM    TM_LZ.I2B2_I2B2_MTM;
  
  UPDATE I2B2METADATA.I2B2 SET 
  C_FACTTABLECOLUMN = 'concept_cd',
  C_TABLENAME       = 'concept_dimension',
  C_COLUMNNAME       = 'concept_path',
  C_COLUMNDATATYPE  = 'T',
  C_TOOLTIP         = 'BCH EHR i2b2',
  C_NAME            = 'BCH EHR i2b2'
  WHERE C_FULLNAME = '\Autism\BCH EHR i2b2\';
  
  exec TM_CZ.I2B2_FILL_IN_TREE('AUTISM','\Autism\BCH EHR i2b2\');
   
----------------------------------------------------

----------------------------------------------------
--PATIENT_DIMENSION
----------------------------------------------------
SELECT * FROM TM_LZ.PATIENT_DIMENSION_I2B2_MTM;

DELETE FROM I2B2DEMODATA.PATIENT_DIMENSION WHERE SOURCESYSTEM_CD = 'i2b2::BCH';
DELETE FROM TM_LZ.NEW_PATIENT_NUM;

CREATE TABLE TM_LZ.I2B2_TO_BCH_MRN
(
  "PATIENT_NUM" VARCHAR2(2000 BYTE) NULL,
  "MRN" VARCHAR2(2000 BYTE) NULL
);

CREATE TABLE TM_LZ.BCH_MRN_TO_FAMILY_ID
(
  "MRN" VARCHAR2(2000 BYTE) NULL,
  "PRIMARY_ID" VARCHAR2(2000 BYTE) NULL
);


--ANY PATIENT WHO ISN'T ALREADY IN THE CURRENT I2B2 DB NEEDS TO BE ADDED.
--CREATE A TABLE TO GIVE THESE PATIENTS NEW PATIENT_IDs.
CREATE TABLE TM_LZ.NEW_PATIENT_NUM
(
  "PATIENT_NUM" VARCHAR2(2000 BYTE) NULL,
  "NEW_PATIENT_NUM" VARCHAR2(2000 BYTE) NULL
);

INSERT INTO TM_LZ.NEW_PATIENT_NUM
SELECT  PD.PATIENT_NUM,
        I2B2DEMODATA.SEQ_PATIENT_NUM.nextval
FROM TM_LZ.PATIENT_DIMENSION_I2B2_MTM PD
WHERE PD.PATIENT_NUM NOT IN (SELECT NVL(I2B2_PATIENT_NUM,0) FROM TM_LZ.MASTER_BCH_MAPPING);

INSERT INTO I2B2DEMODATA.PATIENT_DIMENSION
(PATIENT_NUM,
VITAL_STATUS_CD,
BIRTH_DATE,
DEATH_DATE,
SEX_CD,
AGE_IN_YEARS_NUM,
LANGUAGE_CD,
RACE_CD,
MARITAL_STATUS_CD,
RELIGION_CD,
ZIP_CD,
STATECITYZIP_PATH,
UPDATE_DATE,
DOWNLOAD_DATE,
IMPORT_DATE,
SOURCESYSTEM_CD,
UPLOAD_ID,
PATIENT_BLOB,
INCOME_CD)

SELECT  NPN.NEW_PATIENT_NUM,
PD.VITAL_STATUS_CD,
TO_TIMESTAMP(PD.BIRTH_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(PD.DEATH_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
PD.SEX_CD,
PD.AGE_IN_YEARS_NUM,
PD.LANGUAGE_CD,
PD.RACE_CD,
PD.MARITAL_STATUS_CD,
PD.RELIGION_CD,
PD.ZIP_CD,
PD.STATECITYZIP_PATH,
TO_TIMESTAMP(PD.UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(PD.DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(PD.IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
'i2b2::BCH',
PD.UPLOAD_ID,
PD.PATIENT_BLOB,
PD.INCOME_CD 
FROM TM_LZ.PATIENT_DIMENSION_I2B2_MTM PD
INNER JOIN TM_LZ.NEW_PATIENT_NUM NPN ON PD.PATIENT_NUM = NPN.PATIENT_NUM;

----------------------------------------------------



----------------------------------------------------
--OBSERVATION_FACT
----------------------------------------------------
SELECT * FROM TM_LZ.OBSERVATION_FACT_I2B2_MTM;
SELECT * FROM I2B2DEMODATA.OBSERVATION_FACT;

SELECT * FROM I2B2DEMODATA.OBSERVATION_FACT WHERE SOURCESYSTEM_CD = 'AUTISM_I2B2';

--CREATE A TABLE OF DISTINCT ENCOUNTER NUMBERS AND MAP THEM TO A NEW SEQUENCE ID.
CREATE TABLE TM_LZ.NEW_ENCOUNTER_NUM
(
  "ENCOUNTER_NUM" VARCHAR2(2000 BYTE) NULL,
  "NEW_ENCOUNTER_NUM" VARCHAR2(2000 BYTE) NULL
);

INSERT INTO TM_LZ.NEW_ENCOUNTER_NUM
SELECT t.ENCOUNTER_NUM,
        I2B2DEMODATA.SQ_UP_ENCDIM_ENCOUNTERNUM.nextval
FROM
(SELECT  DISTINCT ENCOUNTER_NUM
FROM    TM_LZ.OBSERVATION_FACT_I2B2_MTM OBSF ) t
;

--CREATE A NEW PARTITION FOR THIS OBSERVATION_FACT DATA BY SPLITTING THE DEFAULT PARTITION.
ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT 
   SPLIT PARTITION OTHER_STUDIES VALUES ('AUTISM_I2B2') 
   INTO 
    ( PARTITION AUTISM_I2B2,
      PARTITION OTHER_STUDIES);

ALTER TABLE I2B2DEMODATA.OBSERVATION_FACT TRUNCATE PARTITION "AUTISM_I2B2";

ALTER INDEX I2B2DEMODATA.OB_FACT_PK REBUILD;

INSERT INTO I2B2DEMODATA.OBSERVATION_FACT
(ENCOUNTER_NUM, 
PATIENT_NUM, 
CONCEPT_CD, 
PROVIDER_ID, 
START_DATE, 
MODIFIER_CD, 
VALTYPE_CD, 
TVAL_CHAR, 
NVAL_NUM, 
VALUEFLAG_CD, 
QUANTITY_NUM, 
UNITS_CD, 
END_DATE, 
LOCATION_CD, 
CONFIDENCE_NUM, 
UPDATE_DATE, 
DOWNLOAD_DATE, 
IMPORT_DATE, 
SOURCESYSTEM_CD, 
UPLOAD_ID, 
OBSERVATION_BLOB, 
INSTANCE_NUM)
SELECT  NEN.NEW_ENCOUNTER_NUM, 
PD.PATIENT_NUM, 
OBSF.CONCEPT_CD, 
OBSF.PROVIDER_ID, 
TO_TIMESTAMP(OBSF.START_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
OBSF.MODIFIER_CD, 
OBSF.VALTYPE_CD, 
OBSF.TVAL_CHAR, 
OBSF.NVAL_NUM, 
OBSF.VALUEFLAG_CD, 
OBSF.QUANTITY_NUM, 
OBSF.UNITS_CD, 
TO_TIMESTAMP(OBSF.END_DATE,'DD-MON-YY HH12.MI.SS.FF AM'), 
OBSF.LOCATION_CD, 
CONFIDENCE_NUM, 
TO_TIMESTAMP(OBSF.UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(OBSF.DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(OBSF.IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
'AUTISM_I2B2', 
OBSF.UPLOAD_ID, 
TO_LOB(OBSF.OBSERVATION_BLOB) OBSERVATION_BLOB, 
OBSF.INSTANCE_NUM
FROM TM_LZ.OBSERVATION_FACT_I2B2_MTM OBSF
INNER JOIN TM_LZ.NEW_ENCOUNTER_NUM NEN ON NEN.ENCOUNTER_NUM = OBSF.ENCOUNTER_NUM
INNER JOIN TM_LZ.MASTER_BCH_MAPPING MM ON OBSF.PATIENT_NUM = MM.I2B2_PATIENT_NUM
INNER JOIN I2B2DEMODATA.PATIENT_DIMENSION PD ON PD.SOURCESYSTEM_CD = 'AUTISM:' || MM.SSC_SOURCESYSTEM_CD;  

INSERT INTO I2B2DEMODATA.OBSERVATION_FACT
(ENCOUNTER_NUM, 
PATIENT_NUM, 
CONCEPT_CD, 
PROVIDER_ID, 
START_DATE, 
MODIFIER_CD, 
VALTYPE_CD, 
TVAL_CHAR, 
NVAL_NUM, 
VALUEFLAG_CD, 
QUANTITY_NUM, 
UNITS_CD, 
END_DATE, 
LOCATION_CD, 
CONFIDENCE_NUM, 
UPDATE_DATE, 
DOWNLOAD_DATE, 
IMPORT_DATE, 
SOURCESYSTEM_CD, 
UPLOAD_ID, 
OBSERVATION_BLOB, 
INSTANCE_NUM)
SELECT  NEN.NEW_ENCOUNTER_NUM, 
NPN.NEW_PATIENT_NUM, 
OBSF.CONCEPT_CD, 
OBSF.PROVIDER_ID, 
TO_TIMESTAMP(OBSF.START_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
OBSF.MODIFIER_CD, 
OBSF.VALTYPE_CD, 
OBSF.TVAL_CHAR, 
OBSF.NVAL_NUM, 
OBSF.VALUEFLAG_CD, 
OBSF.QUANTITY_NUM, 
OBSF.UNITS_CD, 
TO_TIMESTAMP(OBSF.END_DATE,'DD-MON-YY HH12.MI.SS.FF AM'), 
OBSF.LOCATION_CD, 
CONFIDENCE_NUM, 
TO_TIMESTAMP(OBSF.UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(OBSF.DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(OBSF.IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
'AUTISM_I2B2', 
OBSF.UPLOAD_ID, 
TO_LOB(OBSF.OBSERVATION_BLOB) OBSERVATION_BLOB, 
OBSF.INSTANCE_NUM
FROM TM_LZ.OBSERVATION_FACT_I2B2_MTM OBSF
INNER JOIN TM_LZ.NEW_ENCOUNTER_NUM NEN ON NEN.ENCOUNTER_NUM = OBSF.ENCOUNTER_NUM
INNER JOIN TM_LZ.NEW_PATIENT_NUM NPN ON NPN.PATIENT_NUM = OBSF.PATIENT_NUM;

----------------------------------------------------



----------------------------------------------------
--VISIT_DIMENSION
----------------------------------------------------
SELECT * FROM TM_LZ.VISIT_DIMENSION_I2B2_MTM;
SELECT * FROM I2B2DEMODATA.VISIT_DIMENSION;

INSERT INTO VISIT_DIMENSION
(
ENCOUNTER_NUM,
PATIENT_NUM,
INOUT_CD,
LOCATION_CD,
LOCATION_PATH,
START_DATE,
END_DATE,
UPDATE_DATE,
DOWNLOAD_DATE,
IMPORT_DATE,
SOURCESYSTEM_CD,
UPLOAD_ID,
ACTIVE_STATUS_CD,
VISIT_BLOB,
LENGTH_OF_STAY
)
SELECT NEN.NEW_ENCOUNTER_NUM,
PD.PATIENT_NUM,
VDIM.INOUT_CD,
VDIM.LOCATION_CD,
VDIM.LOCATION_PATH,
TO_TIMESTAMP(VDIM.START_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(VDIM.END_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(VDIM.UPDATE_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(VDIM.DOWNLOAD_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
TO_TIMESTAMP(VDIM.IMPORT_DATE,'DD-MON-YY HH12.MI.SS.FF AM'),
VDIM.SOURCESYSTEM_CD,
VDIM.UPLOAD_ID,
VDIM.ACTIVE_STATUS_CD,
TO_LOB(VDIM.VISIT_BLOB),
VDIM.LENGTH_OF_STAY
FROM TM_LZ.VISIT_DIMENSION_I2B2_MTM VDIM
INNER JOIN TM_LZ.NEW_ENCOUNTER_NUM NEN ON NEN.ENCOUNTER_NUM = VDIM.ENCOUNTER_NUM
INNER JOIN TM_LZ.I2B2_TO_BCH_MRN MAP1 ON MAP1.PATIENT_NUM = VDIM.PATIENT_NUM
INNER JOIN TM_LZ.BCH_MRN_TO_FAMILY_ID MAP2 ON MAP1.MRN = MAP2.MRN
INNER JOIN TM_LZ.SSC_LINKAGE LINK1 ON LINK1.PRIMARY_ID = MAP2.PRIMARY_ID
INNER JOIN I2B2DEMODATA.PATIENT_DIMENSION PD ON PD.SOURCESYSTEM_CD = 'AUTISM:' || LINK1.ID
;
----------------------------------------------------

----------------------------------------------------
exec TM_CZ.i2b2_create_concept_counts('\Autism\Expression Array\');


UPDATE i2b2 SET C_VISUALATTRIBUTES = 'FA', C_BASECODE = NULL, C_OPERATOR = 'LIKE' WHERE C_FULLNAME LIKE '\Autism\BCH EHR i2b2\';
UPDATE i2b2 SET C_VISUALATTRIBUTES = 'FA' WHERE C_FULLNAME LIKE '\Autism\BCH EHR i2b2\%' AND C_VISUALATTRIBUTES = 'CA' AND C_HLEVEL = 2;
----------------------------------------------------





