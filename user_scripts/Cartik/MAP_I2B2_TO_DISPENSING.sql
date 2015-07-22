TRUNCATE TABLE pCORI_CDMV3.DISPENSING;

CREATE TABLE PCORI_CDMV3.DISPENSING_STAGING (
  PATIENT_NUM VARCHAR2(20 BYTE),
  NDC VARCHAR2(11 BYTE),
  NDC_RAW VARCHAR2(50 BYTE)
);

INSERT /*+ APPEND NOLOGGING */ 
INTO PCORI_CDMV3.DISPENSING_STAGING
SELECT DISTINCT 
ob.patient_num, 
i2.c_basecode
FROM 
i2b2demodata.observation_fact ob,
i2b2metadata.i2b2 i2 
WHERE
ob.concept_cd = i2.C_BASECODE
and ob.sourcesystem_cd = 'HMS_PMS_NLP_NDT' 
and i2.c_hlevel > 4 
ORDER BY ob.PATIENT_NUM;

INSERT /*+ APPEND NOLOGGING */ 
INTO PCORI_CDMV3.DISPENSING 
SELECT 
PATIENT_NUM || '_' || NDC,
PATIENT_NUM,
NULL,
TO_CHAR(SYSDATE), 
NDC,
NULL, 
NULL, 
NULL
FROM 
PCORI_CDMV3.DISPENSING_STAGING;

DROP TABLE pCORI_CDMV3.DISPENSING_STAGING;