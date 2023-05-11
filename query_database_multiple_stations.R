#Download data for FIRE index for Ferdia (summer student)
#script by Pádraig Fattery (padraig.flattery@met.ie) May 2021

#load packages
library(dplyr)
library(RJDBC)
library(data.table)
library(tidyverse)

#Load database connect function (keep in your working directory
#need RJDBC loaded for this to work
source("~/fire/db_conn.R")


sql_to_csv <- function(stno){
  #This is a function which takes a single station number (stno) as an argument
  #and passes it to an SQL query which extracts rainfall from 12-12 UTC and other
  #variables daily at 12am. The variables are used in the 'Fire Weather Index' calculation
  
  #read rainfall data, this query calculates rainfall from 12-12 UTC (http://reaserve/trac/wiki/NonDailyRainfall)
  rainfall <- db_conn(paste("SELECT stno, date_trunc('day',date + date('11 hours')) 
                          AS date_s, sum(rainfall) AS daily_rain_total 
                          FROM hourly WHERE stno = ", paste0(stno),"
                          GROUP BY stno, date_trunc('day',date + date('11 hours')) 
                          ORDER BY date_trunc('day',date_s)"))
  
  #change name of column for merge later
  setnames(rainfall, "date_s", "date")
  
  #read in the other data variables daily at 12pm 
  othervars <- db_conn(paste("select stno,date,speed,drybulb,rh from hourly 
  where stno = ", paste0(stno)," and hour = 12"))
  
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
  
  #arrange by date
  alldata <- dplyr::arrange(alldata, date)
  
  #write the data to csv 
  write.csv(alldata, paste0('/home/pflattery/fire/output_2023/', stno,'.csv'), row.names = FALSE)
}

#test on one to see if it works correctly
sql_to_csv(305)

#if it works, do it for multiple stations in a list
station_numbers <- list(305, 1004, 518, 532, 2727, 3723, 2437, 4919, 1034, 2615,
                        545, 3613, 3904, 2922, 4935, 5237, 875, 175, 275, 375, 
                        475, 575, 675, 1975)

#apply the function to all the stations in the list above
#this generates a csv for each station with the stno as the title
lapply(station_numbers, sql_to_csv)
