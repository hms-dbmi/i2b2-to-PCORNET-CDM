#'JDBC Connect
#'
#'Create connection to a JDBC database
#'
#'@param config_path Path to config_file (see getConfig() documentation)
#'@return connection object
#'@export
JDBCConnect <- function(config_path = 'config_file')
{
  require(RJDBC)
  config <- getConfig(config_path)
  db_connect = paste("jdbc:oracle:thin:@", config$db_host,":",config$db_port,':',config$db_name, sep = '')
  drv <- JDBC(config$driver_type, classPath= config$driver_path, " ") 
  con <- dbConnect(drv, db_connect, config$db_user, config$db_pass) 
  return(con)
}