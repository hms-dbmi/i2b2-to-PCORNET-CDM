
createColumnsList <- function(columnNames) {
  columnNames <- strsplit(gsub('\"',"",columnNames),',')
  return(unlist(columnNames))
}

createDataFrameFromColumns <- function(columnNames, nrow=0) {
  columnNames <- createColumnsList(columnNames)
  df <- data.frame(matrix(ncol = length(columnNames), nrow = nrow))
  names(df) <- columnNames
  return(df)
}

createHeadersFromColumns <- function(columnNames) {
  columnNames <- createColumnsList(columnNames)
  return(paste(columnNames, collapse='\t'))
}