# -*- coding: utf-8 -*-
"""
Created on Sat Aug  4 22:05:13 2018

@author: Duncan
"""
import pandas as pd
import numpy as np
from bs4 import BeautifulSoup

from selenium import webdriver
from selenium.webdriver.support.ui import Select

##  allow druver to be used in get_snap_count_page function
global driver 

## positions for snap count stats
positions = ["RB", "WR", "TE"]

#initialize weeks data frame for regular season weeks only
weeks = list(np.arange(1, 18, 1))

seasons = ["2016","2017"]

 # snap counts page url
url = "https://www.footballoutsiders.com/stats/snapcounts"

driver = webdriver.Chrome("E:\Python Projects\chromedriver.exe")

driver.get(url)

def get_snap_count_page (pos, week, year): 
    
    ## select WR position
    s1 = Select(driver.find_element_by_name("pos"))
    s1.select_by_visible_text(pos)
    
    ## select week 1
    s2 = Select(driver.find_element_by_name("week"))
    s2.select_by_visible_text(week)
    
    ## select year
    s3 = Select(driver.find_element_by_name("year"))
    s3.select_by_visible_text(year)
    
    #submit data
    driver.find_element_by_name("Submit").click()
    return;


#initialize DF
master_df = pd.DataFrame([])

## iterate through position, season and week combos to get all desired data
for p in positions :
    for y in seasons:
        for w in weeks:
            get_snap_count_page(p, str(w), y)

            html = driver.page_source

            soup = BeautifulSoup(html, 'html.parser')

            table = soup.find('table', id = "dataTable") # grab first table

            column_headers = [th.getText() for th in
                      table.findAll('tr')[0].findAll('th')]


            data_rows = table.findAll('tr')[1:]
     
        
            player_data = [[td.getText() for td in data_rows[i].findAll('td')]
                            for i in range(len(data_rows))]        
            
            df = pd.DataFrame(player_data, columns = column_headers)

            # separate player number, player First initials, and player last name
            name_data = pd.DataFrame(df.Player.str.split(r'[-.]',2).tolist(),
                                     columns = ["player_number", 
                                                "player_FI", 
                                                "player_last_name"])

            # combine split name data 
            df = pd.concat([name_data, df.drop("Player", axis = 1)], axis=1)

            # add week and season column
            df['Season'] = y
            df['Week'] = w
           
            #append new data to old dataframe
            master_df = master_df.append(df)

#fix column names - trim trailing spaces, replace remaining spaces with underscore
# convert to all upper case
            
col_names = master_df.columns.values
col_names = list(map(str.strip, col_names))
col_names = list(map(str.upper, col_names))
col_names = list(map(str.replace(' ', '_'), col_names))
col_names = [ x.replace(' ', '_') for x in col_names ]

#assign col names to master_df
master_df.columns = col_names

# get rid of pct, add decimal place
master_df["OFF_SNAP_PCT"] = master_df["OFF_SNAP_PCT"].str.replace('%', '')
master_df["DEF_SNAP_PCT"] = master_df["DEF_SNAP_PCT"].str.replace('%', '')
master_df["ST_SNAP_PCT"] = master_df["ST_SNAP_PCT"].str.replace('%', '')

master_df["OFF_SNAP_PCT"] = '.' + master_df["OFF_SNAP_PCT"].astype(str) 
master_df["DEF_SNAP_PCT"] = '.' + master_df["DEF_SNAP_PCT"].astype(str) 
master_df["ST_SNAP_PCT"] = '.' + master_df["ST_SNAP_PCT"].astype(str)       

## save file as CSV
master_df.to_csv('NFL Snap Counts - WR - RB - TE - 2016-2017.csv', index = False, header = True)

