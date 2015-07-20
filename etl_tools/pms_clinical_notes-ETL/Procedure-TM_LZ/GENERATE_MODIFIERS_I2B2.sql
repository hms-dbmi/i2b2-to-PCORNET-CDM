create or replace PROCEDURE                                                                                                                                                                                      GENERATE_MODIFIERS_I2B2
(
top_node 	IN VARCHAR2
)
AS

BEGIN
FOR rec IN (SELECT * FROM I2B2_TEMP)
LOOP
DBMS_OUTPUT.ENABLE(1000000);
if (SUBSTR(rec.c_fullname,1,INSTR(rec.c_fullname,'\',-2,1)) = top_node and rec.c_synonym_cd='N') then
insert into i2b2metadata.i2b2 values(1,'\cTAKES Modifiers\','cTAKES Modifiers','N','OAE',null,'CTAKES_MODIFIERS',null,'MODIFIER_CD','MODIFIER_DIMENSION','MODIFIER_PATH','T','LIKE','\CTAKES Modifiers\',null,'cTAKES Modifiers',sysdate,null,null,'CTAKES_MODIFIERS',null,null,rec.c_fullname||'%',null,'\cTAKES Modifiers\','CTAKES Modifiers');
commit;
END if;
END LOOP;
NULL;
END GENERATE_MODIFIERS_I2B2;