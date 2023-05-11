#Download data for FIRE index for Ferdia (summer student)
#script by Pádraig Fattery (padraig.flattery@met.ie) May 2021

#load packages
library(dplyr)
library(RJDBC)
library(data.table)

#Load database connect function (keep in your working directory
#need RJDBC loaded for this to work
source("~/fire/db_conn.R")

#read rainfall data, this query calculates rainfall from 12-12 UTC (http://reaserve/trac/wiki/NonDailyRainfall)
rainfall <- db_conn(paste("SELECT stno, date_trunc('day',date + date('11 hours')) 
                          AS date_s, sum(rainfall) AS daily_rain_total 
                          FROM hourly WHERE stno = 875 
                          GROUP BY stno, date_trunc('day',date + date('11 hours')) 
                          ORDER BY date_trunc('day',date_s)"))

#change name of column for merge later
setnames(rainfall, "date_s", "date")

#read in the other data variables daily at 12pm 
othervars <- db_conn(paste("select stno,date,speed,drybulb,rh from hourly where stno = 875 and
   hour = 12"))

#set date column as a date column
rainfall$date <- as.Date(rainfall$date)
othervars$date <- as.Date(othervars$date)

#merge the data using dplyr
alldata <- left_join(othervars, rainfall, by=c("stno","date"))

#change the variable names to more intuitive ones using data.table package
setnames(alldata, "drybulb", "Temperature (C)")
setnames(alldata, "speed", "Windspeed (knots)")
setnames(alldata, "rh", "Relative Humidity (%)")
setnames(alldata, "daily_rain_total", "Total Rain (mm)")

#write the data to csv 
write.csv(alldata, '/home/pflattery/fire/MullingarSynop.csv', row.names = FALSE)

