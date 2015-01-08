/opt/data-integration/kitchen.sh \
rep=Y \
-file=/opt/tranSMART-ETL/Kettle-GPL/Kettle-ETL/create_clinical_data.kjb \
-log=../logs/load_clinical_data.log \
-level=Basic \
-param:COLUMN_MAP_FILE='PMSREGISTRY_columns.txt' \
-param:DATA_LOCATION='/opt/data/testdata/working/PMSREGISTRY_DEC29/' \
-param:STUDY_ID=PMSREGISTRY \
-param:TOP_NODE='\PMS_DN\01 PMS Registry (Patient Reported Outcomes)\01 PMS Ontology\' \
-param:SORT_DIR='/opt/data/testdata/working/PMSREGISTRY_DEC29/' \
-param:LOAD_TYPE=I 
