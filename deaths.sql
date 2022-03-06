#mysql --local-infile=1 -u root -p
SET SQL_SAFE_UPDATES = 0;

USE covid_app;
drop table death_orig;
CREATE TABLE death_orig (
    c_date VARCHAR(50),
    iso2 VARCHAR(5),
    iso3 VARCHAR(5),
    code3 INT,
    FIPS INT,
    Province_State VARCHAR(100),
    Country_Region VARCHAR (5),
    Population INT,
    Death INT
    );



LOAD DATA LOCAL INFILE 'C:/Users/zetgi/Desktop/Database/new_death.csv' 
INTO TABLE death_orig 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
;
UPDATE death_orig SET c_date = STR_TO_DATE(c_date, '%m/%d/%Y');
select * from death_orig;


drop table state_info;
create table state_info(
	FIPS INT,
    Population INT
    )
		select FIPS, Population
        from death_orig
        group by fips, population;
select * from state_info;

CREATE TABLE Deaths (
	FIPS INT,
    c_date DATE,
	Deaths INT
)
	SELECT FIPS, c_date, Deaths
	FROM death_orig;

