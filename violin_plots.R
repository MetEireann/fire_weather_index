#this code takes the FWI output for a station and presents statistics 

library(ggplot2)
library(RJDBC)
library(gridExtra)

#db_conn function for running SQL
source("~/fire/db_conn.R")

station_names <- db_conn(paste("SELECT stno,name 
                          FROM stations"))

station_names$stno <- as.factor(station_names$stno)

#read in the data and combine it 
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



# Filter out stations without data for the full 30-year period
# Group the data by Station
grouped_data <- combined_data %>%
  group_by(Station)

# Filter out stations that don't have data for every year in the 30-year period 1981-2010
filtered_data_1981_2010 <- grouped_data %>%
  filter(all(c(1981:2010) %in% YR)) %>%
  ungroup()

#print the stations 
stations_1981_2010 <- unique(filtered_data_1981_2010$Station)
stations_1981_2010

# Filter out stations that don't have data for every year in the 30-year period 1991-2020
filtered_data_1991_2020 <- grouped_data %>%
  filter(all(c(1991:2020) %in% YR)) %>%
  ungroup()

stations_1991_2020 <- unique(filtered_data_1991_2020$Station)
stations_1991_2020

# Basic violin plot
plot <- ggplot(combined_data, aes(x=Station, y=FFMC, fill=Station)) + 
  geom_violin(trim=FALSE) +
  geom_boxplot(width=0.1, fill="white")+
  theme_classic()

#  violin plots
plot_81_10 <- ggplot(filtered_data_1981_2010, aes(x=Station, y=FFMC, fill=Station)) + 
  geom_violin(trim=FALSE) +
  geom_boxplot(width=0.1, fill="white")+
  labs(x = "Station", y = "FFMC", title = "Fine Fuel Moisture Content (FFMC) at Synoptic Stations 1981-2010") +
  theme_classic()

plot_81_10

plot_91_20 <- ggplot(filtered_data_1991_2020, aes(x=Station, y=FFMC, fill=Station)) + 
  geom_violin(trim=FALSE) +
  geom_boxplot(width=0.1, fill="white")+
  labs(x = "Station", y = "FFMC", title = "Fine Fuel Moisture Content (FFMC) at Synoptic Stations 1991-2020") +
  theme_classic()

plot_91_20

#only plot the stations which match

# Extract the common stations
common_stations <- intersect(filtered_data_1981_2010$Station, filtered_data_1991_2020$Station)

# Filter the data to include only common stations
filtered_data_1981_2010 <- subset(filtered_data_1981_2010, Station %in% common_stations)

# Combine the filtered dataframes
merged_data <- rbind(filtered_data_1981_2010, filtered_data_1991_2020)

# Determine the common y-axis limits for both plots
y_axis_limits <- range(merged_data$FFMC)

# Create the violin plot for 1981-1990 data
plot_1981_2010 <- ggplot(filtered_data_1981_2010, aes(x = Station, y = FFMC, fill = Station)) +
  geom_violin(trim = FALSE, scale = "width") +
  scale_y_continuous(limits = y_axis_limits) +
  labs(x = "Station", y = "FFMC", title = "Violin Plots of FFMC (1981-2010)") +
  theme_minimal() +
  theme(legend.position = "none")

# Create the violin plot for 1991-2020 data
plot_1991_2020 <- ggplot(filtered_data_1991_2020, 
                         aes(x = Station, y = FFMC, 
                             fill = Station)) +
  geom_violin(trim = FALSE, scale = "width") +
  scale_y_continuous(limits = y_axis_limits) +
  labs(x = "Station", y = "FFMC", title = "Violin Plots of FFMC (1991-2020)") +
  theme_minimal()

# Arrange the plots side by side
combined_plot <- grid.arrange(plot_1981_2010, plot_1991_2020, ncol = 2)


