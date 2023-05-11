#this code queries the output from the FWI calculation, and shows the start and 
#end date, the number of miissing days, and the percentage of missing days. 


#note - missing data has already been removed, so some stations e.g. 175 
#phoenix park, has very little wind speed data, meaning most of its 
#records have been dropped. 

library(lubridate)
library(RJDBC)
library(tidyverse)

#db_conn function for running SQL
source("~/fire/db_conn.R")

station_names <- db_conn(paste("SELECT stno,name 
                          FROM stations"))

station_names$stno <- as.factor(station_names$stno)

# Folder path where the _fwi.csv files are located
folder_path <- "/home/pflattery/fire/fwi_output_final"

# Get list of _fwi.csv files in the folder
fwi_files <- list.files(path = folder_path, pattern = "_fwi.csv", full.names = TRUE)

# Create an empty dataframe to store the start and end dates, number of missing days, and percentage of missing days
record_info <- data.frame(station_number = character(), start_date = Date(), end_date = Date(), missing_days = numeric(), percentage_missing_days = numeric(), stringsAsFactors = FALSE)

# Iterate over each _fwi.csv file
for (fwi_file in fwi_files) {
  # Extract the station number from the CSV file title
  station_number <- gsub("_fwi.csv", "", basename(fwi_file))
  
  # Read the data from the _fwi.csv file
  fwi_data <- read.csv(fwi_file)
  
  # Extract the YR, MON, and DAY columns from the data
  yr <- fwi_data$YR
  mon <- fwi_data$MON
  day <- fwi_data$DAY
  
  # Create the date column using YR, MON, and DAY
  date <- as.Date(paste(yr, mon, day, sep = "-"))
  
  # Calculate the start and end dates
  start_date <- min(date)
  end_date <- max(date)
  
  # Calculate the number of missing days and the percentage of missing days
  total_days <- as.integer(difftime(end_date, start_date, units = "days")) + 1
  available_days <- length(unique(date))
  missing_days <- total_days - available_days
  percentage_missing_days <- (missing_days / total_days) * 100
  
  # Add the record information to the dataframe
  record_info <- rbind(record_info, data.frame(station_number = station_number, start_date = start_date, end_date = end_date, missing_days = missing_days, percentage_missing_days = percentage_missing_days))
}

# Print the record information dataframe
record_info$percentage_missing_days <- round(record_info$percentage_missing_days, 2)


record_info$years_diff <- time_length(difftime(record_info$end_date, 
                                   record_info$start_date), 
                          "years")  # Calculate difference in years

#rename the column so it can be joined
record_info <- record_info %>% 
  rename("stno" = "station_number")

#join the stations together 
record_info_with_names <- left_join(record_info, station_names, by="stno")

