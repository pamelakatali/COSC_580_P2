#mysql --local-infile=1 -u root -p
SHOW DATABASES;
#CREATE DATABASE covid_app;
#SET SQL_SAFE_UPDATES = 0;
#USE covid_app;

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


LOAD DATA LOCAL INFILE '/Users/pamelakatali/Downloads/school/COSC580/trips.csv' 
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
	trips_500 = if(@trips_1="", NULL, @trips_500),
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

CREATE TABLE trips_agg (
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


CREATE TABLE trips (
	state_date_id INT,
	pop_stay_at_home INT, 
    pop_not_stay_at_home INT,
    trips_total INT,
    trips_5 INT,
    trips_5_50 INT,
    trips_50_250 INT,
    trips_250 INT
)
	SELECT state_date_info.state_date_id, trips_agg.pop_stay_at_home, trips_agg.pop_not_stay_at_home, trips_agg.trips_total,
	trips_agg.trips_5, trips_agg.trips_5_50, trips_agg.trips_50_250, trips_agg.trips_250
	FROM trips_agg
	LEFT JOIN state_date_info
	ON trips_agg.state_fips = state_date_info.state_fips and trips_agg.row_date = state_date_info.row_date ;

#select *
#from state_date_info;

CREATE TABLE deaths_raw (
    c_date VARCHAR(50),
    iso2 VARCHAR(5),
    iso3 VARCHAR(5),
    code3 INT,
    state_fips INT,
    province_state VARCHAR(100),
    country_cegion VARCHAR (5),
    population INT,
    deaths INT
    );

LOAD DATA LOCAL INFILE '/Users/pamelakatali/Downloads/school/COSC580/deaths_clean.csv' 
INTO TABLE deaths_raw 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

UPDATE deaths_raw SET c_date = STR_TO_DATE(c_date, '%m/%d/%Y');
SELECT * 
FROM deaths_raw;


create table state_info(
	state_fips INT,
    population INT
    )
		select state_fips, population
        from deaths_raw
        group by state_fips, population;

#select * from state_info;

#select * from deaths_raw;


CREATE TABLE deaths (
	state_date_id INT,
	deaths INT
)
	SELECT state_date_info.state_date_id, deaths_raw.deaths
	FROM deaths_raw
    LEFT JOIN state_date_info
	ON deaths_raw.state_fips = state_date_info.state_fips and deaths_raw.c_date = state_date_info.row_date; 
    

#select * from deaths;

CREATE TABLE cases_raw (
    c_date VARCHAR(50),
    iso2 VARCHAR(5),
    iso3 VARCHAR(5),
    code3 INT,
    state_fips INT,
    province_state VARCHAR(100),
    country_region VARCHAR (5),
    cases INT
    );


LOAD DATA local INFILE '/Users/pamelakatali/Downloads/school/COSC580/cases_clean.csv' 
INTO TABLE cases_raw 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS;

UPDATE cases_raw SET c_date = STR_TO_DATE(c_date, '%m/%d/%Y');

SELECT *
FROM cases_raw;


CREATE TABLE cases (
	state_date_id INT,
	cases INT
)
	SELECT state_date_info.state_date_id, cases_raw.cases
	FROM cases_raw
	LEFT JOIN state_date_info
	ON cases_raw.state_fips = state_date_info.state_fips and cases_raw.c_date = state_date_info.row_date;


SELECT *
FROM cases;


CREATE TABLE tests_raw (    
    tests_date VARCHAR(50),
    state_code VARCHAR(3),
    cases_conf_probable INT,
    cases_confirmed INT,
    cases_probable INT,
    tests_viral_positive INT,
    tests_viral_negative INT,
    tests_viral_total INT,
    tests_antigen_positive INT,
    tests_antigen_total INT,
    people_viral_positive INT,
    people_viral_total INT,
    people_antigen_positive INT,
    people_antigen_total INT,
    encounters_viral_total INT,
    tests_combined_total INT
    );



LOAD DATA local INFILE '/Users/pamelakatali/Downloads/school/COSC580/tests.csv' 
INTO TABLE tests_raw 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS (@tests_date,state_code,@cases_conf_probable,@cases_confirmed,@cases_probable,
@tests_viral_positive,@tests_viral_negative,@tests_viral_total,@tests_antigen_positive,
@tests_antigen_total,@people_viral_positive,@people_viral_total,@people_antigen_positive,
@people_antigen_total,@encounters_viral_total,@tests_combined_total)
SET tests_date  = STR_TO_DATE(@tests_date, '%c/%d/%Y'), 
cases_conf_probable = if(@cases_conf_probable="", NULL, @cases_conf_probable),
cases_confirmed = if(@cases_confirmed="", NULL, @cases_confirmed),
cases_probable = if(@cases_probable="", NULL, @cases_probable),
tests_viral_positive = if(@tests_viral_positive="", NULL, @tests_viral_positive),
tests_viral_negative = if(@tests_viral_negative="", NULL, @tests_viral_negative),
tests_viral_total = if(@tests_viral_total="", NULL, @tests_viral_total),
tests_antigen_positive = if(@tests_antigen_positive="", NULL, @tests_antigen_positive),
people_viral_positive = if(@people_viral_positive="", NULL, @people_viral_positive),
people_viral_total = if(@people_viral_total="", NULL, @people_viral_total),
people_antigen_positive = if(@people_antigen_positive="", NULL, @people_antigen_positive),
people_antigen_total = if(@people_antigen_total="", NULL, @people_antigen_total),
encounters_viral_total = if(@encounters_viral_total="", NULL, @encounters_viral_total),
tests_combined_total = if(@tests_combined_total="", NULL, @tests_combined_total);

SELECT *
FROM tests_raw;

SELECT  a.state_fips, tests_raw.tests_date,tests_raw.state_code, tests_raw.tests_combined_total
FROM tests_raw
LEFT JOIN 
(SELECT DISTINCT state_fips, state_code 
FROM trips_raw
WHERE state_code != '') a
ON tests_raw.state_code = a.state_code;


CREATE TABLE tests_agg (    
	state_fips INT,
    tests_date DATE,
    state_code VARCHAR(3),
    tests_total INT
)
	SELECT  state_code_info.state_fips, tests_raw.tests_date,tests_raw.state_code, tests_raw.tests_combined_total tests_total
	FROM tests_raw
	LEFT JOIN state_code_info
	ON tests_raw.state_code = state_code_info.state_code;

select * from tests_agg;


CREATE TABLE tests (    
	state_date_id INT,
    tests_total INT
)
	SELECT state_date_info.state_date_id, tests_agg.tests_total
	FROM tests_agg
	LEFT JOIN state_date_info
	ON tests_agg.state_fips = state_date_info.state_fips and tests_agg.tests_date = state_date_info.row_date; 


CREATE TABLE vaccines_raw (    
	state VARCHAR(50),
    row_date DATE,
    vacc_type VARCHAR(50),
    state_fips INT,
    country_region VARCHAR(5),
    lat_coor DOUBLE,
    long_coor DOUBLE,
    doses_alloc INT,
    doses_shipped INT,
    doses_admin INT,
    stage_one_doses INT,
    stage_two_doses INT,
    combined_key VARCHAR(20)
    );



LOAD DATA local INFILE '/Users/pamelakatali/Downloads/school/COSC580/vaccines.csv' 
INTO TABLE vaccines_raw 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS (	state, @row_date, @vacc_type, state_fips, country_region, lat_coor,
long_coor, @doses_alloc, @doses_shipped, doses_admin, @stage_one_doses, @stage_two_doses,
combined_key)
SET row_date  = STR_TO_DATE(@row_date, '%Y-%c-%d'), 
vacc_type = if(@vacc_type="", NULL, @vacc_type),
doses_shipped = if(@doses_shipped="", NULL, @doses_shipped),
doses_alloc = if(@doses_alloc="", NULL, @doses_alloc),
stage_one_doses = if(@stage_one_doses="", NULL, @stage_one_doses),
stage_two_doses = if(@stage_two_doses="", NULL, @stage_two_doses);


select * from vaccines_raw;

CREATE TABLE vaccines (    
	state_date_id INT,
    doses_admin INT,
    vacc_type VARCHAR(25),
    stage_one_doses INT,
    stage_two_doses INT
)
	SELECT state_date_info.state_date_id, vaccines_raw.doses_admin, vaccines_raw.vacc_type, 
    vaccines_raw.stage_one_doses, vaccines_raw.stage_two_doses
	FROM vaccines_raw
	LEFT JOIN state_date_info
	ON vaccines_raw.state_fips = state_date_info.state_fips and vaccines_raw.row_date = state_date_info.row_date; 

SELECT * FROM vaccines;

/*
 state_fips
 abrr from tests
 vaccines_Raw data truncated
 vaccines - null state_date_id

mysql> SET GLOBAL local_infile=1;
mysql> SHOW GLOBAL VARIABLES LIKE 'local_infile';

*/