# Folder path where the _fwi.csv files are located
library(ggplot2)
library(ggmap)
library(lubridate)

# Folder path where the _fwi.csv files are located
folder_path <- "/home/pflattery/fire/fwi_output_final"

# Get list of _fwi.csv files in the folder
fwi_files <- list.files(path = folder_path, pattern = "_fwi.csv", full.names = TRUE)

# Create an empty data frame to store the circle markers and station numbers
circle_markers <- data.frame(lat = numeric(), lon = numeric(), record_length = numeric(), station_number = character())

# Iterate over each _fwi.csv file
for (fwi_file in fwi_files) {
  # Read the data from the _fwi.csv file
  fwi_data <- read.csv(fwi_file)
  
  # Extract the latitude, longitude, YR, MON, and DAY columns from the data
  lat <- fwi_data$LAT
  lon <- fwi_data$LONG
  yr <- fwi_data$YR
  mon <- fwi_data$MON
  day <- fwi_data$DAY
  
  # Create the date column using YR, MON, and DAY
  date <- as.Date(paste(yr, mon, day, sep = "-"))
  
  # Calculate the record length as the difference between the start and end dates
  record_length <- as.numeric(max(date) - min(date))
  
  # Extract the station number from the CSV file title
  station_number <- gsub("_fwi.csv", "", basename(fwi_file))
  
  # Append circle marker data to the data frame
  circle_markers <- rbind(circle_markers, data.frame(lat = lat, lon = lon, record_length = record_length, station_number = station_number))
}

# Get the bounding box coordinates for the map
bbox <- c(min(circle_markers$lon), min(circle_markers$lat), max(circle_markers$lon), max(circle_markers$lat))

# Get the map image using the bbox coordinates CHANGE MAP TYPE HERE - https://www.nceas.ucsb.edu/sites/default/files/2020-04/ggmapCheatsheet.pdf
map_img <- get_map(location = bbox, source = "stamen", maptype = "watercolor", crop = FALSE)

# Plot the map image
map_plot <- ggmap(map_img)

# Plot the circle markers with green color and station number labels
map_plot <- map_plot +
  geom_point(data = circle_markers, aes(x = lon, y = lat, size = record_length), color = "green") +
  geom_text(data = circle_markers, aes(x = lon, y = lat, label = station_number), color = "black", size = 3) +
  scale_size_continuous(range = c(2, 10))  # Adjust the size range as desired

# Save the map as a JPG image
output_file <- "output_map_4.jpg"

setwd("output_maps/")
ggsave(output_file, map_plot, width = 8, height = 6, dpi = 300)

