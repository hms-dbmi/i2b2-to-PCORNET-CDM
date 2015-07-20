#!/bin/bash
echo "Before proceeding delete old data from tables i2b2, concept_dimension, observation_fact, node_metadata"
VAR_1='SNOMEDCT_US'
echo "Ontology entered is: $VAR_1"
top_node='\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED';
echo "The top node is: $top_node"
study_id='PMSTEST'
echo "The study id is: $study_id"
FactSet='HMS_PMS_NLP_SNO'
umls_table='UMLS_TOP5_2014AB.MRCONSO'
echo "The UMLS table is : $umls_table"
i2b2_full_table='BIOPORTAL_I2B2.I2B2_SNOMED_FULL'
echo "The full i2b2 table is: $i2b2_full_table"
start=`date +%s`
sqlplus username/xxx@SID <<EOF
exec I2B2_LOAD_CLINICAL_NOTES('$VAR_1','$top_node','$study_id','$FactSet','$umls_table','$i2b2_full_table');
exit;
EOF
end=`date +%s`
runtime=$((end-start))
echo "Exit shell script, Load Completed for ${VAR_1} Load time:${runtime}"
sh ./index_rebuild_prod.sh
VAR_1='HPO'
echo "Ontology entered is: $VAR_1"
top_node='\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\02 HPO';
echo "The top node is: $top_node"
study_id='PMSTEST'
echo "The study id is: $study_id"
FactSet='HMS_PMS_NLP_HPO'
umls_table='NULL'
echo "The UMLS table is : $umls_table"
i2b2_full_table='BIOPORTAL_I2B2.I2B2_HPO_FULL'
echo "The full i2b2 table is: $i2b2_full_table"
start=`date +%s`
sqlplus username/xxx@SID  <<EOF
exec I2B2_LOAD_CLINICAL_NOTES('$VAR_1','$top_node','$study_id','$FactSet','$umls_table','$i2b2_full_table');
exit;
EOF
end=`date +%s`
runtime=$((end-start))
echo "Exit shell script, Load Completed for ${VAR_1} Load time:${runtime}"
sh ./index_rebuild_prod.sh
VAR_1='ICD9CM'
echo "Ontology entered is: $VAR_1"
top_node='\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\03 ICD9CM';
echo "The top node is: $top_node"
study_id='PMSTEST'
echo "The study id is: $study_id"
FactSet='HMS_PMS_NLP_IC9'
umls_table='UMLS_TOP5_2014AB.MRCONSO'
echo "The UMLS table is : $umls_table"
i2b2_full_table='BIOPORTAL_I2B2.I2B2_ICD9CM_FULL'
echo "The full i2b2 table is: $i2b2_full_table"
start=`date +%s`
sqlplus username/xxx@SID <<EOF
exec I2B2_LOAD_CLINICAL_NOTES('$VAR_1','$top_node','$study_id','$FactSet','$umls_table','$i2b2_full_table');
exit;
EOF
end=`date +%s`
runtime=$((end-start))
echo "Exit shell script, Load Completed for ${VAR_1} Load time:${runtime}"
sh ./index_rebuild_prod.sh
VAR_1='ICD10CM'
echo "Ontology entered is: $VAR_1"
top_node='\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\04 ICD10CM';
echo "The top node is: $top_node"
study_id='PMSTEST'
echo "The study id is: $study_id"
FactSet='HMS_PMS_NLP_ICX'
umls_table='UMLS_TOP5_2014AB.MRCONSO'
echo "The UMLS table is : $umls_table"
i2b2_full_table='BIOPORTAL_I2B2.I2B2_ICD10CM_FULL'
echo "The full i2b2 table is: $i2b2_full_table"
start=`date +%s`
sqlplus username/xxx@SID  <<EOF
exec I2B2_LOAD_CLINICAL_NOTES('$VAR_1','$top_node','$study_id','$FactSet','$umls_table','$i2b2_full_table');
exit;
EOF
end=`date +%s`
runtime=$((end-start))
echo "Exit shell script, Load Completed for ${VAR_1} Load time:${runtime}"
sh ./index_rebuild_prod.sh
VAR_1='MSH'
echo "Ontology entered is: $VAR_1"
top_node='\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\05 MeSH';
echo "The top node is: $top_node"
study_id='PMSTEST'
echo "The study id is: $study_id"
FactSet='HMS_PMS_NLP_MSH'
umls_table='UMLS_TOP5_2014AB.MRCONSO'
echo "The UMLS table is : $umls_table"
i2b2_full_table='BIOPORTAL_I2B2.I2B2_MSH_FULL'
echo "The full i2b2 table is: $i2b2_full_table"
start=`date +%s`
sqlplus username/xxx@SID  <<EOF
exec I2B2_LOAD_CLINICAL_NOTES('$VAR_1','$top_node','$study_id','$FactSet','$umls_table','$i2b2_full_table');
exit;
EOF
end=`date +%s`
runtime=$((end-start))
echo "Exit shell script, Load Completed for ${VAR_1} Load time:${runtime}"
sh ./index_rebuild_prod.sh
VAR_1='NDFRT'
echo "Ontology entered is: $VAR_1"
top_node='\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\06 NDFRT';
echo "The top node is: $top_node"
study_id='PMSTEST'
echo "The study id is: $study_id"
FactSet='HMS_PMS_NLP_NDT'
umls_table='UMLS_TOP5_2014AB.MRCONSO'
echo "The UMLS table is : $umls_table"
i2b2_full_table='BIOPORTAL_I2B2.I2B2_NDFRT_FULL'
echo "The full i2b2 table is: $i2b2_full_table"
start=`date +%s`
sqlplus username/xxx@SID  <<EOF
exec I2B2_LOAD_CLINICAL_NOTES('$VAR_1','$top_node','$study_id','$FactSet','$umls_table','$i2b2_full_table');
exit;
EOF
end=`date +%s`
runtime=$((end-start))
echo "Exit shell script, Load Completed for ${VAR_1} Load time:${runtime}"
sh ./index_rebuild_prod.sh