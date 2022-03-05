#mysql --local-infile=1 -u root -p
SHOW DATABASES;
CREATE DATABASE covid_app;
USE covid_app;

CREATE TABLE conf_orig (
    iso2 VARCHAR(5),
    iso3 VARCHAR(5),
    code3 INT,
    FIPS INT,
    Province_State VARCHAR(100),
    Country_Region VARCHAR (5),
    Population INT,
    c_date DATE,
    Cases INT
    );

SHOW TABLES;


LOAD DATA LOCAL INFILE 'C:\Users\zetgi\Desktop\Database\new_confirmed.csv' 
INTO TABLE conf_orig 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS (@iso2, @iso3, @code3, @FIPS, @Province_State, @Country_Region, @Population, @c_Date, @Cases)
SET c_date  = STR_TO_DATE(@c_date, '%c/%d/%Y'),
	iso3 = if(@iso3="", NULL, @iso3),
	code3 = if(@code3="", NULL, @code3),
	FIPS = if(@FIPS="", NULL, @FIPS),
	Province_State = if(@Province_State="", NULL, @Province_State),
	Country_Region = if(@Country_Region="", NULL, @Country_Region),
	Population = if(@Population="", NULL, @Population),
	Cases = if(@Cases="", NULL, @Cases);
    
    
CREATE TABLE state_info (
	state_pop_id INT NOT NULL AUTO_INCREMENT,
    FIPS INT,
    population INT,
    PRIMARY KEY (state_pop_id)
)
	SELECT FIPS, population
    FROM conf_orig
    Where level = 'State'
    GROUP BY FIPS, population;
    

CREATE TABLE cases (
	FIPS INT,
    c_date DATE,
	Cases INT
)
	SELECT FIPS, c_date, Cases
	FROM conf_orig
	WHERE level = 'State';

