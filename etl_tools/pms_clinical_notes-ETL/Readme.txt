1. During first export of Clinical notes run procedure first_time_run_sqlldr.sh (In the procedure modify the directory name where you have stored fresh export of clinical notes). This also creates temp tables in staging _tables.sql

2. To load SNOMED, ICD9CM, MeSH delete the previous data and run upload_clinical-notes.sh with parameters -> SAB (Ontology), TOP_NODE, STUDY_ID, FACT_SET, UMLS SCHEMA AND TABLE NAME, BIOPORTAL I2B2 SCHEMA AND TABLE NAME

3. Rebuild index using script index_rebuild_prod.sh

4. RUN THE SCRIPT FILE upload_clinical-notes.sh for each and every ontology and repeat step 4

5. Delete temp tables using script delete_temp_tables.sh

6. Repeat from step 1 for each fresh clinical notes export