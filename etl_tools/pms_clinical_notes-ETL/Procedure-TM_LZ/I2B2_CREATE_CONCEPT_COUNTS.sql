create or replace PROCEDURE                                                                                                                                                                         I2B2_CREATE_CONCEPT_COUNTS AS
path varchar2(1000);
pat_num number;
enc_num number;
i number;
y number;
BEGIN

FOR rec IN (SELECT distinct encounter_num,patient_num,C_FULLNAME FROM concept_counts_temp)
LOOP
i:=i+1;
DBMS_OUTPUT.ENABLE(1000000);
path := rec.C_FULLNAME;

pat_num := rec.PATIENT_NUM;

enc_num := rec.encounter_num;
INSERT  INTO concept_counts_temp2 values(path,enc_num,pat_num);

WHILE path != '\'
LOOP
y:=y+1;
path := SUBSTR(path,1,INSTR(path,'\',-2,1));
INSERT  INTO concept_counts_temp2 values(path,enc_num,pat_num);

END LOOP;
END LOOP;
COMMIT;

NULL;
END I2B2_CREATE_CONCEPT_COUNTS;