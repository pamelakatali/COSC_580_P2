#For finding the percentage of death rate per state.
#Uncomment part below if you haven’t created the table already.

/*create table case_death select state_code_info.state_code, state_date_info.row_date, cases.cases, deaths.deaths 
from (((cases 
join deaths on cases.state_date_id = deaths.state_date_id)
join state_date_info on state_date_info.state_date_id = cases.state_date_id)
join state_code_info on state_code_info.state_fips = state_date_info.state_fips)
order by state_code, row_date;*/

with d_rate as 
(SELECT  state_code,
		Max(deaths) as deaths,
		Max(cases) as confirmed_cases
FROM case_death
GROUP BY state_code)
SELECT  state_code, 
		Round((deaths/confirmed_cases)*100, 2) AS death_rate
FROM d_rate
ORDER BY death_rate DESC;

#For knowing the top 10 states with highest number of cases over the period of last one week. 
#Can we used for even a month,day, year time period.
use covid_app;
drop table temp;
create table temp select state_date_info.state_date_id,  state_date_info.row_date, state_date_info.state_fips, cases.cases from ((state_date_info  join cases on state_date_info.state_date_id = cases.state_date_id)
join state_code_info on state_code_info.state_fips = state_date_info.state_fips)
where date(state_date_info.row_date) > DATE_SUB(date('2022-02-05'), INTERVAL 1 WEEK);



select sum(cases) as total_cases, state_code_info.state_code from (temp join state_code_info on 
state_code_info.state_fips = temp.state_fips) group by temp.state_fips order by total_cases desc  limit 10;

#finding when covid peaked with respect to state.
WITH c_peak AS
(SELECT  state_code,
		 row_date,
		 cases,
		 AVG(cases) OVER (PARTITION BY row_date) as Spike,
		 DENSE_RANK() OVER (PARTITION BY row_date ORDER BY cases DESC) AS rnk
FROM case_death)
SELECT  state_code,
		row_date,
		ROUND(Spike,2) as AvgCasesPeak
FROM c_peak
WHERE rnk = 1 AND cases >3000
ORDER BY row_date;
