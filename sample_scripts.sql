USE covid_app;
show tables;


## create temporary table case_death which combines cases and deaths which will be dropped after analysis.
create table case_death select state_code_info.state_code, state_date_info.row_date, cases.cases, deaths.deaths 
from (((cases 
join deaths on cases.state_date_id = deaths.state_date_id)
join state_date_info on state_date_info.state_date_id = cases.state_date_id)
join state_code_info on state_code_info.state_fips = state_date_info.state_fips)
order by state_code, row_date;

##select * from case_death;

## wanted to see which date had most cases for each state. but it won't work because it only gives total number of cases.
## will need to change it to number of case increase per date

## get max cases for each state
SELECT state_code, row_date, cases
FROM case_death WHERE (state_code,cases) IN 
( SELECT state_code, MAX(cases)
  FROM case_death
  GROUP BY state_code
);
## get max deaths for each state
SELECT state_code, row_date, deaths
FROM case_death WHERE (state_code,deaths) IN 
( SELECT state_code, MAX(deaths)
  FROM case_death
  GROUP BY state_code
);
## compare number of test administered to number of positive cases
select state_code, row_date, tests_total, cases
from (((tests
join cases on tests.state_date_id = cases.state_date_id)
join state_date_info on state_date_info.state_date_id = tests.state_date_id)
join state_code_info on state_code_info.state_fips = state_date_info.state_fips)
order by state_code, row_date;

## compare number of trips taken with number of positive cases and vaccine numbers
select state_code, row_date, pop_stay_at_home, cases, stage_one_doses, stage_two_doses
from ((((trips
join cases on trips.state_date_id = cases.state_date_id)
join vaccines on trips.state_date_id = vaccines.state_date_id)
join state_date_info on trips.state_date_id = state_date_info.state_date_id)
join state_code_info on state_date_info.state_fips = state_code_info.state_fips)
where vacc_type='All'
order by state_code, row_date;

select state_code, row_date, deaths, stage_one_doses, stage_two_doses
from (((deaths
join vaccines on deaths.state_date_id = vaccines.state_date_id)
join state_date_info on deaths.state_date_id = state_date_info.state_date_id)
join state_code_info on state_date_info.state_fips = state_code_info.state_fips)
where vacc_type='All'
order by state_code, row_date;

## get number of cases increase from previous date
create table deaths_count
SELECT 	
  state_code,
  row_date,
  deaths - LAG(deaths)
    OVER (ORDER BY state_code,row_date ) AS diff_death
FROM case_death;

## get number of deaths increase from previous date
create table cases_count 
SELECT 
  state_code,
  row_date,
  cases - LAG(cases)
    OVER (ORDER BY state_code,row_date ) AS diff_cases
FROM case_death;

## find the date with max number of deaths (increase)
SELECT state_code, row_date, diff_death
FROM deaths_count WHERE (state_code,diff_death) IN 
( SELECT state_code, MAX(diff_death)
  FROM deaths_count
  GROUP BY state_code
);

## find the date with max number of cases (increase)
SELECT state_code, row_date, diff_cases
FROM cases_count WHERE (state_code,diff_cases) IN 
( SELECT state_code, MAX(diff_cases)
  FROM cases_count
  GROUP BY state_code
);

