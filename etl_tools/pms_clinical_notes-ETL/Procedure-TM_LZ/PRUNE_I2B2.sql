create or replace PROCEDURE                                                                                                                                                                                                   PRUNE_I2B2 AS
i NUMBER := 0;
y NUMBER := 0;
path varchar2(2000);
BEGIN
FOR rec IN (SELECT distinct c_fullname FROM TM_LZ.i2b2_leaves )
LOOP
i:=i+1;
DBMS_OUTPUT.ENABLE(1000000);
path := rec.C_FULLNAME;
WHILE path != '\'
LOOP
y:=y+1;
path := SUBSTR(path,1,INSTR(path,'\',-2,1));

INSERT  INTO TM_LZ.i2b2_folders_fullname values(path); 

END LOOP;

y:=0;
END LOOP;
commit;
END PRUNE_I2B2;