
alter session set current_schema=I2B2DEMODATA;

/* Create modifiers in MODIFIER_DIMENSION_TABLE: CUSTOM:OBSERVATION_VALID, CUSTOM:OBSERVATION_INVALID_REASON, PATIENT_VALID, CONCEPT_VALIDATED */
/* Note: Run only once (adds new rows each time */
INSERT ALL 
INTO MODIFIER_DIMENSION (MODIFIER_PATH, MODIFIER_CD, NAME_CHAR, SOURCESYSTEM_CD) VALUES 
('\OBSERVATION_VALID\', 'CUSTOM:OBSERVATION_VALID:', 'OBSERVATION_VALID', 'CTAKES_16TESTFILES')
INTO MODIFIER_DIMENSION (MODIFIER_PATH, MODIFIER_CD, NAME_CHAR, SOURCESYSTEM_CD) VALUES 
('\OBSERVATION_INVALID_REASON\', 'CUSTOM:OBSERVATION_INVALID_REASON:', 'OBSERVATION_INVALID_REASON', 'CTAKES_16TESTFILES')
INTO MODIFIER_DIMENSION (MODIFIER_PATH, MODIFIER_CD, NAME_CHAR, SOURCESYSTEM_CD) VALUES 
('\PATIENT_VALID\', 'CUSTOM:PATIENT_VALID:', 'PATIENT_VALID', 'CTAKES_16TESTFILES')
INTO MODIFIER_DIMENSION (MODIFIER_PATH, MODIFIER_CD, NAME_CHAR, SOURCESYSTEM_CD) VALUES 
('\CONCEPT_VALIDATED\', 'CUSTOM:CONCEPT_VALIDATED:', 'CONCEPT_VALIDATED', 'CTAKES_16TESTFILES')
SELECT * FROM dual;

/* Add modifiers to i2b2 table */
INSERT ALL
INTO I2B2METADATA.I2B2 (C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_BASECODE,
C_METADATAXML, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR,
C_DIMCODE, C_COMMENT, C_TOOLTIP, UPDATE_DATE, SOURCESYSTEM_CD, VALUETYPE_CD, I2B2_ID,
M_APPLIED_PATH, M_EXCLUSION_CD, C_PATH, C_SYMBOL) VALUES
(2,'\cTAKES Modifiers\OBSERVATION_VALID\', 'OBSERVATION_VALID', 'N', 'RA', 'CUSTOM:OBSERVATION_VALID:', '"<ValueMetadata> 
    <Version>3.02</Version> 
     <TestID>CUSTOM:OBSERVATION_VALID:</TestID> 
     <TestName>OBSERVATION_VALID List</TestName> 
     <DataType>Enum</DataType> 
     <Oktousevalues>Y</Oktousevalues> 
     <EnumValues> 
          <Val description="Positive">1</Val> 
          <Val description="Negative">-1</Val>                             
     </EnumValues> 
</ValueMetadata>"',	'MODIFIER_CD', 'MODIFIER_DIMENSION', 'MODIFIER_PATH',	'T', 'LIKE',
'\OBSERVATION_VALID\', null, '\cTAKES Modifiers\OBSERVATION_VALID\', '04-DEC-2014', 'cTAKES_MODIFIERS', null, '20000',
'\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%', null, '\cTAKES Modifiers\', 'OBSERVATION_VALID')
INTO I2B2METADATA.I2B2 (C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_BASECODE,
C_METADATAXML, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR,
C_DIMCODE, C_COMMENT, C_TOOLTIP, UPDATE_DATE, SOURCESYSTEM_CD, VALUETYPE_CD, I2B2_ID,
M_APPLIED_PATH, M_EXCLUSION_CD, C_PATH, C_SYMBOL) VALUES
(2,'\cTAKES Modifiers\OBSERVATION_INVALID_REASON\',	'OBSERVATION_INVALID_REASON', 'N', 'RA', 'CUSTOM:OBSERVATION_INVALID_REASON:',
null, 'MODIFIER_CD', 'MODIFIER_DIMENSION', 'MODIFIER_PATH',	'T', 'LIKE',
'\OBSERVATION_INVALID_REASON\', null, '\cTAKES Modifiers\OBSERVATION_INVALID_REASON\', '04-DEC-2014', 'cTAKES_MODIFIERS', null, '20000',
'\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%', null, '\cTAKES Modifiers\', 'OBSERVATION_INVALID_REASON')
INTO I2B2METADATA.I2B2 (C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_BASECODE,
C_METADATAXML, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR,
C_DIMCODE, C_COMMENT, C_TOOLTIP, UPDATE_DATE, SOURCESYSTEM_CD, VALUETYPE_CD, I2B2_ID,
M_APPLIED_PATH, M_EXCLUSION_CD, C_PATH, C_SYMBOL) VALUES
(2,'\cTAKES Modifiers\PATIENT_VALID\',	'PATIENT_VALID', 'N', 'RA', 'CUSTOM:PATIENT_VALID:',
null, 'MODIFIER_CD', 'MODIFIER_DIMENSION', 'MODIFIER_PATH',	'T', 'LIKE',
'\PATIENT_VALID\', null, '\cTAKES Modifiers\PATIENT_VALID\', '04-DEC-2014', 'cTAKES_MODIFIERS', null, '20000',
'\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%', null, '\cTAKES Modifiers\', 'PATIENT_VALID')
INTO I2B2METADATA.I2B2 (C_HLEVEL, C_FULLNAME, C_NAME, C_SYNONYM_CD, C_VISUALATTRIBUTES, C_BASECODE,
C_METADATAXML, C_FACTTABLECOLUMN, C_TABLENAME, C_COLUMNNAME, C_COLUMNDATATYPE, C_OPERATOR,
C_DIMCODE, C_COMMENT, C_TOOLTIP, UPDATE_DATE, SOURCESYSTEM_CD, VALUETYPE_CD, I2B2_ID,
M_APPLIED_PATH, M_EXCLUSION_CD, C_PATH, C_SYMBOL) VALUES
(2,'\cTAKES Modifiers\CONCEPT_VALIDATED\',	'CONCEPT_VALIDATED', 'N', 'RA', 'CUSTOM:CONCEPT_VALIDATED:',
null, 'MODIFIER_CD', 'MODIFIER_DIMENSION', 'MODIFIER_PATH',	'T', 'LIKE',
'\CONCEPT_VALIDATED\', null, '\cTAKES Modifiers\CONCEPT_VALIDATED\', '04-DEC-2014', 'cTAKES_MODIFIERS', null, '20000',
'\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%', null, '\cTAKES Modifiers\', 'CONCEPT_VALIDATED')
;

/* Default initial setting for CUSTOM:OBSERVATION_VALID modifier based on negative polarity */
/* Note: Run only once (adds new rows each time */
INSERT INTO OBSERVATION_FACT 
SELECT ENCOUNTER_NUM,PATIENT_NUM,CONCEPT_CD,PROVIDER_ID,START_DATE,'CUSTOM:OBSERVATION_VALID:','T','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,SYSDATE,SYSDATE,'SNOMED_DEC3',NULL,INSTANCE_NUM,OBSERVATION_BLOB FROM OBSERVATION_FACT WHERE MODIFIER_CD='CUSTOM:POLARITY:' and tval_char='1';

INSERT INTO OBSERVATION_FACT 
SELECT ENCOUNTER_NUM,PATIENT_NUM,CONCEPT_CD,PROVIDER_ID,START_DATE,'CUSTOM:OBSERVATION_VALID:','T','-1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,SYSDATE,SYSDATE,'SNOMED_DEC3',NULL,INSTANCE_NUM,OBSERVATION_BLOB FROM OBSERVATION_FACT WHERE MODIFIER_CD='CUSTOM:POLARITY:' and tval_char='-1';

/* Default initial setting for CUSTOM:OBSERVATION_INVALID_REASON modifier based on negative polarity */
/* Note: Run only once (adds new rows each time */
INSERT INTO OBSERVATION_FACT
SELECT ENCOUNTER_NUM,PATIENT_NUM,CONCEPT_CD,PROVIDER_ID,START_DATE,'CUSTOM:OBSERVATION_INVALID_REASON:','T','Negative Polarity',NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,SYSDATE,SYSDATE,'SNOMED_DEC3',NULL,INSTANCE_NUM,OBSERVATION_BLOB FROM OBSERVATION_FACT WHERE MODIFIER_CD='CUSTOM:OBSERVATION_VALID:' and tval_char='-1';

/* Stored Procedure for generating the PATIENT_VALID modifier */
/* Note: Run only once (adds new rows each time */
create or replace PROCEDURE "PATIENT_VALID_MODIFIER" AS
PAT_NUM NUMBER;
CON_CD VARCHAR2(1000);
PAT_NUM1 NUMBER;
CON_CD1 VARCHAR2(1000);
FLAG NUMBER :=0;
BEGIN

for rec1 in(select distinct patient_num,concept_cd from I2B2DEMODATA.OBSERVATION_FACT WHERE MODIFIER_CD='CUSTOM:OBSERVATION_VALID:' and tval_char='1')
LOOP
PAT_NUM := rec1.patient_num;
CON_CD := rec1.concept_cd;
INSERT/*+ APPEND NOLOGGING */ INTO OBSERVATION_FACT values(null,PAT_NUM,CON_CD,0,null,'CUSTOM:PATIENT_VALID:','T','1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,SYSDATE,SYSDATE,'SNOMED_DEC3',NULL,-1,null);
commit;
end loop;
for rec in(select distinct patient_num,concept_cd from I2B2DEMODATA.OBSERVATION_FACT WHERE CONCEPT_CD LIKE 'SNO:%')
LOOP
PAT_NUM := rec.patient_num;
CON_CD := rec.concept_cd;
for rec1 in(select distinct patient_num,concept_cd from I2B2DEMODATA.OBSERVATION_FACT WHERE concept_cd like 'SNO:%' and MODIFIER_CD='CUSTOM:PATIENT_VALID:' and tval_char='1')
LOOP
PAT_NUM1 := rec1.patient_num;
CON_CD1 := rec1.concept_cd;
  if (PAT_NUM = PAT_NUM1 AND CON_CD=CON_CD1) THEN
FLAG := 1;
EXIT WHEN FLAG =1;
end if;
end loop;
if flag = 0 then
INSERT/*+ APPEND NOLOGGING */ INTO OBSERVATION_FACT values(null,PAT_NUM,CON_CD,0,null,'CUSTOM:PATIENT_VALID:','T','-1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,SYSDATE,SYSDATE,SYSDATE,'SNOMED_DEC3',NULL,-1,null);
commit;
END IF;
flag :=0;
END LOOP;

  NULL;
END;

/* Call PATIENT_VALID_MODIFIER to set up initial setting for PATIENT_VALID */
/* Note: Run only once (adds new rows each time */
call PATIENT_VALID_MODIFIER();

/**
*
* PATIENT_VALID_FOR_CONCEPT - updates the PATIENT_VALID modifier for a given concept
*
*//

create or replace PROCEDURE PATIENT_VALID_FOR_CONCEPT (MY_CONCEPT_CD IN VARCHAR2) AS 

cnt INTEGER;
valid VARCHAR2(2);

BEGIN

FOR x IN (
  select distinct(PATIENT_NUM) from I2B2DEMODATA.OBSERVATION_FACT where CONCEPT_CD=MY_CONCEPT_CD and MODIFIER_CD='CUSTOM:OBSERVATION_VALID:' 
)

LOOP

select count(*) into cnt from I2B2DEMODATA.OBSERVATION_FACT where PATIENT_NUM=x.PATIENT_NUM and CONCEPT_CD=MY_CONCEPT_CD and MODIFIER_CD='CUSTOM:OBSERVATION_VALID:' and TVAL_CHAR='1';

if cnt > 0 then
valid := '1';
ELSE
valid := '-1';
END IF;

MERGE INTO I2B2DEMODATA.OBSERVATION_FACT obsf
USING (
  SELECT x.PATIENT_NUM PATIENT_NUM, MY_CONCEPT_CD CONCEPT_CD, 'CUSTOM:PATIENT_VALID:' MODIFIER_CD from dual
) u
ON (u.PATIENT_NUM = obsf.PATIENT_NUM and u.CONCEPT_CD = obsf.CONCEPT_CD and u.MODIFIER_CD = obsf.MODIFIER_CD)
WHEN MATCHED THEN 
UPDATE SET obsf.TVAL_CHAR = valid
WHEN NOT MATCHED THEN 
INSERT (PROVIDER_ID, PATIENT_NUM, CONCEPT_CD, INSTANCE_NUM, MODIFIER_CD, VALTYPE_CD, TVAL_CHAR) VALUES (0, x.PATIENT_NUM, MY_CONCEPT_CD, 1, 'CUSTOM:PATIENT_VALID:', 'T', valid);

commit;

END LOOP;

END;


/**
*
* PATIENT_COUNT_FOR_CONCEPT - updates the patient count in the NodeMetaData table for a given concept
*
**/
create or replace PROCEDURE PATIENT_COUNT_FOR_CONCEPT (MY_CONCEPT_CD IN VARCHAR2) AS 

cnt INTEGER;

BEGIN

select count(distinct(PATIENT_NUM)) into cnt from I2B2DEMODATA.OBSERVATION_FACT
where CONCEPT_CD=MY_CONCEPT_CD
and MODIFIER_CD='CUSTOM:OBSERVATION_VALID:' 
and TVAL_CHAR='1';

MERGE INTO I2B2DEMODATA.NODE_METADATA nm
USING (
  SELECT CONCEPT_PATH, SUBSTR(CONCEPT_PATH,0,INSTR(CONCEPT_PATH,'\',-2)) PARENT_CONCEPT_PATH, 'PATIENT_COUNT' TYPE from CONCEPT_DIMENSION where CONCEPT_CD=MY_CONCEPT_CD
) u
ON (u.CONCEPT_PATH = nm.CONCEPT_PATH and u.PARENT_CONCEPT_PATH = nm.PARENT_CONCEPT_PATH and u.TYPE = nm.TYPE)
WHEN MATCHED THEN 
UPDATE SET nm.VALUE = cnt
WHEN NOT MATCHED THEN 
INSERT (CONCEPT_PATH, PARENT_CONCEPT_PATH, VALUE, TYPE) VALUES (u.CONCEPT_PATH, u.PARENT_CONCEPT_PATH, u.TYPE, cnt);

commit;

END;


