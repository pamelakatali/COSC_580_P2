#mysql --local-infile=1 -u root -p
SHOW DATABASES;
CREATE DATABASE covid_app;
USE covid_app;

CREATE TABLE death_orig (
    iso2 VARCHAR(5),
    iso3 VARCHAR(5),
    code3 INT,
    FIPS INT,
    Province_State VARCHAR(100),
    Country_Region VARCHAR (5),
    c_date DATE,
    Deaths INT
    );

SHOW TABLES;


LOAD DATA LOCAL INFILE 'C:\Users\zetgi\Desktop\Database\new_death.csv' 
INTO TABLE death_orig 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS (@iso2, @iso3, @code3, @FIPS, @Province_State, @Country_Region, @c_Date, @Deaths)
SET c_date  = STR_TO_DATE(@c_date, '%c/%d/%Y'),
	iso3 = if(@iso3="", NULL, @iso3),
	code3 = if(@code3="", NULL, @code3),
	FIPS = if(@FIPS="", NULL, @FIPS),
	Province_State = if(@Province_State="", NULL, @Province_State),
	Country_Region = if(@Country_Region="", NULL, @Country_Region),
	Deaths = if(@Deaths="", NULL, @Deaths);
    

CREATE TABLE Deaths (
	FIPS INT,
    c_date DATE,
	Deaths INT
)
	SELECT FIPS, c_date, Deaths
	FROM death_orig
	WHERE level = 'State';

