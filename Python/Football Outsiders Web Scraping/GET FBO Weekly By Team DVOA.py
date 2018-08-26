# -*- coding: utf-8 -*-
"""
Created on Thu Aug 23 19:15:08 2018

@author: Duncan
"""
import pandas as pd
from bs4 import BeautifulSoup
from selenium import webdriver

##  allow druver to be used in get_snap_count_page function
global driver 

#initialize weeks data frame for regular season weeks only
years = list(range(2008, 2018))

# read in password files
creds = open("C:/Users/Duncan/Documents/fbo creds.txt", 'r').readlines()
creds[0] = creds[0].rstrip("\n")



# read in team names
teams = pd.read_csv("./FBO TEAM NAMES.csv")

teams = teams["TEAM"].tolist()

def get_dvoa_url (team, year): 
    
    base = "https://www.footballoutsiders.com/premium/weekByTeam.php?od=O&"
    
    year = "year=" + str(year)
    
    team = "&team=" + team
    
    week = "&week=1" 
    
    url = base + year + team + week
    
    return url;


# login into premium page =====================================================
    
url = "https://www.footballoutsiders.com/premium/index.php"

driver = webdriver.Chrome("E:\Python Projects\chromedriver.exe")

driver.get(url)

username = driver.find_element_by_id("edit-name")
password = driver.find_element_by_id("edit-pass")

username.send_keys(creds[0])
password.send_keys(creds[1])

driver.find_element_by_name("op").click()


# loop through data and pull all the tables ===================================

#initialize data frame
master_df = pd.DataFrame([])

for y in years:
    for t in teams:
        
        loop_url = get_dvoa_url(t , y)
        driver.get(loop_url)
        
        html = driver.page_source

        soup = BeautifulSoup(html, 'html.parser')

        table = soup.find('table', id = "dataTable") # grab first table

        column_headers = [th.getText() for th in
                      table.findAll('tr')[0].findAll('th')]
        
        data_rows = table.findAll('tr')[1:]
        
        player_data = [[td.getText() for td in data_rows[i].findAll('td')]
                            for i in range(len(data_rows))]        
         
        if player_data[0] != ['No data available in table']:
            df = pd.DataFrame(player_data, columns = column_headers)
    
            # add week and season column
            df['Season'] = y
            df['Team'] = t
               
            #append new data to old dataframe
            master_df = master_df.append(df)
            
            
col_names = master_df.columns.values
col_names = list(map(str.strip, col_names))
col_names = list(map(str.upper, col_names))
col_names = [ x.replace(' ', '_') for x in col_names ]

#assign col names to master_df
master_df.columns = col_names


# get rid of pct, move decimal place
master_df["TOTAL_DVOA"] = master_df["TOTAL_DVOA"].str.replace('%', '')
master_df["OFFENSE_DVOA"] = master_df["OFFENSE_DVOA"].str.replace('%', '')
master_df["OFF_PASS_DVOA"] = master_df["OFF_PASS_DVOA"].str.replace('%', '')
master_df["OFF_RUSH_DVOA"] = master_df["OFF_RUSH_DVOA"].str.replace('%', '')
master_df["DEFENSE_DVOA"] = master_df["DEFENSE_DVOA"].str.replace('%', '')
master_df["DEF_PASS_DVOA"] = master_df["DEF_PASS_DVOA"].str.replace('%', '')
master_df["DEF_RUSH_DVOA"] = master_df["DEF_RUSH_DVOA"].str.replace('%', '')
master_df["ST_DVOA"] = master_df["ST_DVOA"].str.replace('%', '')

# convert to numeric
master_df["TOTAL_DVOA"] = pd.to_numeric(master_df["TOTAL_DVOA"]) * .01
master_df["OFFENSE_DVOA"] = pd.to_numeric(master_df["OFFENSE_DVOA"]) * .01
master_df["OFF_PASS_DVOA"] = pd.to_numeric(master_df["OFF_PASS_DVOA"]) * .01
master_df["OFF_RUSH_DVOA"] = pd.to_numeric(master_df["OFF_RUSH_DVOA"]) * .01
master_df["DEFENSE_DVOA"] = pd.to_numeric(master_df["DEFENSE_DVOA"]) * .01
master_df["DEF_PASS_DVOA"] = pd.to_numeric(master_df["DEF_PASS_DVOA"]) * .01
master_df["DEF_RUSH_DVOA"] = pd.to_numeric(master_df["DEF_RUSH_DVOA"]) * .01
master_df["ST_DVOA"] = pd.to_numeric(master_df["ST_DVOA"]) * .01


# Fix team names
master_df["TEAM"] = master_df["TEAM"].str.replace('JAC', 'JAX')
master_df["TEAM"] = master_df["TEAM"].str.replace('LARM', 'LAR')
master_df["TEAM"] = master_df["TEAM"].str.replace('LACH', 'LAC')

master_df["OPPONENT"] = master_df["OPPONENT"].str.replace('JAC', 'JAX')
master_df["OPPONENT"] = master_df["OPPONENT"].str.replace('LARM', 'LAR')
master_df["OPPONENT"] = master_df["OPPONENT"].str.replace('LACH', 'LAC')













