splitLevelsFromStrings <- function(string, sep = '\\\\') {
  xx <- unlist(strsplit(x =string, split=sep))
  xx <- xx[xx != '']
  #   xx <- lapply(xx,length)
  #   xx <- t(as.data.frame(xx)) - 2
  #   xx <- xx[,1]
  return(xx)
}

# Extract intermediate Levels from a string between the base level and (level of the string - 1)
extractIntermediateLevels <- function(baseLevel,string) {
  splitString <- splitLevelsFromStrings(string)
  StringLevels <- length(splitString)-1
  result <- data.frame(level = baseLevel: max(baseLevel,(StringLevels-1)), path = baseLevel:max(baseLevel,StringLevels-1))
  for(level in baseLevel:max(baseLevel,(StringLevels-1))) {
    result$path[result$level==level] <- paste0('\\',paste(splitString[1:(level+1)],collapse = '\\'),'\\')
    result$level[result$level==level] <- level
    result$Parent[result$level==level] <- ifelse(level == 0, '', paste0('\\',paste(splitString[1:(level)],collapse = '\\'),'\\'))
    result$name[result$level==level] <- splitString[level+1]
  }
  return(result)
}
# clear textual levels fields
clearLevels <- function(levels) {
  levels <- gsub('[^a-zA-Z0-9]','_',levels)
  levels <- gsub('(_)+','_',levels)
  levels <- gsub('^_|_$','',levels)
  levels <- gsub("[\r\n]", "_", levels)
  levels[levels == ''] <- 'NA'
  #levels <- levels[!duplicated(levels),]
  return(levels)
}

# truncate paths to 255 characters
truncatePath <- function(path, max_length = 253) {
  if (nchar(path) > max_length) {
    path <- substring(path,0,max_length)
    path <- paste0(path,'\\')
  }
  return(path)
}
