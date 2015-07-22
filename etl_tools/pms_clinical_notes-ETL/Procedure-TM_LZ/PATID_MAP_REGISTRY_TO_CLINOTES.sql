create or replace PROCEDURE                                                                                                                                                           PATID_MAP_REGISTRY_TO_CLINOTES
(
FactSet in VARCHAR2,
study_id in varchar2
)
AS 
Original_Var NUMBER;
New_Var NUMBER;
BEGIN
for rec in (SELECT distinct PATIENT_NUM,  SOURCESYSTEM_CD FROM I2B2DEMODATA.PATIENT_DIMENSION WHERE sourcesystem_cd LIKE study_id||'%')
LOOP
Original_Var := SUBSTR(rec.SOURCESYSTEM_CD,9);
New_Var := rec.PATIENT_NUM;

update TM_LZ.OBSERVATION_FACT_TEMP
set patient_num = New_Var
where sourcesystem_cd =FactSet and patient_num = Original_Var;

END LOOP;
commit;
  NULL;
END PATID_MAP_REGISTRY_TO_CLINOTES;