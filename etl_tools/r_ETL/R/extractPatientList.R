### Warning: special columns (except for SUBJECT_ID) must appear in only 1 file
### Currently: special columns are SUBJECT_ID, RACE, SEX, AGE, DOB, DEATH, FAMILY, ROLE


source('../MyPheWAS/R/getConfig.R')
source('../MyPheWAS/R/toLog.R')
source('R/createDataFrameFromColumns.R')
config <- getConfig('config_file')
require(data.table)
require(dplyr)
# PatientDimensionColumnList = c('PATIENT_NUM','VITAL_STATUS_CD','BIRTH_DATE','DEATH_DATE','SEX_CD','AGE_IN_YEARS_NUM',
#                                'LANGUAGE_CD','RACE_CD','MARITAL_STATUS_CD','RELIGION_CD','ZIP_CD','STATECITYZIP_PATH',
#                                'UPDATE_DATE','DOWNLOAD_DATE','IMPORT_DATE','SOURCESYSTEM_CD','UPLOAD_ID','PATIENT_BLOB',
#                                'INCOME_CD')

config$BASE_PATH
extractPatientList <- function(conf = config) {
  require(data.table)
  start <- Sys.time()
  # load master_mapping
  if (!file.exists(conf$MAPPING_FILE_DIRECTORY)) {stop(paste('Directory not found: ',conf$MAPPING_FILE_DIRECTORY,'does not exit'))}
  masterMappingFile <- paste0(conf$MAPPING_FILE_DIRECTORY,'master_mapping')

  newColumns <- c('SUBJECT_ID','SEX_CD', 'RACE_CD', 'AGE_IN_YEARS_NUM', 'BIRTH_DATE', 'DEATH_DATE', 'FAMILY', 'ROLE')

  if (!file.exists(masterMappingFile)) {stop(paste('Config File not found:',masterMappingFile,'does not exit'))}
  masterMapping <- read.table(masterMappingFile, sep = '\t', header = T, as.is=T)
  nFile <- nrow(masterMapping)

  # ----- loop over every row of master mapping
  for(i in 1:nrow(masterMapping)) {

    # ----- load mapping file
    mappingFileName <- masterMapping$mappingfile[i]
    mappingFileFullPath <- paste0(conf$MAPPING_FILE_DIRECTORY,mappingFileName)
    if (!file.exists(mappingFileFullPath)) {stop(paste('Config File not found:', mappingFileFullPath,'does not exit'))}

    toLog(paste0('Patient Dimension - Processing Mapping File: ',mappingFileName))

    mappingFile <- read.table(paste0(conf$MAPPING_FILE_DIRECTORY,mappingFileName),sep = '\t', header = T, as.is=T)
    # ------

    # ------ find special columns in mapping file
    column <- list()
    column$id <- mappingFile[mappingFile$PATH == 'SUBJECT_ID',1]
    column$sex <- mappingFile[mappingFile$PATH == 'SEX_CD',1]
    column$race <- mappingFile[mappingFile$PATH == 'RACE_CD',1]
    column$age <- mappingFile[mappingFile$PATH == 'AGE_IN_YEARS_NUM',1]
    column$DOB <- mappingFile[mappingFile$PATH == 'BIRTH_DATE',1]
    column$death <- mappingFile[mappingFile$PATH == 'DEATH_DATE',1]
    column$family <- mappingFile[mappingFile$PATH == 'FAMILY',1]
    column$role <- mappingFile[mappingFile$PATH == 'ROLE',1]
    columns <- c(column$id,column$sex,column$race,column$age,column$DOB,column$death,column$family,column$role)
    # -------

    # ------- Load data file
    dataFileName <- gsub('.map','',mappingFileName)
    dataFileFullPath <- paste0(conf$BASE_PATH,conf$PATIENT_DATA_DIRECTORY,dataFileName)

    if (!file.exists(dataFileFullPath)) {stop(paste('Config File not found:', dataFileFullPath,'does not exit'))}
    f <- fread(paste0(conf$BASE_PATH,conf$PATIENT_DATA_DIRECTORY,dataFileName))
    toLog(paste0('Patient Dimension - Processing Data File: ',dataFileName))
    # -------

    # ------- extract special columns from data file
    temp <- (f[,names(f) %in% columns,with=F])

    # ------- renames columns to standard names
    for (i in 1:length(column)){
      if (length(unlist(column[i]))>0) { setnames(temp,unlist(column[i]),newColumns[i]) }
    }
    # -------

    # ------- merge new patients to patientList
    if (!exists('patientList')) {
      patientList <- temp
    } else {
      patientList <-merge(as.data.frame(patientList),as.data.frame(temp), all.x=T, all.y =T, by = 'SUBJECT_ID')
    }
    # -------
  }

  time <- Sys.time() - start

  toLog(paste0('Patient Dimension - Retrieved ',nrow(patientList),' patients from ',nFile,'files in'),time)

  return(patientList)

}

patients <- extractPatientList(config)

# ------ get existing patients from DB (patient_mapping)
source('R/getPatientSubjectHash.R')
patientHash <- getPatientSubjectHash()
existingPatients <- merge(as.data.frame(patients), patientHash, by.x = 'SUBJECT_ID', by.y = 'PATIENT_IDE')
# ------



findNewPatients <- function(patients, patientHash) {
  source('R/getNewIdentifiers.R')
  # ------ extract new patients
  newPatients <- patients[!(patients$SUBJECT_ID %in% existingPatients$SUBJECT_ID),]

  if(nrow(newPatients) > 0) {
    # ------ get new identifiers for new patients
    newPatientIds <- getNewIdentifiers(numberOfIdsToGet = nrow(newPatients), nameOfSequence = 'I2B2DEMODATA.SEQ_PATIENT_NUM', conf = config)
    newPatients$PATIENT_NUM <- newPatientIds
    # ------
    # ------ map with patient data
    patientMappingData <- data.frame(PATIENT_NUM = newPatients$PATIENT_NUM,
                                     PATIENT_IDE = newPatients$SUBJECT_ID,
                                     PATIENT_IDE_SOURCE = config$FACT_SET,
                                     SOURCESYSTEM_CD = config$SOURCESYSTEM)

    setnames(newPatients, 'SUBJECT_ID', 'SOURCESYSTEM_CD')

    # ------ create the patient dimension data frame
    patientDimensionData <- createDataFrameFromColumns(config$PATIENT_DIMENSION_COLUMNS, nrow(newPatients))

    # ------ fill in data from special columns
    for (col in names(newPatients)) {
      if (col %in% names(patientDimensionData)) {
        patientDimensionData[,col] <- newPatients[,col]
      }
    }

  } else {
    # ----- if no new patients: create empty datasets
    patientMappingData <- createDataFrameFromColumns(config$PATIENT_MAPPING_COLUMNS)
    patientDimensionData <- createDataFrameFromColumns(config$PATIENT_DIMENSION_COLUMNS)

  }

  return(list(patientDimensionData = patientDimensionData,
              patientMappingData = patientMappingData, newPatients = newPatients))
}

dataFiles <- findNewPatients(patients,patientHash)


mergePatients <- function(existingPatients, newPatients) {
  setnames(existingPatients, 'SUBJECT_ID', 'SOURCESYSTEM_CD')
  if (nrow(newPatients)>0) {
    return(rbind(existingPatients,newPatients))
  } else {return(existingPatients)

  }

}

patients <- mergePatients(existingPatients, dataFiles$newPatients)

if(!file.exists('temp')){
  dir.create('temp')
}

save(patients,file='temp/patients.RData')

write.table(dataFiles$patientDimensionData,file(paste0(config$PATIENT_DIMENSION_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)
write.table(dataFiles$patientMappingData,file(paste0(config$PATIENT_MAPPING_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)

