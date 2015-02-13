createDataFrameFromColumns <- function(columnNames, nrow=0) {
  columnNames <- strsplit(gsub('\"',"",columnNames),',')
  columnNames <- unlist(columnNames)
  df <- data.frame(matrix(ncol = length(columnNames), nrow = nrow))
  names(df) <- columnNames
  return(df)
}

