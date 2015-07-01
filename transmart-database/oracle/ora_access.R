# Sets up JDBC access for R
# Avoids echoing passwords
# Requires RJDBC library, if not installed use "install.packages(RJDBC)" first
library(RJDBC)
drv <- JDBC("oracle.jdbc.OracleDriver",classPath="/mnt/tmp/11.2.0/client_1/ojdbc5.jar", " ")
# change DB address as needed
jdbc <- "jdbc:oracle:thin:@pici-ssc-phenome-dev-db.dbmi.hms.harvard.edu:1521:ORCL"
user <- Sys.getenv("USER")
if (Sys.getenv("RSTUDIO") == 1) {
con <- dbConnect(drv, jdbc, user, .rs.askForPassword("Enter Oracle password:"))
} else {
cat('Enter Oracle password:')
con <- dbConnect(drv, jdbc, user, system('stty -echo && read -e ff && stty echo && echo $ff && ff=""', intern=TRUE))
cat('\n')
}
