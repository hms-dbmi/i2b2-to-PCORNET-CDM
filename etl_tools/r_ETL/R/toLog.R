#'toLog
#'
#'Write a new line to the log file defined in the configuration file
#'
#'@param message : text to write
#'@param time : duration (facultative)
#'@param conf : config environment (obtained with getConfig())
#'@param debug : if this parameter = 1 then the message will be logged only in debug mode (config file)
#'@return new line in the log file
#'@export
toLog <- function(message, time = '',conf = config, debug = 0) {
  if (config$logging == 'YES') {
    if (time != '') {
      time = paste(as.character(round(time,2)), units(time))
    }
    if(!file.exists(config$log_file)) {
      fileConn<-file(config$log_file, open ='w')
    } else {
      fileConn<-file(config$log_file , open = 'at')
    }
    writeLines(paste(Sys.time(), ' -- ',message, time), fileConn)
    close(fileConn)
  }
}