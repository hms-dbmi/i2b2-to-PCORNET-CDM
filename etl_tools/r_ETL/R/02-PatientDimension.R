### Warning: special columns (except for SUBJECT_ID) must appear in only 1 file
### Currently: special columns are SUBJECT_ID, RACE, SEX, AGE, DOB, DEATH, FAMILY, ROLE

# source('../MyPheWAS/R/getConfig.R')
# source('../MyPheWAS/R/toLog.R')
# source('R/columnsUtilities.R')
# source('R/getPatientSubjectHash.R')
# source('R/getNewIdentifiers.R')
#
# config <- getConfig('config_file')
#
# require(data.table)
# require(dplyr)

#config$BASE_PATH
extractPatientList <- function(conf = config) {
  require(data.table)
  start <- Sys.time()
  # load master_mapping
  if (!file.exists(conf$MAPPING_FILE_DIRECTORY)) {stop(paste('Directory not found: ',conf$MAPPING_FILE_DIRECTORY,'does not exit'))}
  masterMappingFile <- paste0(conf$MAPPING_FILE_DIRECTORY,'master_mapping')

  newColumns <- c('SUBJECT_ID','SEX_CD', 'RACE_CD', 'AGE_IN_YEARS_NUM', 'BIRTH_DATE', 'DEATH_DATE', 'FAMILY', 'ROLE')

  if (!file.exists(masterMappingFile)) {stop(paste('master mapping File not found:',masterMappingFile,'does not exit'))}
  masterMapping <- read.table(masterMappingFile, sep = '\t', header = T, as.is=T)
  nFile <- nrow(masterMapping)

  # ----- loop over every row of master mapping
  for(i in 1:nrow(masterMapping)) {

    # ----- load mapping file
    mappingFileName <- masterMapping$mappingfile[i]
    mappingFileFullPath <- paste0(conf$MAPPING_FILE_DIRECTORY,mappingFileName)
    if (!file.exists(mappingFileFullPath)) {stop(paste('mapping File not found:', mappingFileFullPath,'does not exit'))}

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
    dataFileFullPath <- paste0(conf$DATA_BASE_PATH,conf$PATIENT_DATA_DIRECTORY,dataFileName)

    if (!file.exists(dataFileFullPath)) {stop(paste('Data File not found:', dataFileFullPath,'does not exit'))}
    f <- fread(dataFileFullPath)
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
      tempColsToKeep <- c('SUBJECT_ID',names(temp)[!(names(temp) %in% names(patientList))])
      patientList <-merge(as.data.frame(patientList),
                          as.data.frame(subset(temp,select=tempColsToKeep)), 
                          all.x=T, all.y =T, 
                          by = 'SUBJECT_ID')
    }
    # -------
  }
  patientList <- patientList[!duplicated(patientList$SUBJECT_ID),]
  
  time <- Sys.time() - start

  toLog(paste0('Patient Dimension - Retrieved ',nrow(patientList),' patients from ',nFile,'files in'),time)

  return(patientList)

}

# patients <- extractPatientList(config)
#
# # ------ get existing patients from DB (patient_mapping)
# patientHash <- getPatientSubjectHash()
# existingPatients <- merge(as.data.frame(patients), patientHash, by.x = 'SUBJECT_ID', by.y = 'PATIENT_IDE')
# # ------



findNewPatients <- function(patients, patientHash) {

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
    
    patientTrialData <- data.frame(PATIENT_NUM = newPatients$PATIENT_NUM,
                                   TRIAL = config$SOURCESYSTEM,
                                   SECURE_OBJ_TOKEN = config$SECURE_OBJ_TOKEN)

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
    patientTrialData <- createDataFrameFromColumns(config$PATIENT_TRIAL_COLUMNS)

  }

  return(list(patientDimensionData = patientDimensionData,
              patientMappingData = patientMappingData,
              patientTrialData = patientTrialData,
              newPatients = newPatients))
}

# dataFiles <- findNewPatients(patients,patientHash)


mergePatients <- function(existingPatients, newPatients) {
  setnames(existingPatients, 'SUBJECT_ID', 'SOURCESYSTEM_CD')
  if (nrow(newPatients)>0) {
    return(rbind(existingPatients,newPatients))
  } else {return(existingPatients)

  }

}

# patients <- mergePatients(existingPatients, dataFiles$newPatients)

# if(!file.exists('temp')){
#   dir.create('temp')
# }
#
# save(patients,file='temp/patients.RData')
#
# write.table(dataFiles$patientDimensionData,file(paste0(config$PATIENT_DIMENSION_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)
# write.table(dataFiles$patientMappingData,file(paste0(config$PATIENT_MAPPING_OUT_FILE)),quote = F, sep = '\t', na = '', row.names = F)

