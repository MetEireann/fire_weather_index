#in 2023 the rainfall column created NA values. You are therefore using the 
#data from 2021 in the location /home/pflattery/fire/output

library(tidyverse)
library(dplyr)
library(cffdrs)
library(renv)
library(lubridate)
library(RJDBC)

#db_conn function for running SQL
source("~/fire/db_conn.R")

#read in the station data
lat_lon <- db_conn(paste("SELECT stno,lat_d, long_d 
                          FROM stations"))

calculate_fwi <- function(folder_path, output_folder) {
  # Get list of CSV files in the folder
  csv_files <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)
  
  # Iterate over each CSV file
  for (csv_file in csv_files) {
    # Read in data for one station
    data <- read.csv(csv_file)
    
    # Assuming lat_lon is already defined
    data <- left_join(data, lat_lon, by = "stno")
    
    # Clean the column names up
    clean_data <- rename(data, temp = Temperature..C., rh = Relative.Humidity...., 
                         ws = Windspeed..knots.,
                         prec = Total.Rain..mm., 
                         long = long_d,
                         lat = lat_d)
    
    # Convert windspeed from knots to km/h
    clean_data$ws <- clean_data$ws * 1.852
    
    # Create day, month, and year columns
    clean_data$date <- as.Date(clean_data$date)
    clean_data$yr <- year(clean_data$date)
    clean_data$mon <- month(clean_data$date)
    clean_data$day <- day(clean_data$date)
    
    # Drop the NA rows (FWI calculation doesn't work with NA values)
    clean_data_no_na <- clean_data %>% drop_na()
    
    # Select only the relevant columns
    final_data <- clean_data_no_na %>% dplyr::select(long, lat, yr, mon, day, temp, rh, ws, prec)
    
    # Perform the FWI calculation
    fwi_out_test <- round(fwi(final_data), 2)
    
    # Get the station name from the file name
    station_name <- tools::file_path_sans_ext(basename(csv_file))
    
    # Construct the output file path
    output_file <- paste0(output_folder, "/", station_name, "_fwi.csv")
    
    # Write the result to a CSV file
    write.csv(fwi_out_test, output_file, row.names = FALSE)
  }
}

#define the folder paths for input and output folders
folder_path <- "/home/pflattery/fire/output/"
output_folder <- "/home/pflattery/fire/fwi_output_final/"

#run the calculation 
calculate_fwi(folder_path, output_folder)
