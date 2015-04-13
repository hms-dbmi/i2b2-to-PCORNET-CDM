
drop INDEX I2B2METADATA.i2b2_fullname_text;
drop INDEX I2B2DEMODATA.cd_concept_path_text;
GRANT CTXAPP TO i2b2metadata;
GRANT CTXAPP TO i2b2demodata;
CREATE INDEX I2B2METADATA.i2b2_fullname_text ON i2b2metadata.i2b2(c_fullname) INDEXTYPE IS CTXSYS.CONTEXT;
CREATE INDEX I2B2DEMODATA.cd_concept_path_text ON i2b2demodata.concept_dimension(concept_path) INDEXTYPE IS CTXSYS.CONTEXT;
REVOKE CTXAPP FROM i2b2metadata;
REVOKE CTXAPP FROM i2b2demodata;
alter INDEX I2B2METADATA.I2B2_IDX1_PART rebuild;
ALTER INDEX I2B2METADATA.I2B2_INDEX1_PART REBUILD;
ALTER INDEX I2B2METADATA.I2B2_INDEX2_PART REBUILD;
ALTER INDEX I2B2METADATA.I2B2_INDEX3_PART REBUILD;
ALTER INDEX I2B2METADATA.I2B2_INDEX4_PART REBUILD;
ALTER INDEX I2B2METADATA.I2B2_C_HLEVEL_BASECODE_PART REBUILD;
ALTER INDEX I2B2METADATA.META_APPLIED_PATH_I2B2_PART REBUILD;
ALTER INDEX I2B2DEMODATA.CONCEPT_COUNTS_INDEX1 REBUILD;
ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_1 REBUILD;
ALTER INDEX I2B2DEMODATA.IDX_OB_FACT_2 REBUILD;
ALTER INDEX I2B2DEMODATA.FACT_MOD_PAT_ENC REBUILD;
ALTER INDEX I2B2DEMODATA.FACT_CNPT_PAT_ENCT_IDX REBUILD;
ALTER INDEX I2B2DEMODATA.PD_IDX_ALLPATIENTDIM REBUILD;
ALTER INDEX I2B2DEMODATA.PATIENT_DIMENSION_INDEX1 REBUILD;
ALTER INDEX I2B2DEMODATA.PATIENT_TRIAL_INDEX1 REBUILD;
ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM3 REBUILD;
ALTER INDEX I2B2DEMODATA.IDX_CONCEPT_DIM_1 REBUILD;
ALTER INDEX I2B2METADATA.I2B2_S_IDX1 REBUILD;
