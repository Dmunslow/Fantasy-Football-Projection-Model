# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import pandas as pd
from bs4 import BeautifulSoup
from selenium import webdriver

global driver

driver = webdriver.Chrome("E:\Python Projects\chromedriver.exe")

# create list of weeks and years that we want to scrape data for
weeks = list(range(1,18))
years = list(range(2014, 2018))

def get_salary_url (week, year): 
    
    base = "http://rotoguru1.com/cgi-bin/fyday.pl?"
    
    week = "week=" + str(week)
    
    year = "&year=" + str(year)
    
    end = "&game=dk&scsv=1"
    
    url = base + week + year + end
    
    return url;

#initialize data frame
salary_master_df = pd.DataFrame([])

for y in years:
    for w in weeks:
        url = get_salary_url(w, y)
        
        driver.get(url)

        html = driver.page_source
        
        soup = BeautifulSoup(html, 'html.parser')

        text_split = soup.find('pre').getText().splitlines()
        
        # split data at semi colon to create list of rows and columns
        delimited = [td.split(";") for td in text_split]

        # pull headers from 
        headers = delimited[0]
        delimited = delimited[1:]
        
        new_salary_df = pd.DataFrame(delimited, columns = headers)
        
        salary_master_df = salary_master_df.append(new_salary_df)

## Clean Data -----------------------------------------------------------------
 
salary_master_cleaned = salary_master_df

# Fix team names to match standard

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('nor', 'NO')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('nor', 'NO') 

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('jac', 'JAX')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('jac', 'JAX') 

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('sfo', 'SF')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('sfo', 'SF') 

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('tam', 'TB')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('tam', 'TB') 

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('sdg', 'SD')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('sdg', 'SD') 

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('kan', 'KC')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('kan', 'KC')

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('nwe', 'NE')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('nwe', 'NE')

salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.replace('gnb', 'GB')
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.replace('gnb', 'GB')

## Convert all team names to upper case
salary_master_cleaned['Team'] = salary_master_cleaned['Team'].str.upper()
salary_master_cleaned['Oppt'] = salary_master_cleaned['Oppt'].str.upper()


## fix column names
col_names = salary_master_cleaned.columns.values
col_names = list(map(str.strip, col_names))
col_names = list(map(str.upper, col_names))
col_names = [ x.replace(' ', '_') for x in col_names ]

salary_master_cleaned.columns = col_names

name_data = pd.DataFrame(salary_master_cleaned.NAME.str.split(', ',1).tolist(),
                          columns = ["PLAYER_LAST_NAME",
                                     "PLAYER_FIRST_NAME"])

 # combine split name data 
name_data.reset_index(drop=True, inplace=True)
salary_master_cleaned.reset_index(drop=True, inplace=True)
 
salary_master_cleaned = pd.concat([name_data, salary_master_cleaned.drop("NAME", axis = 1)], axis=1)

# Drop useless home/away column
salary_master_cleaned  =  salary_master_cleaned.drop("H/A", axis = 1)

salary_master_cleaned.to_csv('DK Salary Data - 2014-2017.csv', index = False, header = True)        