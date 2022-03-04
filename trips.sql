#mysql --local-infile=1 -u root -p
SHOW DATABASES;
CREATE DATABASE covid_app;
USE covid_app;

CREATE TABLE trips_raw (
	level VARCHAR(30), 
	row_date DATE, 
	state_fips INT,
	state_code VARCHAR(3),
	county_fips INT,
	county_name VARCHAR(100),
	pop_stay_at_home INT, 
	pop_not_stay_at_home INT, 
	trips_total INT, 
	trips_1 INT,
	trips_1_3 INT,
	trips_3_5 INT,
	trips_5_10 INT,
	trips_10_25 INT,
	trips_25_50 INT,
	trips_50_100 INT,
	trips_100_250 INT,
	trips_250_500 INT,
	trips_500 INT,
	row_id VARCHAR(30) NOT NULL,
	week INT,
	month INT);

SHOW TABLES;


LOAD DATA LOCAL INFILE '/Users/pamelakatali/Downloads/school/COSC580/Trips_by_Distance.csv' 
INTO TABLE trips_raw 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS (level, @row_date, @state_fips, state_code, @county_fips,
@county_name, @pop_stay_at_home, @pop_not_stay_at_home, @trips_total, @trips_1, @trips_1_3,
@trips_3_5, @trips_5_10, @trips_10_25, @trips_25_50, @trips_50_100, @trips_100_250, @trips_250_500,
@trips_500, row_id, week, month)
SET row_date  = STR_TO_DATE(@row_date, '%Y/%c/%d'),
	state_fips = if(@state_fips="", NULL, @state_fips),
	county_name = if(@county_name="", NULL, @county_name),
	trips_500 = if(@trips_1="", NULL, @trips_500
	pop_stay_at_home = if(@pop_stay_at_home="", NULL, @pop_stay_at_home),
	pop_not_stay_at_home = if(@pop_not_stay_at_home="", NULL, @pop_not_stay_at_home),
	trips_total = if(@trips_total="", NULL, @trips_total),
	trips_1 = if(@trips_1="", NULL, @trips_1),
	trips_1_3 = if(@trips_1_3="", NULL, @trips_1_3),
	trips_3_5 = if(@trips_3_5="", NULL, @trips_3_5),
	trips_5_10 = if(@trips_5_10="", NULL, @trips_5_10),
	trips_10_25 = if(@trips_10_25="", NULL, @trips_10_25),
	trips_25_50 = if(@trips_25_50="", NULL, @trips_25_50),
	trips_50_100 = if(@trips_50_100="", NULL, @trips_50_100),
	trips_100_250 = if(@trips_100_250="", NULL, @trips_100_250),
	trips_250_500 = if(@trips_250_500="", NULL, @trips_250_500),
	trips_500 = if(@trips_500="", NULL, @trips_500);


CREATE TABLE state_date_info (
	state_date_id INT NOT NULL AUTO_INCREMENT, 
	state_fips INT,
    row_date DATE,
	PRIMARY KEY (state_date_id)
)
	SELECT state_fips, row_date
	FROM trips_raw
	WHERE level = 'State'
	GROUP BY state_code, state_fips, row_date;

CREATE TABLE trips (
	state_fips INT,
    row_date DATE,
	pop_stay_at_home INT, 
    pop_not_stay_at_home INT,
    trips_total INT,
    trips_5 INT,
    trips_5_50 INT,
    trips_50_250 INT,
    trips_250 INT
)
	SELECT state_fips, row_date, pop_stay_at_home, pop_not_stay_at_home, trips_total,
			trips_1 + trips_1_3 + trips_3_5	as trips_5,
			trips_5_10 + trips_10_25 + trips_25_50 as trips_5_50,
			trips_50_100 + trips_100_250 as trips_50_250,
			trips_250_500 + trips_500 as trips_250
	FROM trips_raw
	WHERE level = 'State';

