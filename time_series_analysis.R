#this code takes the FWI output for the synoptic stations and 
#performs time-series analysis 

library(ggplot2)
library(RJDBC)
library(lubridate)

#db_conn function for running SQL
source("~/fire/db_conn.R")

station_names <- db_conn(paste("SELECT stno,name 
                          FROM stations"))

station_names$stno <- as.factor(station_names$stno)

#blank data frame for combined data
combined_data <- data.frame()

#folder with fwi output
folder_path <- "/home/pflattery/fire/fwi_output_final"

#create a list of files for manipulation
file_list <- list.files(folder_path, full.names = TRUE)

for (file in file_list) {
  # Extract the station number from the filename
  station_number <- gsub("_fwi.csv", "", basename(file))
  
  station_name <- station_names$name[station_names$stno == station_number]
  
  # Read the CSV file into a temporary dataframe
  temp_data <- read.csv(file)
  
  # Add a new column with the station number
  temp_data$Station <- paste(station_number, station_name)
  yr <- temp_data$YR
  mon <- temp_data$MON
  day <- temp_data$DAY
  
  temp_data$DATE <- as.Date(paste(yr, mon, day, sep = "-"))
  
  # Append the temporary dataframe to the combined dataframe
  combined_data <- rbind(combined_data, temp_data)
}

#calculate annual averages
annual_average <- combined_data %>%
  group_by(Station, year = lubridate::floor_date(DATE, "year")) %>%
  summarize(ffmc_average = mean(FFMC))

#plot them
ggplot(annual_average, aes(x=year, y=ffmc_average, col=Station))+
  geom_line()

#calculate monthly averages
monthly_average <- combined_data %>%
  group_by(Station, month = lubridate::floor_date(DATE, "month")) %>%
  summarize(ffmc_average = mean(FFMC))

#plot them
ggplot(monthly_average, aes(x=month, y=ffmc_average, col=Station))+
  geom_line()

#examine roches point
roches_point <- filter(combined_data, Station == "1004 ROCHES POINT")

ggplot(roches_point, aes(x=DATE, y=))