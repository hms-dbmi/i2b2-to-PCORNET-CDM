rm(list=ls())

# Load libraries and external functions ------
 source('R/getConfig.R')
 source('R/toLog.R')
 source('R/getNewIdentifiers.R')
 source('R/columnsUtilities.R')
 source("R/conceptsUtilities.R")
 source('R/JDBCConnect.R')
#
 require(data.table)
 require(dplyr)
 require(reshape2)
#
 require(foreach)
 require(doSNOW)
#
 config <- getConfig('config_file')

conf = config

# --------
#ObservationFact <- function(conf = config) {
  # Load parameters ---------
  ncore <- conf$CORES
  extension <- conf$DATA_FILE_EXTENSION
  OBSERVATION_FACTS_COLUMNS <- conf$OBSERVATION_FACTS_COLUMNS
  obsFile <- conf$OBSERVATION_FACT_OUT_FILE
  folderFile <- conf$CONCEPTS_FOLDERS_PATIENTS_OUT_FILE
  conceptCountFile <- conf$CONCEPT_COUNT_OUT_FILE
  CONCEPTS_FOLDER_PATIENTS_COLUMNS <- conf$CONCEPTS_FOLDER_PATIENTS_COLUMNS
  MAPPING_FILE_DIRECTORY <- conf$MAPPING_FILE_DIRECTORY
  OBSERVATION_FACTS_COLUMNS <- conf$OBSERVATION_FACTS_COLUMNS
  MAPPING_FILE_DIRECTORY <- conf$MAPPING_FILE_DIRECTORY
  DATA_BASE_PATH <- conf$DATA_BASE_PATH
  PATIENT_DATA_DIRECTORY <- conf$PATIENT_DATA_DIRECTORY
  ENCOUNTER_TYPE <- conf$ENCOUNTER_TYPE
  STUDY_ID <- conf$STUDY_ID
  debug <- conf$debug
  encounterNumRetrieved = F
  # ----------


  start <- Sys.time()

  # Get output files columns --------
  obsColumns <- createHeadersFromColumns(OBSERVATION_FACTS_COLUMNS)
  folderColumns <- createHeadersFromColumns(CONCEPTS_FOLDER_PATIENTS_COLUMNS)
  # -------

  # load patients and concepts --------
  load('temp//patients.RData')
  #concepts <- read.table('data//i2b2_load_tables//concept_dimension.dat', sep='\t', header=T,as.is=T)
  concepts <- fread('data//i2b2_load_tables//concept_dimension.dat')
  # ----------

  # Load master mapping ---------
  masterMappingFile <- paste0(MAPPING_FILE_DIRECTORY,'master_mapping')
  if (!file.exists(masterMappingFile)) {stop(paste('Config File not found:',masterMappingFile,'does not exit'))}
  masterMapping <- read.table(masterMappingFile, sep = '\t', header = T, as.is=T)
  nFile <- nrow(masterMapping)
  # ----------

  # initial output files ---------
  con <- file(obsFile,'w')
  writeLines(createHeadersFromColumns(OBSERVATION_FACTS_COLUMNS),con)
  close(con)

  con <- file(folderFile,'w')
  writeLines(createHeadersFromColumns(folderColumns),con)
  close(con)
  # ---------

  # Multicore options -------
  #
  # cl <- makeCluster(ncore, type = "SOCK")
  # registerDoSNOW(cl)
  # ----------

  # utility functions ---------
  getEncounterIds <- function(conf = config) {
    nobs <- nrow(temp)
    if (ENCOUNTER_TYPE == 'FAMILY') {

      if (encounterNumRetrieved == F){
        families <- data.frame(FAMILY=patients$FAMILY[!duplicated(patients$FAMILY)])

        if(debug == 0) {
          families$ENCOUNTER_NUM <- getNewIdentifiers(numberOfIdsToGet = nrow(families), "I2B2DEMODATA.SQ_UP_ENCDIM_ENCOUNTERNUM",conf )
        } else {
          families$ENCOUNTER_NUM <- seq(1:nrow(families))
        }
        patients <- merge(patients,families, by='FAMILY')
        assign('encounterNumRetrieved',T, envir = .GlobalEnv )
        return(patients)
      } else {
        return(patients)
      }

    } else if (debug == 0) {
      encounter_nums <- getNewIdentifiers(numberOfIdsToGet = nobs, "I2B2DEMODATA.SQ_UP_ENCDIM_ENCOUNTERNUM" )

    } else {
      encounter_nums <- seq(1, nobs)
    }

    return(encounter_nums)
  }

  generateIntermediatesForPatientFolder <- function(patientFolder) {
    patientFolderTemp <- patientFolder
    while(nrow(patientFolderTemp) > 0) {
      patientFolderTemp$CONCEPT_PATH <- gsub('[^\\)]+\\\\$','',patientFolderTemp$CONCEPT_PATH)
      patientFolderTemp <- patientFolderTemp[patientFolderTemp$CONCEPT_PATH != '\\',]
      patientFolder <- rbind(patientFolder, patientFolderTemp)
    }
    patientFolder <- distinct(patientFolder)
    return(patientFolder)
  }
  # ------------


  #foreach(i=1:nrow(masterMapping), .packages=c('data.table','dplyr')) %dopar%

  # BEGIN files loop ------------
  for(i in 1:nrow(masterMapping))
  {

    # load mapping file ----------
    mappingFileName <- masterMapping$mappingfile[i]
    mappingFileFullPath <- paste0(MAPPING_FILE_DIRECTORY,mappingFileName)
    if (!file.exists(mappingFileFullPath)) {stop(paste('Config File not found:', mappingFileFullPath,'does not exit'))}
    toLog(paste0('Observation Fact - Processing Mapping File: ',mappingFileName),conf = conf)
    mappingFile <- read.table(paste0(MAPPING_FILE_DIRECTORY,mappingFileName),sep = '\t', header = T, as.is=T)
    # -------------

    # load data file ---------
    dataFileName <- gsub('.map','',mappingFileName)
    dataFileFullPath <- paste0(DATA_BASE_PATH,PATIENT_DATA_DIRECTORY,dataFileName)
    if (!file.exists(dataFileFullPath)) {stop(paste('Data File not found:', dataFileFullPath,'does not exit'))}
    f <- fread(paste0(DATA_BASE_PATH,PATIENT_DATA_DIRECTORY,dataFileName),na.strings = '')
    toLog(paste0('Observation Fact - Processing Data File: ',dataFileName),conf = conf)
    # ----------

    idColumn <- mappingFile$HEADER[mappingFile$PATH == "SUBJECT_ID"]

    # retrieve patient_nums and roles ------------
    patient_nums <- patients$PATIENT_NUM[patients$SOURCESYSTEM_CD %in% unlist(f[,idColumn,with=F])]

    if (!is.null(patients$ROLE)) {
      patient_roles <- patients$ROLE[patients$SOURCESYSTEM_CD %in% unlist(f[,idColumn,with=F])]

    }
    # -----------

    nfacts <- 0
    startFile <- Sys.time()

    # BEGIN rows loop
    for(j in 1:nrow(mappingFile)) {
      # get var name -------
      print(paste0(mappingFileName,': ',j,'/',nrow(mappingFile)))
      var =  mappingFile$HEADER[j]
      # ---------

      # for numerical and blob concepts -----------

      if(mappingFile$DATATYPE[j] == 'N' | mappingFile$DATATYPE[j] == 'B') {

        # create temp data.frame --------
        temp <- data.frame(SOURCESYSTEM_CD = unlist(f[,idColumn,with=F]), NVAL_NUM = unlist(f[,var,with=F]))
        temp <- merge(temp, subset(patients,select=c('PATIENT_NUM','SOURCESYSTEM_CD')),by='SOURCESYSTEM_CD')
        temp$SOURCESYSTEM_CD <- c()
        # ----------

        # add roles -------
        if (exists('patient_roles')) {
          temp <- cbind(temp, ROLE = patient_roles)
        }
        # --------

        if(nrow(temp)>0) {
          # add encounter ---------
          if (ENCOUNTER_TYPE == 'FAMILY') {
            patients <- getEncounterIds()
            temp$ENCOUNTER_NUM <- patients$ENCOUNTER_NUM[patients$PATIENT_NUM %in% temp$PATIENT_NUM]
            temp <- temp[!is.na(temp$NVAL_NUM),]
          } else {
            temp <- temp[!is.na(temp$NVAL_NUM),]
            encounter_nums <- getEncounterIds()
            temp$ENCOUNTER_NUM <- encounter_nums
          }
          # ----------

          # get the list of concepts for the file and their type --------
          obsPathMap <- (concepts$CONCEPT_PATH == mappingFile$PATH[j])
          valtype <- ifelse(mappingFile$DATATYPE[j] == 'B', 'N', 'N')

          if (mappingFile$DATATYPE[j]=='N') {
            tval <- 'E'
            nval <- temp$NVAL_NUM
            blob = NA
          } else {
            tval <- 'BLOB'
            nval <- NA
            blob = temp$NVAL_NUM
          }
          # ------------

          # create  data frames --------
          obs <- data.frame(ENCOUNTER_NUM = temp$ENCOUNTER_NUM,
                            PATIENT_NUM = temp$PATIENT_NUM,
                            CONCEPT_CD = concepts$CONCEPT_CD[obsPathMap],
                            PROVIDER_ID = '@',
                            START_DATE = NA,
                            MODIFIER_CD = paste0('ROLE:',temp$ROLE),
                            VALTYPE_CD = valtype,
                            TVAL_CHAR = tval,
                            NVAL_NUM = nval,
                            VALUEFLAG_CD = NA,
                            QUANTITY_NUM = NA,
                            UNITS_CD = NA,
                            END_DATE = NA,
                            LOCATION_CD = NA,
                            CONFIDENCE_NUM = NA,
                            UPDATE_DATE = Sys.time(),
                            DOWNLOAD_DATE = Sys.time(),
                            IMPORT_DATE = Sys.time(),
                            SOURCESYSTEM_CD = STUDY_ID,
                            UPLOAD_ID = NA,
                            OBSERVATION_BLOB = blob,
                            INSTANCE_NUM = 1)

          patientFolder <- data.frame(PATIENT_NUM = temp$PATIENT_NUM,
                                      CONCEPT_PATH = concepts$CONCEPT_PATH[obsPathMap])
          # -----------

          # generate intermediate concepts lines for patientFolder -------
          #         patientFolderTemp <- patientFolder
          #         while(nrow(patientFolderTemp) > 0) {
          #           patientFolderTemp$CONCEPT_PATH <- gsub('[^\\)]+\\\\$','',patientFolderTemp$CONCEPT_PATH)
          #           patientFolderTemp <- patientFolderTemp[patientFolderTemp$CONCEPT_PATH != '\\',]
          #           patientFolder <- rbind(patientFolder, patientFolderTemp)
          #         }
          patientFolder <- generateIntermediatesForPatientFolder(patientFolder)
          # ----------

          # write tables --------
          if (mappingFile$DATATYPE[j]=='N' | mappingFile$DATATYPE[j] == 'B') {
            write.table(obs, file = obsFile,append=T, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')
            write.table(patientFolder, file = folderFile,append=T, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')
          }
          # ----------
          nfacts <- nfacts + nrow(obs)
          rm(obs,temp)
        }
        # END of numerical concepts -----------

        # textual concepts --------
      } else if (mappingFile$DATATYPE[j] == 'T') {

        # create temp data.frame --------
        temp <- data.frame(SOURCESYSTEM_CD = unlist(f[,idColumn,with=F]), TVAL_CHAR = unlist(f[,var,with=F]))
        temp <- merge(temp, subset(patients,select=c('PATIENT_NUM','SOURCESYSTEM_CD')),by='SOURCESYSTEM_CD')
        temp$SOURCESYSTEM_CD <- c()
        # ----------

        # add roles -------
        if (exists('patient_roles')) {
          temp <- cbind(temp, ROLE = patient_roles)
        }
        # ----------

        # add encounter ---------
        if (ENCOUNTER_TYPE == 'FAMILY') {
          patients <- getEncounterIds()
          temp$ENCOUNTER_NUM <- patients$ENCOUNTER_NUM[patients$PATIENT_NUM %in% temp$PATIENT_NUM]
          temp<- temp[temp$TVAL_CHAR != '' & !is.na(temp$TVAL_CHAR),]
        } else {
          temp<- temp[temp$TVAL_CHAR != '' & !is.na(temp$TVAL_CHAR),]
          encounter_nums <- getEncounterIds()
          temp$ENCOUNTER_NUM <- encounter_nums
        }
        # ----------

        # extract and clean levels --------
        temp$TVAL_TEMP <- temp$TVAL_CHAR
        temp$TVAL_TEMP <- clearLevels(temp$TVAL_TEMP)
        temp <- temp[temp$TVAL_TEMP != 'NA',]
        levels <- data.frame(TVAL_TEMP = levels(as.factor(temp$TVAL_TEMP[temp$TVAL_TEMP != 'NA'])))

        # ----------

        # match extracted levels to concepts ---------
        #levels$pathToGrep<- paste0(gsub(extension,'',dataFileName),'\\\\',var,'\\\\',levels$TVAL_TEMP,'\\\\')
        levels$pathToGrep <- paste0(mappingFile$PATH[j],levels$TVAL_TEMP,'\\')
        levels$pathToGrep <- unlist(lapply(levels$pathToGrep,truncatePath))
        levels$pathToGrep <- gsub('[(\\)]','\\\\\\\\',levels$pathToGrep)

        levels$CONCEPT_CD <- unlist(lapply(levels$pathToGrep,function(x) {concepts$CONCEPT_CD[grep(x,concepts$CONCEPT_PATH)] }))
        levels$CONCEPT_PATH <- unlist(lapply(levels$pathToGrep,function(x) {concepts$CONCEPT_PATH[grep(x,concepts$CONCEPT_PATH)] }))
        temp <- merge(temp, subset(levels,select=c(TVAL_TEMP,CONCEPT_CD,CONCEPT_PATH)),all.x=T,)
        temp$TVAL_TEMP <- c()
        # ----------

        # generate data frames --------
        obs <- data.frame(ENCOUNTER_NUM = temp$ENCOUNTER_NUM,
                          PATIENT_NUM = temp$PATIENT_NUM,
                          CONCEPT_CD = unlist(temp$CONCEPT_CD),
                          PROVIDER_ID = '@',
                          START_DATE = NA,
                          MODIFIER_CD = paste0('ROLE:',temp$ROLE),
                          VALTYPE_CD = 'T',
                          TVAL_CHAR = temp$TVAL_CHAR,
                          NVAL_NUM = NA,
                          VALUEFLAG_CD = NA,
                          QUANTITY_NUM = NA,
                          UNITS_CD = NA,
                          END_DATE = NA,
                          LOCATION_CD = NA,
                          CONFIDENCE_NUM = NA,
                          UPDATE_DATE = Sys.time(),
                          DOWNLOAD_DATE = Sys.time(),
                          IMPORT_DATE = Sys.time(),
                          SOURCESYSTEM_CD = STUDY_ID,
                          UPLOAD_ID = NA,
                          OBSERVATION_BLOB = NA,
                          INSTANCE_NUM = 1)

        patientFolder <- data.frame(PATIENT_NUM = temp$PATIENT_NUM,
                                    CONCEPT_PATH = unlist(temp$CONCEPT_PATH))

        # generate intermediate concepts lines for patientFolder -------
        patientFolder <- generateIntermediatesForPatientFolder(patientFolder)
        #       patientFolderTemp <- patientFolder
        #       while(nrow(patientFolderTemp) > 0) {
        #         patientFolderTemp$CONCEPT_PATH <- gsub('[^\\)]+\\\\$','',patientFolderTemp$CONCEPT_PATH)
        #         patientFolderTemp <- patientFolderTemp[patientFolderTemp$CONCEPT_PATH != '\\',]
        #         patientFolder <- rbind(patientFolder, patientFolderTemp)
        #       }
        #       patientFolder <- distinct(patientFolder)
        # ----------

        # write tables --------
        write.table(obs, file = obsFile,append=T, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')
        write.table(patientFolder, file = folderFile,append=T, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')

        nfacts <- nfacts + nrow(obs)
        rm(obs,temp,patientFolder)
        # ---------
        #     if(exists('observationFact')) {
        #       observationFact<- rbind(observationFact,obs)
        #     } else {
        #       observationFact <- obs
        #     }
      }
      # END of textual concepts -------

    }
    # END of rows loop ----------
    timeFile <- Sys.time() - startFile
    toLog(paste0('Observation Fact - Written to Obsercation Fact File: ', nfacts,' facts in'),timeFile,conf = conf)
    # write.table(observationFact, file = paste0('temp/obs_temp_',i),append=T, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding= 'latin1')
  }
  # END of files loop --------

  # keep only distinct lines in concepts_folders_patients ----------
  conceptFolders <- fread(folderFile)
  conceptFolders  <- distinct(conceptFolders )
  # -----------


  # calculate concept counts from concept_folders_patients --------
  conceptFolders$PATIENT_COUNT <- 1
  conceptCount <- aggregate(PATIENT_COUNT ~ CONCEPT_PATH, data = conceptFolders, FUN =sum )
  conceptCount$PARENT_CONCEPT_PATH <- gsub('[^\\]+[\\]$','',conceptCount$CONCEPT_PATH)
  conceptCount <- conceptCount[grepl(conf$MAPPING_BASE_PATH,conceptCount$CONCEPT_PATH),]
  conceptCount <- conceptCount[,c('CONCEPT_PATH','PARENT_CONCEPT_PATH','PATIENT_COUNT')]
  conceptFolders$PATIENT_COUNT <- c()
  # ------------

  # write tables, concepts_folder and concept_count
  write.table(conceptFolders, file = folderFile, sep = '\t', na = "", col.names = T,row.names=F, quote = F,fileEncoding= 'latin1')
  write.table(conceptCount, file = conceptCountFile, sep = '\t', na = "", col.names = T,row.names=F, quote = F,fileEncoding= 'latin1')

  # -----------

  Sys.time() - start
  # stopCluster(cl)
#}

#ObservationFact()

