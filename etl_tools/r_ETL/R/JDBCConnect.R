#'JDBC Connect
#'
#'Create connection to a JDBC database
#'
#'@param config_path Path to config_file (see getConfig() documentation)
#'@return connection object
#'@export
JDBCConnect <- function(conf = config)
{
  require(RJDBC)
  db_connect = paste("jdbc:oracle:thin:@", conf$db_host,":",conf$db_port,':',conf$db_name, sep = '')
  drv <- JDBC(conf$driver_type, classPath= conf$driver_path, " ") 
  con <- dbConnect(drv, db_connect, conf$db_user, conf$db_pass) 
  return(con)
}