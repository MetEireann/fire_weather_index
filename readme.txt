The data input for the Fire Weather Index requires rainfall sums from 12pm-12pm, which is non-daily (see here: http://reaserve/trac/wiki/NonDailyRainfall).

Conor Lally came up with this sql query which gives 12-12 sum or rainfall along with the date and other variables at 12pm (this example is for stno=305). 

SELECT a.stno, a.date, a.year, a.month, a.day, a.hour, a.speed as wind_speed, a.drybulb as temperature, a.rh as humidity, b.daily_rain_total 
        FROM (select stno, date, year, month, day, hour, speed, drybulb, rh from hourly where stno = 305 and hour = 12) a,  
        (SELECT stno, date_trunc('day',date + date('11 hours')) AS date_s, round(sum(rainfall),1) AS daily_rain_total 
                FROM hourly 
                WHERE stno = 305
                GROUP BY stno, date_trunc('day',date + date('11 hours'))) b 
        WHERE a.stno = b.stno 
                AND a.year = DATE_PART('YEAR',b.date_s)
                AND a.month = DATE_PART('MONTH',b.date_s)
                AND a.day = DATE_PART('DAY',b.date_s)
        ORDER BY a.date


The workflow is as follows: 

Download the data from the hourly database 'query_database.R' for a single station and 'query_database_multiple_stations.R' for multiple stations
This produces the raw data for each station in the /output/ folder.

then the scipt 'fwi_calculation.R' and 'fwi_calculation_multiple_stations.R' converts the data from the previous scripts in /output/
into a format suitable for the cffdrs fire weather index package. 

This produces output in '/fwi_output_final/' which contains all the varialbles of the FWI for each station. 

Further exploration and data display is done by 'map_stations_and_record_length.R' which produces a map located in /output_maps/
Similarly 'record_length_dataframe.R' produces a dataframe of the start and end dates for each station and the number of missing days and percentage of total which are missing. 

violin_plots.R produces violin plots (boxplots and Probability Density Functions combined) for the FFMC variable at different timesteps. 

correlations.R does a correlation matrix for all variables at each station 
