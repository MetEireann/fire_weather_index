#correlation plots
library(corrplot)
library(data.table)
library(RJDBC)
library(tidyverse)

#db_conn function for running SQL
source("~/fire/db_conn.R")

#get station names for labelling later
station_names <- db_conn(paste("SELECT stno,name 
                          FROM stations"))

station_names$stno <- as.factor(station_names$stno)

full_station_name <- station_names[station_name == station_names$station_name, stno]


#read in the fwi data
folder_path <- "/home/pflattery/fire/fwi_output_final"

file_list <- list.files(folder_path, full.names = TRUE)

station_532 <- read.csv("fwi_output_final/532_fwi.csv")

# Select columns to exclude (e.g., "long" and "lat")
columns_to_exclude <- c("LONG", "LAT")

# Exclude the specified columns from the dataframe
data_subset <- station_532[, !(names(station_532) %in% columns_to_exclude)]

cor_matrix <- cor(data_subset)

corrplot(cor_matrix, method = "color", type = "lower", tl.col = "black")


#do all the files together 
# Install corrplot package if not already installed
# install.packages("corrplot")

# Load required libraries
library(corrplot)
library(data.table)
library(ggplot2)

# Specify the folder path containing the CSV files
folder_path <- "/home/pflattery/fire/fwi_output_final"

# Get the list of files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)

# Read and process each file in the folder
for (file in file_list) {
  # Extract the station name from the file name
  station_name <- sub("^.*/(\\d+)_fwi.csv$", "\\1", file)
  
  # Read the CSV file
  fire_data <- fread(file)
  
  # Select columns to exclude (e.g., "long" and "lat")
  columns_to_exclude <- c("LONG", "LAT", "YR")
  
  # Exclude the specified columns from the dataframe
  data_subset <- fire_data[, !(names(fire_data) %in% columns_to_exclude), with = FALSE]
  
  # Compute correlation matrix
  cor_matrix <- cor(data_subset)
  
  # Create a correlation plot for the station
  corrplot(cor_matrix, method = "color", type = "lower", tl.col = "black")
  
  # Add a title with the station name
  title(main = paste("Correlation Map of Fire Weather Index - Station", station_name), line = -2)
}


#try with better station names: 
# Read and process each file in the folder
for (file in file_list) {
  # Extract the station number from the file name
  station_number <- sub("^.*/(\\d+)_fwi.csv$", "\\1", file)
  
  # Find the matching station name from the station_names dataframe
  station_name <- station_names$name[station_names$stno == station_number]
  
  # Read the CSV file
  fire_data <- fread(file)
  
  # Select columns to exclude (e.g., "LONG" and "LAT")
  columns_to_exclude <- c("LONG", "LAT", "YR")
  
  # Exclude the specified columns from the dataframe
  data_subset <- fire_data[, !(names(fire_data) %in% columns_to_exclude), with = FALSE]
  
  # Compute correlation matrix
  cor_matrix <- cor(data_subset)
  
  # Create a correlation plot for the station
  corrplot(cor_matrix, method = "color", type = "lower", tl.col = "black")
  
  # Add a title with the better station name
  title(main = paste("Correlation Map of Fire Weather Index -", 
                     station_name, 
                     station_number), line = -2)
}
