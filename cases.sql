USE covid_app;

SET SQL_SAFE_UPDATES = 0;
CREATE TABLE conf_orig (
    c_date VARCHAR(50),
    iso2 VARCHAR(5),
    iso3 VARCHAR(5),
    code3 INT,
    FIPS INT,
    Province_State VARCHAR(100),
    Country_Region VARCHAR (5),
    Cases INT
    );

LOAD DATA local INFILE 'C:/Users/zetgi/Desktop/Database/new_confirmed.csv' 
INTO TABLE conf_orig 
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\n' 
IGNORE 1 ROWS
;
UPDATE conf_orig SET c_date = STR_TO_DATE(c_date, '%m/%d/%Y');
select *from conf_orig;

CREATE TABLE cases (
	FIPS INT,
    c_date VARCHAR(50),
	Cases INT
)
	SELECT FIPS, c_date, Cases
	FROM conf_orig;
show tables;
select *from cases;