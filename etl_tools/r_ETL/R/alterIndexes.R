source(paste0(r_scripts_path,'getConfig.R'))
source(paste0(r_scripts_path,'toLog.R'))
source(paste0(r_scripts_path,'JDBCConnect.R'))
source(paste0(r_scripts_path,'SendQueries.R'))

conf <- getConfig('config_file')

query_list <- 
  c("ALTER INDEX I2B2DEMODATA.CONCEPTS_FOLDERS_PATS_IDX1 UNUSABLE",
     "DROP INDEX I2B2DEMODATA.OB_FACT_PK",
     "DROP INDEX I2B2METADATA.i2b2_fullname_text",
     "DROP INDEX cd_concept_path_text",
     "DROP INDEX I2B2METADATA.I2B2_INDEX")

SendQueries(conf,query_list)
