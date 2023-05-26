# Load required libraries
library(ggplot2)
library(dplyr)
library(RJDBC)


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

# Assuming your dataframe is named 'weather_data' and contains columns: Stations, Temperature, Windspeed, Rainfall, FFMC, FWI

# Compute dataset lengths for each station
dataset_lengths <- combined_data %>%
  group_by(Station) %>%
  summarize(dataset_length = n(),
            start_date = min(DATE),
            end_date = max(DATE))

# Plotting the dataset lengths
ggplot(dataset_lengths, aes(x = Station, y = dataset_length, fill = dataset_length)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Station", y = "Dataset Length", fill = "Dataset Length") +
  geom_text(aes(label = paste(start_date, end_date, sep = " - ")), vjust = 0.5, size = 5, angle = 90, color = "red")

# Compute missing data proportions for each variable and station
missing_data_proportions <- combined_data %>%
  group_by(Station) %>%
  summarize(
    Temperature_missing = sum(is.na(TEMP)) / n(),
    Windspeed_missing = sum(is.na(WS)) / n(),
    Rainfall_missing = sum(is.na(PREC)) / n(),
    FFMC_missing = sum(is.na(FFMC)) / n(),
    FWI_missing = sum(is.na(FWI)) / n()
  )

# Combine the two summaries
summary_data <- merge(dataset_lengths, missing_data_proportions, by = "Station")

# Plotting the dataset lengths
ggplot(summary_data, aes(x = Station, y = dataset_length, fill = dataset_length)) +
  geom_bar(stat = "identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Stations", y = "Dataset Length", fill = "Dataset Length")

# Plotting the missing data proportions
ggplot(summary_data, aes(x = Stations)) +
  geom_bar(aes(y = Temperature_missing), fill = "blue", alpha = 0.5, position = "stack") +
  geom_bar(aes(y = Windspeed_missing), fill = "green", alpha = 0.5, position = "stack") +
  geom_bar(aes(y = Rainfall_missing), fill = "red", alpha = 0.5, position = "stack") +
  geom_bar(aes(y = FFMC_missing), fill = "orange", alpha = 0.5, position = "stack") +
  geom_bar(aes(y = FWI_missing), fill = "purple", alpha = 0.5, position = "stack") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Stations", y = "Missing Data Proportion", fill = "Variable") +
  scale_y_continuous(labels = scales::percent_format())

# Note: You may need to customize the plot parameters and colors based on your preferences.
