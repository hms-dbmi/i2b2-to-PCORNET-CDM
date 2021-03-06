DROP TABLE PCORI_CDMV3.VITAL;

CREATE TABLE PCORI_CDMV3.VITAL 
(
  VITALID VARCHAR2(50) 
, PATID VARCHAR2(20) 
, ENCOUNTER_ID VARCHAR2(20) 
, MEASURE_DATE VARCHAR2(20) 
, VITAL_SOURCE VARCHAR2(2) 
, MEASURE_TIME VARCHAR2(5) 
, HT VARCHAR2(20) 
, WT VARCHAR2(20) 
, DIASTOLIC VARCHAR2(10) 
, SYSTOLIC VARCHAR2(10) 
, ORIGINAL_BMI VARCHAR2(10) 
, BP_POSITION VARCHAR2(2) 
, SMOKING VARCHAR2(2)
, TOBACCO VARCHAR2(2)
, TOBACCO_TYPE VARCHAR2(2)
, RAW_DIASTOLIC VARCHAR2(20)
, RAW_SYSTOLIC VARCHAR2(20)
, RAW_BP_POSITION VARCHAR2(20)
, RAW_SMOKING VARCHAR2(20)
, RAW_TOBACCO VARCHAR2(20)
, RAW_TOBACCO_TYPE VARCHAR2(20)
);

COMMIT;

CREATE TABLE PCORI_CDMV3.VITAL_HT
(
  PATID VARCHAR2(20),
  HT VARCHAR2(20),
  MEASURE_DATE VARCHAR2(20)
);

CREATE TABLE PCORI_CDMV3.VITAL_WT
(
  PATID VARCHAR2(20),
  WT VARCHAR2(20) 
);

INSERT INTO PCORI_CDMV3.VITAL_HT(PATID, HT, MEASURE_DATE)
SELECT 
OBFA.PATIENT_NUM, OBFA.TVAL_CHAR, OBFA.IMPORT_DATE
FROM 
(I2B2DEMODATA.OBSERVATION_FACT) OBFA,
(I2B2METADATA.I2B2) I2B2
WHERE 
OBFA.CONCEPT_CD = I2B2.C_BASECODE AND
REGEXP_LIKE (I2B2.C_FULLNAME, '^\\DBMI\\PMS_DN\\01 PMS Registry \(Patient Reported Outcomes\)\\01 PMS Patient Reported Outcomes\\Clinical\\General Information\\.*height\? \\currently\\.*$')
;

INSERT INTO PCORI_CDMV3.VITAL_WT(PATID, WT)
SELECT 
OBFA.PATIENT_NUM, OBFA.TVAL_CHAR
FROM 
(I2B2DEMODATA.OBSERVATION_FACT) OBFA,
(I2B2METADATA.I2B2) I2B2
WHERE 
OBFA.CONCEPT_CD = I2B2.C_BASECODE AND
REGEXP_LIKE (I2B2.C_FULLNAME, '^\\DBMI\\PMS_DN\\01 PMS Registry \(Patient Reported Outcomes\)\\01 PMS Patient Reported Outcomes\\Clinical\\General Information\\.*weight\? \\currently\\.*$')
;

INSERT INTO PCORI_CDMV3.VITAL(VITALID, VITAL_SOURCE, PATID, HT, WT, MEASURE_DATE)
SELECT 
VH.PATID || '_' || VH.MEASURE_DATE, 
'PR',
VH.PATID, VH.HT, VW.WT, VH.MEASURE_DATE
FROM 
(PCORI_CDMV3.VITAL_HT) VH JOIN (PCORI_CDMV3.VITAL_WT) VW
ON 
VW.PATID = VH.PATID;

COMMIT;

DROP TABLE PCORI_CDMV3.VITAL_HT;
DROP TABLE PCORI_CDMV3.VITAL_WT;
COMMIT;