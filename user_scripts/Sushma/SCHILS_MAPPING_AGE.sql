  create or replace PROCEDURE              SCHILS_MAPPING_AGE AS 
    age NUMBER ;
     pat_id number ;
  BEGIN
   FOR rec IN (SELECT distinct PATIENT_NUM, AGE_IN_YEARS_NUM   FROM i2b2demodata.patient_dimension where sourcesystem_cd like 'PMSREGISTRY%')
      LOOP
        age = rec.AGE_IN_YEARS_NUM;
        pat_id = rec.PATIENT_NUM;  
      DBMS_OUTPUT.ENABLE(1000000);
        if (TRUNC(age12)3) THEN
   INSERT INTO OBSERVATION_FACT VALUES(NULL,pat_id,'DEMAGE'TRUNC(age12),'@',null,'PCORNET_CDM','N','E',TRUNC(age12),'@',null,null,null,'@',null,null,null,null,'PCORNET_CDM',null,null,1,'PCORNET_CDM');
  
  ELSIF age= 0 THEN 
   INSERT INTO OBSERVATION_FACT VALUES(NULL,pat_id,'DEMAGE1mo','@',null,'PCORNET_CDM','N','E',age,'@',null,null,null,'@',null,null,null,null,'PCORNET_CDM',null,null,1,'PCORNET_CDM');
  
  else
     INSERT INTO OBSERVATION_FACT VALUES(NULL,pat_id,'DEMAGE'age'mo','@',null,'PCORNET_CDM','N','E',age,'@',null,null,null,'@',null,null,null,null,'PCORNET_CDM',null,null,1,'PCORNET_CDM');
  END IF;
  END LOOP;
insert into concept_counts
select b.c_fullname,ltrim(SUBSTR(b.c_fullname, 1,instr(b.c_fullname, '\',-1,2))),count(distinct a.patient_num)
from observation_fact a, i2b2 b where
 b.c_fullname like '\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\Age\%' and a.concept_cd=b.c_basecode
 group by b.c_fullname;

insert into concept_counts
select b.c_fullname,ltrim(SUBSTR(b.c_fullname, 1,instr(b.c_fullname, '\',-1,2))),0
from i2b2 b where
 b.c_fullname like '\PMS_DN\03 PCORNet CDM v1 -SCHILS Ontology\DEMOGRAPHIC\Age\%' and b.c_fullname not in (select concept_path from concept_counts) and b.c_hlevel in (5,6)
 group by b.c_fullname;
commit;
    NULL;
  END SCHILS_MAPPING_AGE;