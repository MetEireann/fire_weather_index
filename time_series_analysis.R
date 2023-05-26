#this code takes the FWI output for the synoptic stations and 
#performs time-series analysis 

library(ggplot2)
library(RJDBC)
library(lubridate)
library(dplyr)

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
ggplot(annual_average, aes(x=year, y=ffmc_average, col=Station)) +
  geom_line()

#calculate monthly averages
monthly_average <- combined_data %>%
  group_by(Station, month = lubridate::floor_date(DATE, "month")) %>%
  summarize(ffmc_average = mean(FFMC))

#plot them
ggplot(monthly_average, aes(x=month, y=ffmc_average, col=Station))+
  geom_line()

#examine roches point as it looks very dodgy
roches_point <- filter(combined_data, Station == "1004 ROCHES POINT")

ggplot(roches_point, aes(x=DATE, y=FFMC)) +
  geom_line()

knock_airport <- filter(combined_data, Station == "4935 KNOCK AIRPORT")

ggplot(knock_airport, aes(x=DATE, y=FFMC)) +
  geom_line()



claremorris <- filter(combined_data, Station == "2727 CLAREMORRIS")

ggplot(claremorris, aes(x=DATE, y=FFMC)) +
  geom_line()


# Filter and plot for each station
unique_stations <- unique(combined_data$Station)

for (station in unique_stations) {
  station_data <- filter(combined_data, Station == station)
  
  plot <- ggplot(station_data, aes(x = DATE, y = FFMC)) +
    geom_line() +
    labs(title = paste("Station:", station))
  
  # Display the plot
  print(plot)
}


#save them 
for (station in unique_stations) {
  station_data <- filter(combined_data, Station == station)
  
  plot <- ggplot(station_data, aes(x = DATE, y = FFMC)) +
    geom_line() +
    labs(title = paste("Station:", station))
  
  # Save the plot as a PNG file
  plot_file <- paste0("ffmc_timeseries_plots/ffmc_plot_", station, ".png")
  ggsave(plot_file, plot, width = 10, height = 6)
}


