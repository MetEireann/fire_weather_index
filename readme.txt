SQL queries are difficult for this - but what seems to work is to get the hourly data at 12 using this SQL:

Then using this SQL to get daily sums of rainfall:
SELECT stno, date_trunc('day',date + date('11 hours')) AS date_s, sum(rainfall) AS daily_rain_total FROM hourly WHERE stno = 305 GROUP BY stno, date_trunc('day',date + date('11 hours')) ORDER BY 2

Then use R to join these together. 

This will produce the data that is located in /home/pflattery/fire/output/. Since this is already there and this work has been done previously, 
the SQL in the scripts 'query_database.R' and 'query_database_multiple_stations.R' may have to be changed and may not work. 



The workflow is as follows: 

Download the data from the hourly database 'query_database.R' for a single station and 'query_database_multiple_stations.R' for multiple stations
This produces the raw data for each station in the /output/ folder.

then the scipt 'fwi_calculation.R' and 'fwi_calculation_multiple_stations.R' converts the data from the previous scripts in /output/
into a format suitable for the cffdrs fire weather index package. 

This produces output in '/fwi_output_final/' which contains all the varialbles of the FWI for each station. 

Further exploration and data display is done by 'map_stations_and_record_length.R' which produces a map located in /output_maps/
Similarly 'record_length_dataframe.R' produces a dataframe of the start and end dates for each station and the number of missing days and percentage of total which are missing

