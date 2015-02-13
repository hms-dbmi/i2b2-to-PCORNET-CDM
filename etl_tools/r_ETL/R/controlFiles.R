# rm(list=ls())
# 
# source('../MyPheWAS/R/getConfig.R')
# # source('../MyPheWAS/R/toLog.R')
# # source('R/getNewIdentifiers.R')
config <- getConfig('config_file')
# # require(data.table)
# # require(dplyr)
# # require(reshape2)
# conf = config
# # require(foreach)
# # require(doSNOW)
# #
# # ncore = 2

conf = config

generateControlFiles <- function(inFileName, outFileName, dbTable, columns, base_path = config$DATA_BASE_PATH ) {
  extension = conf$DATA_FILE_EXTENSION
  
  if (!file.exists(paste0(base_path,"scripts"))) {
    dir.create(paste0(base_path,"scripts"))
  }
  con <-file(paste0(base_path,"scripts/load_",outFileName,"_data.sh"))
  cat(paste0('/usr/bin/time -v sqlldr ','tm_lz/',conf$db_pass,'@','BCH_',conf$db_name,
             ' control=',base_path,'control_files/',outFileName,'.ctl',
             ' log=',base_path,'log_files/',outFileName,'.log\n',"exit 0"),file=con)
  close(con)
  Sys.chmod(paste0(base_path,"scripts/load_",outFileName,"_data.sh"),mode = '755')

  if (!file.exists(paste0(base_path,"control_files"))) {
    dir.create(paste0(base_path,"control_files"))
  }

  columns <- gsub('_DATE\"', '_DATE\" DATE "yyyy-MM-dd HH24:MI:ss"', columns)
  columns <- gsub('BIRTH_DATE\" DATE "yyyy-MM-dd HH24:MI:ss"','BIRTH_DATE\" DATE "yyyy-MM-dd"',columns)
  columns <- gsub('DEATH_DATE\" DATE "yyyy-MM-dd HH24:MI:ss"','DEATH_DATE\" DATE "yyyy-MM-dd"',columns)

  con <- file(paste0(base_path,"/control_files/",outFileName,".ctl"))
  cat(paste0("OPTIONS (DIRECT=TRUE, SKIP=1) UNRECOVERABLE \n",
             "load data\n",
             "infile '",base_path,"data/i2b2_load_tables/",inFileName,"'\n",
             "APPEND into table ", dbTable,"\n",
             'fields terminated by "\\t" TRAILING NULLCOLS',"\n",
             '(',columns,')'),file=con)
  close(con)
  if(!file.exists(paste0(base_path,"log_files"))){
    dir.create(paste0(base_path,"log_files"))
  }
#   if(!file.exists(paste0(base_path,"log/",outFileName,'.log'))){
#     dir.create(paste0(base_path,"log/",outFileName,'.log'))
#   }

}

generateControlFiles(inFileName = 'concept_dimension.dat',
                     outFileName = 'concept_dimension',
                     dbTable = "I2B2DEMODATA.CONCEPT_DIMENSION",
                     columns = config$CONCEPT_DIMENSION_COLUMNS)

generateControlFiles(inFileName = 'concept_count.dat',
                     outFileName = 'concept_count',
                     dbTable = "I2B2DEMODATA.CONCEPT_COUNTS",
                     columns = config$CONCEPT_COUNT_COLUMNS)

generateControlFiles(inFileName = 'patient_dimension.dat',
                     outFileName = 'patient_dimension',
                     dbTable = "I2B2DEMODATA.PATIENT_DIMENSION",
                     columns = config$PATIENT_DIMENSION_COLUMNS )

generateControlFiles(inFileName = 'patient_trial.dat',
                     outFileName = 'patient_trial',
                     dbTable = "I2B2DEMODATA.PATIENT_TRIAL",
                     columns = config$PATIENT_TRIAL_COLUMNS )

generateControlFiles(inFileName = 'i2b2.dat',
                     outFileName = 'i2b2',
                     dbTable = "I2B2METADATA.I2B2",
                     columns = gsub('C_METADATAXML\"','C_METADATAXML\" CHAR(10000)',config$I2B2_COLUMNS))

generateControlFiles(inFileName = 'patient_mapping.dat',
                     outFileName = 'patient_mapping',
                     dbTable = "I2B2DEMODATA.PATIENT_MAPPING",
                     columns = config$PATIENT_MAPPING_COLUMNS)


  generateControlFiles(inFileName = 'observation_fact.dat',
                       outFileName = 'observation_fact',
                       dbTable = "I2B2DEMODATA.OBSERVATION_FACT",
                       columns = config$OBSERVATION_FACTS_COLUMNS)


  generateControlFiles(inFileName = 'concepts_folders_patients.dat',
                       outFileName = 'concepts_folders_patients',
                       dbTable = "I2B2DEMODATA.CONCEPTS_FOLDERS_PATIENTS",
                       columns = config$CONCEPTS_FOLDER_PATIENTS_COLUMNS)


script_list <- list.files(paste0(config$DATA_BASE_PATH,'scripts'), 'load_')

generateMasterScript <- function(scripts_list, base_path = config$DATA_BASE_PATH) {
  con <-file(paste0(base_path,"scripts/masterScript.sh"),open='w')
  close(con)

  con <-file(paste0(base_path,"scripts/masterScript.sh"),open='a')
  writeLines("#!/bin/bash",con)
  #close(con)

  for (script in script_list) {
    writeLines(paste0("echo Executing script: ",script),con)
    writeLines(paste0("./",script),con)
  }
  writeLines("exit 0",con)
  close(con)
  Sys.chmod(paste0(base_path,"scripts/masterScript.sh"),mode = '755')

}
generateMasterScript(script_list)


