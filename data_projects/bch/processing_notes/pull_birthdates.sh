/usr/bin/time -v sqlplus -s biomart_user/dwtst@BCH_DWTST<<EOF

set term off 
set colsep ,
set pagesize 50000
set heading on   
set trimspool on
set linesize 300
spool query_results.csv

SELECT PD.PATIENT_NUM,PD.BIRTH_DATE 
FROM TM_WZ.DISTINCT_PATIENTS DP
INNER JOIN TM_LZ.PATIENT_DIMENSION_I2B2_MTM PD ON PD.PATIENT_NUM = DP.PATIENT_NUM;

spool off
exit;

