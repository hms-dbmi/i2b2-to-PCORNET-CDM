
# rm(list=ls())
# source('../MyPheWAS/R/getConfig.R')
# source('../MyPheWAS/R/toLog.R')
# source('R/getNewIdentifiers.R')
# source("R/columnsUtilities.R")
# source("R/conceptsUtilities.R")
# config <- getConfig('config_file')
# require(data.table)
# require(dplyr)
# conf = config
# require(foreach)
# require(doSNOW)
#

##  Main function -------

conceptDimension <- function(conf = config) {

  start <- Sys.time()

  ## ------ load parameters
  mappingBasePath <- conf$MAPPING_BASE_PATH
  MAPPING_FILE_DIRECTORY <- conf$MAPPING_FILE_DIRECTORY
  DATA_BASE_PATH <- conf$DATA_BASE_PATH
  OUTPUT_BASE_PATH <- conf$OUTPUT_BASE_PATH

  extension = conf$DATA_FILE_EXTENSION
  PATIENT_DATA_DIRECTORY <- conf$PATIENT_DATA_DIRECTORY
  debug <- conf$debug

  FACT_SET <- conf$FACT_SET
  STUDY_ID <- conf$STUDY_ID

  CONCEPT_DIMENSION_OUT_FILE <- conf$CONCEPT_DIMENSION_OUT_FILE
  CONCEPT_COUNT_OUT_FILE <- conf$CONCEPT_COUNT_OUT_FILE
  I2B2_OUT_FILE <- conf$I2B2_OUT_FILE

  CONCEPT_DIMENSION_COLUMNS <- conf$CONCEPT_DIMENSION_COLUMNS
  CONCEPT_COUNT_COLUMNS <- conf$CONCEPT_COUNT_COLUMNS
  I2B2_COLUMNS <- conf$I2B2_COLUMNS
  hideLeaveThreshold <- conf$HIDE_LEAVE_LIMIT

  lowLevelsCreated  = F
  patients_file <- 'temp/patients.RData'

  options(stringsAsFactors = F)
  # ------

  # ------ Multicore options
  #ncore = as.numeric(conf$CORES)
  # if (ncore > 1) {
  #   cl <- makeCluster(ncore, type = "SOCK")
  #   registerDoSNOW(cl)
  # }
  # ------

  # Set working directory to OUTPUT_BASE_PATH ------
  setwd(OUTPUT_BASE_PATH)
  # ------

  # Load Master Mapping -------
  masterMappingFile <- paste0(MAPPING_FILE_DIRECTORY,'master_mapping')
  if (!file.exists(masterMappingFile)) {stop(paste('Config File not found:',masterMappingFile,'does not exit'))}
  masterMapping <- read.table(masterMappingFile, sep = '\t', header = T, as.is=T)
  nFile <- nrow(masterMapping)
  # -------

  # Load patients.RData -------
  if (!file.exists(patients_file)) {stop(paste('Patients File not found:',patients_file,'does not exit'))}
  load(patients_file)
  # -------

  # Initiate output data files with headers-------
  conceptDimensionFile <- file(paste0(CONCEPT_DIMENSION_OUT_FILE),'w', encoding = 'latin1')
  conceptCountFile <- file(paste0(CONCEPT_COUNT_OUT_FILE),'w', encoding = 'latin1')
  i2b2File <- file(paste0(I2B2_OUT_FILE),'w', encoding = 'latin1')

  conceptDimensionColumns <- createColumnsList(CONCEPT_DIMENSION_COLUMNS)
  conceptCountColumns <- createColumnsList(CONCEPT_COUNT_COLUMNS)
  i2b2Columns <- createColumnsList(I2B2_COLUMNS)

  cat(paste(conceptDimensionColumns, collapse = '\t'), file = conceptDimensionFile, sep = '\n')
  cat(paste(conceptCountColumns, collapse = '\t'), file = conceptCountFile, sep = '\n')
  cat(paste(i2b2Columns, collapse = '\t'), file = i2b2File, sep = '\n')
  close(conceptDimensionFile)
  close(conceptCountFile)
  close(i2b2File)
  # --------

  # Calculate baseLevel ------
  baseLevel <- length(splitLevelsFromStrings(mappingBasePath)) - 1
  # -------
  intermediateLevels <- data.frame(level=numeric(),path=character(),Parent = character(), name = character())
  # Multicore loop -------
  #foreach(file=1:nrow(masterMapping), .packages=c('data.table','dplyr')) %dopar%
  # -------

  for (file in 1:nrow(masterMapping))
  {
    file_name <- masterMapping$mappingfile[file]
    mappingFileFullPath <- paste0(MAPPING_FILE_DIRECTORY,file_name)
    # load mapping file ------
    if (!file.exists(mappingFileFullPath)) {stop(paste('Mapping File not found:', mappingFileFullPath,'does not exit'))}
    print(paste0('Concept Dimension - Processing Mapping File: ',file_name))
    mappingFile <- read.table(paste0(MAPPING_FILE_DIRECTORY,file_name),sep = '\t', header = T, as.is=T)
    # ------

    # load data file ------
    dataFileName <- gsub('.map','',file_name)
    dataFileFullPath <- paste0(DATA_BASE_PATH,PATIENT_DATA_DIRECTORY,dataFileName)
    if (!file.exists(dataFileFullPath)) {stop(paste('Config File not found:', dataFileFullPath,'does not exit'))}
    print(paste0('Concept Dimension - Processing Data File: ',dataFileName))
    f <- fread(paste0(DATA_BASE_PATH,PATIENT_DATA_DIRECTORY,dataFileName))
    # -------

    # first file  -> create base path concepts -----
    if(file == 1) {

      lowLevels <- extractIntermediateLevels(baseLevel, mappingBasePath)

      LLConceptCount <- data.frame(CONCEPT_PATH = lowLevels$path,
                                   PARENT_CONCEPT_PATH = lowLevels$Parent,
                                   PATIENT_COUNT = nrow(patients),
                                   LEAF = 0)

      LLConceptDimension <- data.frame(CONCEPT_CD = 0 ,
                                       CONCEPT_PATH = lowLevels$path,
                                       NAME_CHAR = lowLevels$name,
                                       CONCEPT_BLOB = '',
                                       UPDATE_DATE = Sys.time(),
                                       DOWNLOAD_DATE = Sys.time(),
                                       IMPORT_DATE= Sys.time(),
                                       SOURCESYSTEM_CD= STUDY_ID,
                                       UPLOAD_ID= '',
                                       TABLE_NAME= '')

      LLi2b2 <- data.frame(C_HLEVEL = lowLevels$level,
                           C_FULLNAME = lowLevels$path,
                           C_NAME = lowLevels$name,
                           C_SYNONYM_CD = 'N',
                           C_VISUALATTRIBUTES = 'FA',
                           C_TOTALNUM = '',
                           C_BASECODE = 0,
                           C_METADATAXML = '',
                           C_FACTTABLECOLUMN= 'CONCEPT_CD',
                           C_TABLENAME= 'CONCEPT_DIMENSION',
                           C_COLUMNNAME= 'CONCEPT_PATH',
                           C_COLUMNDATATYPE= 'T',
                           C_OPERATOR= 'LIKE',
                           C_DIMCODE= lowLevels$path,
                           C_COMMENT= STUDY_ID,
                           C_TOOLTIP= lowLevels$path,
                           UPDATE_DATE= Sys.time(),
                           DOWNLOAD_DATE=Sys.time(),
                           IMPORT_DATE=Sys.time(),
                           SOURCESYSTEM_CD= STUDY_ID,
                           VALUETYPE_CD= '',
                           I2B2_ID= 0,
                           M_APPLIED_PATH= '',
                           M_EXCLUSION_CD= '',
                           C_PATH= '',
                           C_SYMBOL= '')

    }
    # --------

    for (i in 1:nrow(mappingFile)) {

      var <- mappingFile$HEADER[i]
      path <- mappingFile$PATH[mappingFile$HEADER == var & grepl("^[\\]",mappingFile$PATH)]

      if (length(path) > 0) {
        parent <- gsub("[^\\]+[\\]$", '',path)
        intermediateLevels <- rbind(intermediateLevels, extractIntermediateLevels(baseLevel,path))
        intermediateLevels <- intermediateLevels[!duplicated(intermediateLevels$path),]
      }

      ## text concepts --------
      if (mappingFile$DATATYPE[i] == 'T'){

        # detect var levels ------
        varLevels <- as.data.frame(table(f[,var,with=F],useNA='ifany'),stringsAsFactors = F)
        varLevels$Var1[varLevels$Var1 == ''] <- 'NA'
        varLevels$Var1[is.na(varLevels$Var1)] <- 'NA'
        # -----
        #remove every non alpha-numerical character and replace it by '_', then remove multiple and trailing '_'
        varLevels$Var1 <- clearLevels(varLevels$Var1)
        varLevels <- varLevels[!duplicated(varLevels$Var1),]
        varLevels <- varLevels[varLevels$Var1 != 'NA',]
        # -------

        # generate levels concepts path------
        child <- paste0(path,varLevels$Var1,'\\')
        ## truncate paths > 255 characters -------
        child <- unlist(lapply(child,truncatePath))
        # --------

        # generate node patient count--------
        totalPatients = sum(varLevels$Freq[varLevels$Var1 != 'NA'])
        # -------

        # generate data frames ---------


        ConceptCountTemp <- data.frame(CONCEPT_PATH = child,
                                       PARENT_CONCEPT_PATH = path,
                                       PATIENT_COUNT = varLevels$Freq,
                                       LEAF = 1)

        ConceptCountTemp <- rbind(ConceptCountTemp,
                                  data.frame(CONCEPT_PATH = path,
                                             PARENT_CONCEPT_PATH = parent,
                                             PATIENT_COUNT = totalPatients,
                                             LEAF = 0))



        ConceptDimensionTemp <- data.frame(CONCEPT_CD = 0 ,
                                           CONCEPT_PATH = ConceptCountTemp$CONCEPT_PATH,
                                           NAME_CHAR = c(varLevels$Var1,var),
                                           CONCEPT_BLOB = '',
                                           UPDATE_DATE = Sys.time(),
                                           DOWNLOAD_DATE = Sys.time(),
                                           IMPORT_DATE= Sys.time(),
                                           SOURCESYSTEM_CD= STUDY_ID,
                                           UPLOAD_ID= '',
                                           TABLE_NAME= '')

        # set visualAtrribute to hide if the number of levels > hideLeaveThreshold ------
        if (hideLeaveThreshold != -1) {
          if (nrow(varLevels) > hideLeaveThreshold) {visualAttribute <- 'LH'} else {visualAttribute <- 'LA'}
        }
        # -------

        i2b2Temp <- data.frame(C_HLEVEL = 0,
                               C_FULLNAME = ConceptCountTemp$CONCEPT_PATH,
                               C_NAME = c(varLevels$Var1,var),
                               C_SYNONYM_CD = 'N',
                               C_VISUALATTRIBUTES = ifelse(ConceptCountTemp$LEAF==1,visualAttribute,'FA'),
                               C_TOTALNUM = '',
                               C_BASECODE = 0,
                               C_METADATAXML = '',
                               C_FACTTABLECOLUMN= 'CONCEPT_CD',
                               C_TABLENAME= 'CONCEPT_DIMENSION',
                               C_COLUMNNAME= 'CONCEPT_PATH',
                               C_COLUMNDATATYPE= 'T',
                               C_OPERATOR= 'LIKE',
                               C_DIMCODE= ConceptCountTemp$CONCEPT_PATH,
                               C_COMMENT= STUDY_ID,
                               C_TOOLTIP= ConceptCountTemp$CONCEPT_PATH,
                               UPDATE_DATE= Sys.time(),
                               DOWNLOAD_DATE=Sys.time(),
                               IMPORT_DATE=Sys.time(),
                               SOURCESYSTEM_CD= STUDY_ID,
                               VALUETYPE_CD= '',
                               I2B2_ID= 0,
                               M_APPLIED_PATH= '',
                               M_EXCLUSION_CD= '',
                               C_PATH= '',
                               C_SYMBOL= '')

      }
      # END of textual concepts ---------

      # Numerical and blob concepts ---------
      if (mappingFile$DATATYPE[i] == 'N' | mappingFile$DATATYPE[i] == 'B'){

        # Generate data frames --------
        count = sum(!is.na(unlist(f[,var,with=F])))

        ConceptCountTemp <- data.frame(CONCEPT_PATH = path,
                                       PARENT_CONCEPT_PATH = parent,
                                       PATIENT_COUNT = count,
                                       LEAF = 1)

        ConceptDimensionTemp <- data.frame(CONCEPT_CD = 0 ,
                                           CONCEPT_PATH = ConceptCountTemp$CONCEPT_PATH,
                                           NAME_CHAR = var,
                                           CONCEPT_BLOB = '',
                                           UPDATE_DATE = Sys.time(),
                                           DOWNLOAD_DATE = Sys.time(),
                                           IMPORT_DATE= Sys.time(),
                                           SOURCESYSTEM_CD= STUDY_ID,
                                           UPLOAD_ID= '',
                                           TABLE_NAME= '')

        metadataxml <- paste0('<?xml version="1.0"?><ValueMetadata><Version>3.02</Version><CreationDateTime>08/14/2008 01:22:59</CreationDateTime>',
                              '<TestID></TestID><TestName></TestName><DataType>PosFloat</DataType><CodeType></CodeType><Loinc></Loinc>',
                              '<Flagstouse></Flagstouse><Oktousevalues>Y</Oktousevalues><MaxStringLength></MaxStringLength>',
                              '<LowofLowValue>0</LowofLowValue><HighofLowValue>0</HighofLowValue>',
                              '<LowofHighValue>100</LowofHighValue>100<HighofHighValue>100</HighofHighValue><',
                              'LowofToxicValue></LowofToxicValue><HighofToxicValue></HighofToxicValue><EnumValues></EnumValues>',
                              '<CommentsDeterminingExclusion><Com></Com></CommentsDeterminingExclusion><UnitValues>',
                              '<NormalUnits>ratio</NormalUnits><EqualUnits></EqualUnits><ExcludingUnits></ExcludingUnits>',
                              '<ConvertingUnits><Units></Units><MultiplyingFactor></MultiplyingFactor></ConvertingUnits>',
                              '</UnitValues><Analysis><Enums /><Counts /><New /></Analysis></ValueMetadata>')

        # switch between numerical and blob -------
        #datatype <- ifelse(mappingFile$DATATYPE[i] == 'B', 'T', 'N')

        i2b2Temp <- data.frame(C_HLEVEL = 0,
                               C_FULLNAME = ConceptCountTemp$CONCEPT_PATH,
                               C_NAME = var,
                               C_SYNONYM_CD = 'N',
                               C_VISUALATTRIBUTES = ifelse(ConceptCountTemp$LEAF==1,'LA','FA'),
                               C_TOTALNUM = '',
                               C_BASECODE = 0,
                               C_METADATAXML = metadataxml,
                               C_FACTTABLECOLUMN= 'CONCEPT_CD',
                               C_TABLENAME= 'CONCEPT_DIMENSION',
                               C_COLUMNNAME= 'CONCEPT_PATH',
                               C_COLUMNDATATYPE= 'T',
                               C_OPERATOR= 'LIKE',
                               C_DIMCODE= ConceptCountTemp$CONCEPT_PATH,
                               C_COMMENT= STUDY_ID,
                               C_TOOLTIP= ConceptCountTemp$CONCEPT_PATH,
                               UPDATE_DATE= Sys.time(),
                               DOWNLOAD_DATE=Sys.time(),
                               IMPORT_DATE=Sys.time(),
                               SOURCESYSTEM_CD= STUDY_ID,
                               VALUETYPE_CD= '',
                               I2B2_ID= 0,
                               M_APPLIED_PATH= '',
                               M_EXCLUSION_CD= '',
                               C_PATH= '',
                               C_SYMBOL= '')

      }
      # END of numerical concepts----------

      # merge temporary data frames ------
      if (!exists('ConceptCount') & exists('ConceptCountTemp')) {
        ConceptCount <- ConceptCountTemp
        ConceptDimension <- ConceptDimensionTemp
        i2b2 <- i2b2Temp
      } else if (exists('ConceptCountTemp')) {
        ConceptCount <- rbind(ConceptCount, ConceptCountTemp)
        ConceptDimension <- rbind(ConceptDimension, ConceptDimensionTemp)
        i2b2 <- rbind(i2b2,i2b2Temp)
        rm(i2b2Temp,ConceptCountTemp, ConceptDimensionTemp)
      }
      # ---------
    }
    # END of row loop -------


    # generate base concept --------
    fileName <- gsub(extension,'',dataFileName)
    fileConceptPathParent <- paste0('\\',paste(splitLevelsFromStrings(mappingBasePath),collapse = '\\'),'\\')
    fileConceptPath <- paste0(fileConceptPathParent,fileName,'\\')

    if(exists('ConceptCount')) {
      ConceptCount <- rbind(ConceptCount, data.frame(CONCEPT_PATH = fileConceptPath,
                                                     PARENT_CONCEPT_PATH = fileConceptPathParent,
                                                     PATIENT_COUNT = nrow(f),
                                                     LEAF = 0))
      ConceptDimension <- rbind(ConceptDimension, data.frame(CONCEPT_CD = 0 ,
                                                             CONCEPT_PATH = fileConceptPath,
                                                             NAME_CHAR = fileName,
                                                             CONCEPT_BLOB = '',
                                                             UPDATE_DATE = Sys.time(),
                                                             DOWNLOAD_DATE = Sys.time(),
                                                             IMPORT_DATE= Sys.time(),
                                                             SOURCESYSTEM_CD= STUDY_ID,
                                                             UPLOAD_ID= '',
                                                             TABLE_NAME= ''))


      i2b2 <- rbind(i2b2, data.frame(C_HLEVEL = 0,
                                     C_FULLNAME = fileConceptPath,
                                     C_NAME = fileName,
                                     C_SYNONYM_CD = 'N',
                                     C_VISUALATTRIBUTES = 'FA',
                                     C_TOTALNUM = '',
                                     C_BASECODE = 0,
                                     C_METADATAXML = '',
                                     C_FACTTABLECOLUMN= 'CONCEPT_CD',
                                     C_TABLENAME= 'CONCEPT_DIMENSION',
                                     C_COLUMNNAME= 'CONCEPT_PATH',
                                     C_COLUMNDATATYPE= 'T',
                                     C_OPERATOR= 'LIKE',
                                     C_DIMCODE= fileConceptPath,
                                     C_COMMENT= STUDY_ID,
                                     C_TOOLTIP= fileConceptPath,
                                     UPDATE_DATE= Sys.time(),
                                     DOWNLOAD_DATE=Sys.time(),
                                     IMPORT_DATE=Sys.time(),
                                     SOURCESYSTEM_CD= STUDY_ID,
                                     VALUETYPE_CD= '',
                                     I2B2_ID= 0,
                                     M_APPLIED_PATH= '',
                                     M_EXCLUSION_CD= '',
                                     C_PATH= '',
                                     C_SYMBOL= ''))

      # --------

      #i2b2$C_HLEVEL <- length(splitLevelsFromStrings(i2b2$C_FULLNAME, sep = '\\\\'))
      # insert I2V2 C_HLEVEL from path length----------
      xx<- lapply(i2b2$C_FULLNAME,splitLevelsFromStrings)
      xx <- lapply(xx,length)
      i2b2$C_HLEVEL <- unlist(xx)-1

      rm(xx)

      # insert low levels if not already done---------
      if (!lowLevelsCreated) {
        ConceptCount <- rbind(LLConceptCount, ConceptCount)
        ConceptDimension <- rbind(LLConceptDimension, ConceptDimension)
        i2b2 <- rbind(LLi2b2, i2b2)
        lowLevelsCreated = T
      }
      # ----------

      ConceptDimension <- ConceptDimension[!duplicated(ConceptDimension$CONCEPT_PATH),]
      ConceptCount <- ConceptCount[!duplicated(ConceptCount$CONCEPT_PATH),]
      i2b2 <- i2b2[!duplicated(i2b2$C_FULLNAME),]

      # get and insert new concepts identifiers --------
      if(debug == 0) {
        ConceptDimension$CONCEPT_CD <- getNewIdentifiers(nrow(ConceptDimension), "I2B2DEMODATA.CONCEPT_ID")
        i2b2$I2B2_ID <- getNewIdentifiers(nrow(i2b2), 'I2B2METADATA.I2B2_ID_SEQ')
      } else {
        ConceptDimension$CONCEPT_CD <- 1:nrow(ConceptDimension)
        i2b2$I2B2_ID <- 1:nrow(i2b2)
      }

      i2b2$C_BASECODE <- ConceptDimension$CONCEPT_CD
      ConceptCount$LEAF <- c()
      # -----------


      # write tables ----------
      write.table(ConceptDimension, file = paste0(CONCEPT_DIMENSION_OUT_FILE),append=TRUE, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
      write.table(ConceptCount, file = paste0(CONCEPT_COUNT_OUT_FILE),append=TRUE, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
      write.table(i2b2, file = paste0(I2B2_OUT_FILE),append=TRUE, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
      # ----------
    }
   (rm(ConceptCount,ConceptDimension,ConceptCountTemp,ConceptDimensionTemp, i2b2, i2b2Temp))
  }
  # END of file loop ------

  # stopCluster(cl)

  # generate intermediate levels data frames --------
  intermediateLevels <- intermediateLevels[!is.na(intermediateLevels$name),]
  conceptDimension <- fread(CONCEPT_DIMENSION_OUT_FILE)
  intermediateLevels <- intermediateLevels[!(intermediateLevels$path %in% conceptDimension$CONCEPT_PATH),]
  if (nrow(intermediateLevels) > 0) {
    ILConceptCount <- data.frame(CONCEPT_PATH = intermediateLevels$path,
                                 PARENT_CONCEPT_PATH = intermediateLevels$Parent,
                                 PATIENT_COUNT = NA,
                                 LEAF = 0)

    ILConceptDimension <- data.frame(CONCEPT_CD = 0 ,
                                     CONCEPT_PATH = intermediateLevels$path,
                                     NAME_CHAR = intermediateLevels$name,
                                     CONCEPT_BLOB = '',
                                     UPDATE_DATE = Sys.time(),
                                     DOWNLOAD_DATE = Sys.time(),
                                     IMPORT_DATE= Sys.time(),
                                     SOURCESYSTEM_CD= STUDY_ID,
                                     UPLOAD_ID= '',
                                     TABLE_NAME= '')

    ILi2b2 <- data.frame(C_HLEVEL = intermediateLevels$level,
                         C_FULLNAME = intermediateLevels$path,
                         C_NAME = intermediateLevels$name,
                         C_SYNONYM_CD = 'N',
                         C_VISUALATTRIBUTES = 'FA',
                         C_TOTALNUM = '',
                         C_BASECODE = 0,
                         C_METADATAXML = '',
                         C_FACTTABLECOLUMN= 'CONCEPT_CD',
                         C_TABLENAME= 'CONCEPT_DIMENSION',
                         C_COLUMNNAME= 'CONCEPT_PATH',
                         C_COLUMNDATATYPE= 'T',
                         C_OPERATOR= 'LIKE',
                         C_DIMCODE= intermediateLevels$path,
                         C_COMMENT= STUDY_ID,
                         C_TOOLTIP= intermediateLevels$path,
                         UPDATE_DATE= Sys.time(),
                         DOWNLOAD_DATE=Sys.time(),
                         IMPORT_DATE=Sys.time(),
                         SOURCESYSTEM_CD= STUDY_ID,
                         VALUETYPE_CD= '',
                         I2B2_ID= 0,
                         M_APPLIED_PATH= '',
                         M_EXCLUSION_CD= '',
                         C_PATH= '',
                         C_SYMBOL= '')

    # get intermediate levels identifiers --------
    if(debug == 0) {
      ILConceptDimension$CONCEPT_CD <- getNewIdentifiers(nrow(ILConceptDimension), "I2B2DEMODATA.CONCEPT_ID")
      ILi2b2$I2B2_ID <- getNewIdentifiers(nrow(ILi2b2), 'I2B2METADATA.I2B2_ID_SEQ')
    } else {
      ILConceptDimension$CONCEPT_CD <- 1:nrow(ILConceptDimension)
      ILi2b2$I2B2_ID <- 1:nrow(ILi2b2)
    }

    ILi2b2$C_BASECODE <- ILConceptDimension$CONCEPT_CD
    ILConceptCount$LEAF <- c()
    # ---------

    # write tables -------
    write.table(ILConceptDimension, file = paste0(CONCEPT_DIMENSION_OUT_FILE),append=TRUE, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
    write.table(ILConceptCount, file = paste0(CONCEPT_COUNT_OUT_FILE),append=TRUE, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
    write.table(ILi2b2, file = paste0(I2B2_OUT_FILE),append=TRUE, sep = '\t', na = "", col.names = F,row.names=F, quote = F,fileEncoding = 'latin1')
    # ---------
  }
  print(Sys.time() - start)

}

#  conceptDimension()

