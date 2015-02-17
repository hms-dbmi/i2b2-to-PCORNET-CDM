create or replace PROCEDURE COMPUTE_STATISTICS AS 
BEGIN
execute immediate('truncate table "BIOMART_USER"."COMPUTE_STATS"');
commit;
insert into biomart_user.compute_stats
select i.c_fullname as C_FULLNAME, count(distinct o.patient_num) AS DISTINCT_PATIENTS, count(distinct o.concept_cd) AS DISTINCT_CONCEPTS, count(o.concept_cd) AS NUMBER_OF_FACTS
from i2b2metadata.i2b2 i, observation_fact o, concept_dimension c
where i.c_hlevel=1 and o.concept_cd=c.concept_cd and  c.concept_path like concat(i.C_FULLNAME,'%')
 and i.c_fullname not like '\Public Studies\%'
group by i.c_fullname;
commit;

execute immediate('truncate table biomart_user.concept_stats');
commit;
insert into biomart_user.concept_stats
SELECT SOURCESYSTEM_CD, count(1) as COUNT_OF_CONCEPTS FROM CONCEPT_DIMENSION  where concept_path not like '\\Public Studies\\%' group by SOURCESYSTEM_CD;
commit;

execute immediate('truncate table biomart_user.observation_stats');
commit;
insert into biomart_user.observation_stats
SELECT DATASOURCE, count(1) as nb_observation_fact, count(distinct patient_num) as distinct_patient_num, count(distinct CONCEPT_CD) as distint_CONCEPT_CD, min(START_DATE) as min_start_date, max(START_DATE) as max_start_date FROM OBSERVATION_FACT where datasource not like  'EGP%' and datasource not like  'GSE%' group by DATASOURCE;
commit;

execute immediate('truncate table "BIOMART_USER"."SCHEMA_STATS" ');
commit;
insert into BIOMART_USER.SCHEMA_STATS 
SELECT
   owner, to_char(sum(bytes)/1024/1024/1024, '9999.999') as GB
FROM
(SELECT segment_name table_name, owner, bytes
 FROM dba_segments
 WHERE segment_type = 'TABLE'
 UNION ALL
 SELECT i.table_name, i.owner, s.bytes
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type = 'INDEX'
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, DBA_SEGMENTS s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBSEGMENT'
 UNION ALL
 SELECT l.table_name, l.owner, s.bytes
 FROM dba_lobs l, DBA_SEGMENTS s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX')
WHERE owner in ('I2B2METADATA', 'I2B2DEMODATA')
GROUP BY  owner
HAVING SUM(bytes)/1024/1024 > 10 ;-- /* Ignore really small tables */;
commit;






  NULL;
END COMPUTE_STATISTICS;