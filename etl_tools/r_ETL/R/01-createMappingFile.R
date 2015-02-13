

# source('r_etl/R/getConfig.R')
# source('r_etl/R/toLog.R')
# source('r_etl/R/conceptsUtilities.R')
# 
# config <- getConfig('config_file')

createMappingFile <- function(conf = config) {
  require(data.table)
  ## load parameters from config

  MAPPING_BASE_PATH <- conf$MAPPING_BASE_PATH
  MAPPING_BASE_PATH <- paste0('\\',paste(splitLevelsFromStrings(MAPPING_BASE_PATH),collapse='\\'),'\\')

  baseDir <- paste0(conf$DATA_BASE_PATH,conf$PATIENT_DATA_DIRECTORY)
  MAPPING_FILE_DIRECTORY <- conf$MAPPING_FILE_DIRECTORY
  extension <- conf$DATA_FILE_EXTENSION
  colOmit <- conf$COLUMNS_OMIT_FILE
  colSpec <- conf$COLUMNS_SPECIAL_FILE
  toBlobThreshold <- as.numeric(conf$TO_BLOB_LIMIT)
  level_sep <- conf$LEVEL_SEP
  
  start <- Sys.time()

  if (!file.exists(colOmit)) {stop(paste('columns.omit not found:',colOmit,'does not exit'))}
  try(columns.omit <- read.table (colOmit,as.is=T))
  toLog('columns.omit Loaded')

  if (!file.exists(colSpec)) {stop(paste('columns.special not found:',colSpec,'does not exit'))}
  columns.special <- read.table (colSpec,as.is=T)
  if (sum(columns.special[,2] == 'SUBJECT_ID') != 1) {stop(paste('SUBJECT_ID mapping not defined in',columns.special))}
  toLog('columns.special Loaded')

  if (!file.exists(baseDir)) {stop(paste('Directory not found: ',baseDir,'does not exit'))}
  fileList <- list.files(baseDir, extension)
  outputFile <- paste0(fileList,'.map')
  fileName <- gsub(extension,'',fileList)
  nFile <- length(fileList)
  toLog(paste('List of files loaded:',nFile,'to process'))
  fileProcessed <- 0

  # create empty dataframe for demographics
  #demog <- data.frame(HEADER= character(), PATH=character(), DATATYPE=character())
  createDemogConcepts <- function(finalColName, result) {
    originalColName = columns.special$V1[columns.special$V2 == finalColName]
    if (originalColName %in% names(f)) {
      if(finalColName %in% c('SEX_CD','RACE_CD','ROLE')) {dataType <- 'T'} else {dataType <- 'N'}

      if(finalColName %in% c('SEX_CD', 'RACE_CD', 'AGE_IN_YEARS_NUM', 'ROLE')) {
        result <- rbind(result,data.frame(HEADER = originalColName,
                                          PATH = paste0(MAPPING_BASE_PATH,'Demographics','\\',finalColName,'\\'), DATATYPE = dataType,stringsAsFactors = F))
      }
      result <- rbind(result,data.frame(HEADER = originalColName,
                                        PATH = finalColName, DATATYPE = finalColName,stringsAsFactors = F))
    }
    return(result)
  }

  # for each file in fileList

  for (i in 1:nFile) {
    # load file
    cat(paste('Processing file',fileList[i],'(',fileProcessed+1,'/',nFile,')...'))
    toLog(paste('Processing file',fileList[i],'(',fileProcessed+1,'/',nFile,')...'), debug = 1)
    f <- fread(paste0(baseDir,fileList[i]))

    # verify presence of subject_id
    if (sum(names(f) == columns.special[columns.special[,2] == 'SUBJECT_ID',1]) == 0) {
      stop('No SUBJECT_ID column found in',fileList[i])
    }

    # suppress columns to omit
    if (length(columns.omit) != 0) {
      f <- f[,!(columns.omit[,1]),with=F]
    }

    # suppress empty columns
    NACol <- c()
    for (j in 1:ncol(f)) {
      if (sum(is.na(f[,j,with=F])) == nrow(f)) {
        NACol <- c(NACol,j)
      }
    }
    if (length(NACol) != 0) {
      f <- f[,!(NACol),with=F]
    }

    # default mapping to MAPPING_BASE_PATH\fileName\header, datatype set to class
    curratedColNames <- gsub(level_sep,'\\\\',names(f))
    result <- data.frame(HEADER = names(f), PATH = paste0(MAPPING_BASE_PATH,fileName[i],'\\',curratedColNames,'\\'), DATATYPE = unlist(lapply(f,class)),stringsAsFactors = F)
    result <- result[!(result$HEADER %in% columns.special[,1]),]

    # Demographics

    for (var in columns.special$V2) {
        result <- createDemogConcepts(var, result)
    }

    result$DATATYPE[result$DATATYPE == 'character'] <- 'T'
    result$DATATYPE[result$DATATYPE == 'integer'] <- 'N'
    result$DATATYPE[result$DATATYPE == 'numeric'] <- 'N'

    # for textual columns: if the number of levels > to toBlobThreshold => value to OBSERVATION_BLOB instead of TVAL_CHAR
    textCols <- result$DATATYPE=='T'
    if (sum(textCols)>0) {
      textCols <- result$HEADER[result$DATATYPE=='T']

        for (h in 1:length(textCols)) {
          textArray <- as.data.frame(f[,get(textCols[h])])
          textArrayLevels <- levels(as.factor(textArray[,1]))
          if (toBlobThreshold != -1) {
            if (length(textArrayLevels) > toBlobThreshold ) {
              toLog(paste0('File: ',fileList[i],', Header: ',textCols[h], ', Number of levels (',length(textArrayLevels), ') > ',toBlobThreshold, '=> DATATYPE set to BLOB'))
              result$DATATYPE[result$HEADER==textCols[h] & !is.na(result$HEADER)] <- 'B'
            }
          }
        }
    }



    # saving mapping file
    #result[columns.special[,1],2:3] <- columns.special[,2]
    result <- result[!is.na(result$HEADER),]
    fileToWrite <- paste0(MAPPING_FILE_DIRECTORY,outputFile[i])

    write.table(result,file= fileToWrite , sep='\t',quote = F, col.names = T, row.names = F)
    cat("Done\n")
    toLog(paste('Writing file',fileToWrite), debug = 1)
    print(paste('Writing file',fileToWrite))
    fileProcessed <- fileProcessed + 1
  }
  # saving master_mapping
  write.table(data.frame(mappingfile = outputFile, mappingtype = 'INDIVIDUAL'), file = paste0(MAPPING_FILE_DIRECTORY,'master_mapping'), sep='\t',quote = F, col.names = T, row.names = F)

  time = Sys.time() - start
  toLog(paste('Processed',fileProcessed,'files of',nFile,'in'),time)
}

#  createMappingFile(conf = config)
