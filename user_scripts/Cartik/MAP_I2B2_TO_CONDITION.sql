DROP TABLE pCORI_CDMV3.CONDITION;
COMMIT;

CREATE TABLE PCORI_CDMV3.CONDITION
(
          CONDITION_ID VARCHAR2(50),  /* New Column*/
          PATID VARCHAR2(50),
          ENCOUNTERID VARCHAR2(50),
          REPORT_DATE VARCHAR2(50),
          RESOLVE_DATE VARCHAR2(50),
          ONSET_DATE VARCHAR2(50),   
          CONDITION_STATUS VARCHAR2(2),
          CONDITION VARCHAR2(100),
          CONDITION_TYPE VARCHAR2(2),
          CONDITION_SOURCE VARCHAR2(20),
          RAW_CONDITION_STATUS VARCHAR2(50),
          RAW_CONDIITON VARCHAR2(50),
          RAW_CONDIITON_TYPE VARCHAR2(50),
          RAW_CONDITION_SOURCE VARCHAR2(50)
);   
COMMIT;

INSERT /*+ APPEND NOLOGGING */ 
INTO PCORI_CDMV3.CONDITION
SELECT DISTINCT 
i2.c_basecode, ob.patient_num, ob.encounter_num, 
ob.download_date, ob.end_date, ob.start_date, NULL, 
i2.c_name, NULL, i2.sourcesystem_cd, NULL, 
NULL, NULL, NULL
from (i2b2metadata.i2b2) i2, (i2b2demodata.observation_fact) ob 
where
i2.c_basecode = ob.concept_cd and
ob.sourcesystem_cd LIKE 'HMS_PMS_NLP_IC%' and
i2.c_hlevel > 5;
COMMIT;

INSERT /*+ APPEND NOLOGGING */ 
INTO PCORI_CDMV3.CONDITION
SELECT DISTINCT 
i2.c_basecode, ob.patient_num, ob.encounter_num, 
ob.download_date, ob.end_date, ob.start_date, NULL, 
i2.c_name, NULL, i2.sourcesystem_cd, NULL, 
NULL, NULL, NULL
from (i2b2metadata.i2b2) i2, (i2b2demodata.observation_fact) ob 
where
i2.c_basecode = ob.concept_cd and
ob.sourcesystem_cd LIKE 'HMS_PMS_NLP_SNO';
COMMIT;

INSERT /*+ APPEND NOLOGGING */ 
INTO PCORI_CDMV3.CONDITION
SELECT DISTINCT 
i2.c_basecode, ob.patient_num, ob.encounter_num, 
ob.download_date, ob.end_date, ob.start_date, NULL, 
i2.c_name, NULL, i2.sourcesystem_cd, NULL, 
NULL, NULL, NULL
from (i2b2metadata.i2b2) i2, (i2b2demodata.observation_fact) ob 
where
i2.c_basecode = ob.concept_cd and
ob.sourcesystem_cd LIKE 'HMS_PMS_NLP_HPO';
COMMIT;

SELECT * FROM PCORI_CDMV3.CONDITION;
