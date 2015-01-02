--Free MB for tablespaces.
select b.tablespace_name, tbs_size SizeMB, a.free_space FreeMB
from  (select tablespace_name, round(sum(bytes)/1024/1024 ,2) as free_space
       from dba_free_space
       group by tablespace_name) a,
      (select tablespace_name, sum(bytes)/1024/1024 as tbs_size
       from dba_data_files
       group by tablespace_name) b
where a.tablespace_name(+)=b.tablespace_name
AND a.tablespace_name IN ('DEAPP','I2B2_DATA','BIOMART','SEARCHAPP','TRANSMART','TEMP');   

--Size of database components (Tables, Indexes, Partitions) in MB.
SELECT * FROM
(
SELECT segment_name table_name, owner, TRUNC(bytes/1024/1024), 'TABLE' TYPE
 FROM dba_segments
 WHERE segment_type = 'TABLE'
 AND owner in ('I2B2DEMODATA', 'I2B2METADATA', 'TRANSMART', 'SEARCHAPP', 'DEAPP', 'BIOMART')
  AND bytes/1024/1024 > 10  
  
 UNION ALL
 
 
 SELECT segment_name table_name, owner, TRUNC(bytes/1024/1024), 'TABLE PARTITION'
 FROM dba_segments
 WHERE segment_type = 'TABLE PARTITION' 
 AND owner in ('I2B2DEMODATA', 'I2B2METADATA', 'TRANSMART', 'SEARCHAPP', 'DEAPP')
  AND bytes/1024/1024 > 10 
  
  UNION ALL
  
 SELECT i.INDEX_NAME, i.owner, TRUNC(s.bytes/1024/1024), 'INDEX'
 FROM dba_indexes i, dba_segments s
 WHERE s.segment_name = i.index_name
 AND   s.owner = i.owner
 AND   s.segment_type = 'INDEX'
 AND I.owner in ('I2B2DEMODATA', 'I2B2METADATA', 'TRANSMART', 'SEARCHAPP', 'DEAPP')
 AND bytes/1024/1024 > 10 

 UNION ALL
 
 SELECT s.segment_name, l.owner, TRUNC(s.bytes/1024/1024), 'LOBSEGMENT'
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.segment_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBSEGMENT'
 AND L.owner in ('I2B2DEMODATA', 'I2B2METADATA', 'TRANSMART', 'SEARCHAPP', 'DEAPP')
 AND bytes/1024/1024 > 10  
 
 UNION ALL
 
 SELECT s.segment_name, l.owner, TRUNC(s.bytes/1024/1024), 'LOBINDEX'
 FROM dba_lobs l, dba_segments s
 WHERE s.segment_name = l.index_name
 AND   s.owner = l.owner
 AND   s.segment_type = 'LOBINDEX'
 AND L.owner in ('I2B2DEMODATA', 'I2B2METADATA')
 AND bytes/1024/1024 > 10
 )
 ORDER BY 4, 3 DESC;
 
--Tables useful for determining size of objects/data files. 
SELECT * FROM V$TABLESPACE;
SELECT * FROM V$DATAFILE;
select * from v$tempfile;
SELECT * FROM DBA_TEMP_FILES;
SELECT * FROM DBA_TABLESPACES;
 