--------------------------------------------------------
--  DDL for Procedure DROPSYN
--------------------------------------------------------
set define off;

  CREATE OR REPLACE PROCEDURE "TM_CZ"."DROPSYN" IS
 CURSOR s_cur IS
 SELECT synonym_name
 FROM user_synonyms;

 RetVal  NUMBER;
 sqlstr  VARCHAR2(200); 
BEGIN
  FOR s_rec IN s_cur LOOP
    sqlstr := 'DROP SYNONYM ' || s_rec.synonym_name;

    EXECUTE IMMEDIATE sqlstr;
    COMMIT;
  END LOOP; 
END dropsyn;

 
 
 
 
 
 
 

/
