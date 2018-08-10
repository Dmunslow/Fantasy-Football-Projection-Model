# -*- coding: utf-8 -*-
"""
Created on Sat Aug  4 22:05:13 2018

@author: Duncan
"""
import pandas as pd
from bs4 import BeautifulSoup

from selenium import webdriver
from selenium.webdriver.support.ui import Select

##  allow druver to be used in get_snap_count_page function
global driver 

## positions for snap count stats
positions = ["RB", "WR", "TE"]


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



get_snap_count_page("WR", "6", "2017")



# read data with beautiful soup -----------------------------------------------

html = driver.page_source

soup = BeautifulSoup(html, 'html.parser')



table = soup.find('table', id = "dataTable") # grab first table

column_headers = [th.getText() for th in
                      table.findAll('tr')[0].findAll('th')]


data_rows = table.findAll('tr')[1:]
     
        
player_data = [[td.getText() for td in data_rows[i].findAll('td')]
            for i in range(len(data_rows))]        

    
# create pandas data frame
df = pd.DataFrame(player_data, columns = column_headers)