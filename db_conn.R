## function to connect to climate database
## ## requires library(RJDBC)
## replace the words USER and PASSWORD in the script with your user credentials. 
## best not to have this in the main script but keep it separate  

db_conn <- function(sql) {

  drv <- JDBC("com.ingres.jdbc.IngresDriver","/opt/iijdbc.jar",identifier.quote="`")
  conn <- dbConnect(drv, "jdbc:ingres://belenos:ii7/climat", "cliwww", "users1")


  dbGetQuery(conn, sql)
}
