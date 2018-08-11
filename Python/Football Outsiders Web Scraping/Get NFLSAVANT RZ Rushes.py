# -*- coding: utf-8 -*-
"""
Created on Sat Aug 11 13:03:20 2018

@author: Duncan
"""

# -*- coding: utf-8 -*-
"""
Created on Sat Aug 11 11:59:55 2018

@author: Duncan
"""

import pandas as pd
import numpy as np
from bs4 import BeautifulSoup

from selenium import webdriver
from selenium.webdriver.support.ui import Select

##  allow druver to be used in get_snap_count_page function
global driver 


#initialize weeks data frame for regular season weeks only
week_num = list(np.arange(1, 18, 1))

seasons = ["2016", "2017"]


 # snap counts page url
url = "http://nflsavant.com/targets.php"

driver = webdriver.Chrome("E:\Python Projects\chromedriver.exe")

driver.get(url)


# retrieve page for each loop iteration
def get_target_page (week, year): 
    
    ##Select RZ targets
    s1 = Select(driver.find_element_by_id("ddlType"))
    s1.select_by_visible_text("Red Zone Rushing Attempts")
    
    
    ## select week 
    s2 = Select(driver.find_element_by_id("ddlWeek"))
    s2.select_by_visible_text("Week " + week)
    
    
    ## select year
    s3 = Select(driver.find_element_by_id("ddlYear"))
    s3.select_by_visible_text(year)
    return;

#initialize DF
master_df = pd.DataFrame([])

## iterate through position, season and week combos to get all desired data

for y in seasons:
    for w in week_num:
            get_target_page(str(w), y)
            
            html = driver.page_source

            soup = BeautifulSoup(html, 'html.parser')
            
            table = soup.find('table', id = "tblTargetsTotal") # grab first table
            
            column_headers = [th.getText() for th in table.findAll('tr')[0].findAll('th')]
            
            
            data_rows = table.findAll('tr')[1:]
             
            
            player_data = [[td.getText() for td in data_rows[i].findAll('td')]
                            for i in range(len(data_rows))]        
            
            df = pd.DataFrame(player_data, columns = column_headers)
            
            # Change LA Rams team abbreviation to LAR 
            df["Team"] = df["Team"].str.replace(r'\bLA\b', 'LAR')
            
             # separate player number, player First initials, and player last name
            name_data = pd.DataFrame(df.Name.str.split(",",1).tolist(),
                                     columns = ["player_last_name", 
                                                "player_first_name"])
            
            # combine split name data 
            df = pd.concat([name_data, df.drop("Name", axis = 1)], axis=1)
            
            # add week and season column
            df['Season'] = y
            df['Week'] = w
            
            #append new data to old dataframe
            master_df = master_df.append(df)



## save file as CSV
master_df.to_csv('NFL RZ Rushing Att - WR - RB - TE - 2016-2017.csv', index = False, header = True)









