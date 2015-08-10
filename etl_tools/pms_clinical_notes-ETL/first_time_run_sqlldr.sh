#!/bin/sh
echo "Please enter the full path of the directory where the export of Clinical Notes have been unzipped (sqlldr will perform its operation in that directory also mentioned in loader.txt if not change the directory in loader.txt)"
cd /opt/data/PMS_DATA/export_pms_clinical_notes_july13/
rm all_files.txt
cat *output.txt >> all_files.txt
sqlplus username/xxx@SID <<EOF
@/opt/scripts/PMS_DN/clinical_notes/final/staging_tables.sql;
truncate table "TM_LZ"."Export_PMS_Clinical_Notes";
exit; 
EOF
echo "truncated table"
echo "Now in directory: ${PWD}"
sqlldr username/xxx@SID control=loader.txt DIRECT=TRUE
if [ $? -ne 0 ]
then 
   echo "Error! SQL Loader failed" >> ${loader.log}
exit 1
fi
echo "sql loader completed operation"
sqlplus username/xxx@SID  <<EOF
CLINICAL_NOTES_QC();
EXIT;
EOF
