import pandas as pd
import numpy as np
STATES = ['Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','District of Columbia','Florida','Georgia','Hawaii',
          'Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi',
          'Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio',
          'Oklahoma','Oregon','Pennsylvania','Puerto Rico','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Vermont','Virgin Islands',
          'Washington','West Virginia','Wisconsin','Wyoming']

STATE_FIPS = [1,2,4,5,6,8,9,10,11,12,13,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,72,44,45,46,47,48,49,50,51,78,53,54,55,56]

def state_to_fips(name):
    ind = STATES.index(name)
    return STATE_FIPS[ind]

d_url = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv'
c_url = 'https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv'

ddf = pd.read_csv(d_url,index_col=0,parse_dates=[0])
cdf = pd.read_csv(c_url,index_col=0,parse_dates=[0])

ddf = pd.read_csv ('death.csv')
cdf = pd.read_csv('confirmed.csv')

keys = ['UID','iso2','iso3','code3','FIPS','Admin2','Province_State','Country_Region','Lat','Long_','Combined_Key','Population']
new_ddf = pd.DataFrame(columns = ['c_date','iso2','iso3','code3','FIPS','Province_State','Country_Region','Population','Death'])
new_cdf = pd.DataFrame(columns = ['c_date','iso2','iso3','code3','FIPS','Province_State','Country_Region','Death'])



dates = []
for col in list(ddf):
    if col not in keys:
        dates.append(col)
for state in STATES:
    cur_fip = state_to_fips(state)
    tmp_rows = ddf.iloc[np.where(ddf['Province_State'] == state)]
    row = tmp_rows.head(1)
    pop = tmp_rows['Population'].sum()
    # print(row['iso2'].values[0])
    for date in dates:
        total = tmp_rows[date].sum()
        new_ddf.loc[len(new_ddf.index)] = [date, row['iso2'].values[0], row['iso3'].values[0], row['code3'].values[0], cur_fip,row['Province_State'].values[0],
                                           row['Country_Region'].values[0],pop,total]
new_ddf.to_csv('new_death.csv',index=False)

dates = []
for col in list(cdf):
    if col not in keys:
        dates.append(col)
for state in STATES:
    cur_fip = state_to_fips(state)
    tmp_rows = cdf.iloc[np.where(cdf['Province_State'] == state)]
    row = tmp_rows.head(1)
    for date in dates:
        total = tmp_rows[date].sum()
        new_cdf.loc[len(new_cdf.index)] = [date, row['iso2'].values[0], row['iso3'].values[0], row['code3'].values[0], cur_fip,row['Province_State'].values[0],
                                           row['Country_Region'].values[0],total]
new_cdf.to_csv('new_confirmed.csv',index=False)
