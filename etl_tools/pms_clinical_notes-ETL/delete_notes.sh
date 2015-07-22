sqlplus username/xxx@SID <<EOF

delete from i2b2metadata.i2b2 where SOURCESYSTEM_CD='HMS_PMS_NLP_MSH';

delete from i2b2demodata.concept_dimension where sourcesystem_cd='HMS_PMS_NLP_MSH';

delete from I2B2DEMODATA.NODE_METADATA where concept_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\05 MeSH%'

alter table i2b2demodata.observation_fact drop partition HMS_PMS_NLP_MSH;

delete from i2b2metadata.i2b2 where m_applied_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\05 MeSH%';

delete from i2b2metadata.i2b2 where SOURCESYSTEM_CD='HMS_PMS_NLP_ICX';

delete from i2b2demodata.concept_dimension where sourcesystem_cd='HMS_PMS_NLP_ICX';

delete from I2B2DEMODATA.NODE_METADATA where concept_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\04 ICD10CM\%'

alter table i2b2demodata.observation_fact drop partition HMS_PMS_NLP_ICX;

delete from i2b2metadata.i2b2 where m_applied_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\04 ICD10CM\%';

delete from i2b2metadata.i2b2 where SOURCESYSTEM_CD='HMS_PMS_NLP_NDT';

delete from i2b2demodata.concept_dimension where sourcesystem_cd='HMS_PMS_NLP_NDT';

delete from I2B2DEMODATA.NODE_METADATA where concept_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\06 NDFRT\%'

alter table i2b2demodata.observation_fact drop partition HMS_PMS_NLP_NDT;

delete from i2b2metadata.i2b2 where m_applied_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\06 NDFRT\%';

delete from i2b2metadata.i2b2 where SOURCESYSTEM_CD='HMS_PMS_NLP_HPO';

delete from i2b2demodata.concept_dimension where sourcesystem_cd='HMS_PMS_NLP_HPO';

delete from I2B2DEMODATA.NODE_METADATA where concept_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\02 HPO\%'

alter table i2b2demodata.observation_fact drop partition HMS_PMS_NLP_HPO;

delete from i2b2metadata.i2b2 where m_applied_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\02 HPO\%';

delete from i2b2metadata.i2b2 where SOURCESYSTEM_CD='HMS_PMS_NLP_SNO' ;

delete from i2b2demodata.concept_dimension where sourcesystem_cd='HMS_PMS_NLP_SNO';

alter table  i2b2demodata.observation_fact drop partition HMS_PMS_NLP_SNO;

delete from I2B2DEMODATA.NODE_METADATA where concept_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%';

delete  from i2b2metadata.i2b2 where m_applied_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\01 SNOMED\%';

delete from i2b2metadata.i2b2 where SOURCESYSTEM_CD='HMS_PMS_NLP_IC9' ;

delete from i2b2metadata.i2b2 where m_applied_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\03 ICD9CM%';

delete from i2b2demodata.concept_dimension where sourcesystem_cd='HMS_PMS_NLP_IC9';

delete from I2B2DEMODATA.NODE_METADATA where concept_path like '\DBMI\PMS_DN\02 PMS Clinical Notes (cTAKES NLP)\03 ICD9CM%';

alter table i2b2demodata.observation_fact drop partition HMS_PMS_NLP_IC9;

EXIT
EOF
echo "Deleted all Clinical Notes"
sh ./index_rebuild_prod.sh

