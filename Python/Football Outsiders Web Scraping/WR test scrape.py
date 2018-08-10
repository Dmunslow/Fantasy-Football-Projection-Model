# -*- coding: utf-8 -*-
"""
Football Outsiders Web Scraping Test

Created on Sat Aug  4 19:24:26 2018

@author: Duncan
"""

# import libraries
import requests
import pandas as pd
from bs4 import BeautifulSoup

#specify the url
baseurl = "https://www.footballoutsiders.com/stats/wr2017"

# query website
page = requests.get(baseurl)

soup = BeautifulSoup(page.text, 'html.parser')

print(soup.prettify())

table = soup.find_all('table')[0] # grab first table

column_headers = [th.getText() for th in
                      table.findAll('tr', limit = 1)[0].findAll('td')]



data_rows = table.findAll('tr')[1:]
     
        
player_data = [[td.getText() for td in data_rows[i].findAll('td')]
            for i in range(len(data_rows))]        

    
# create pandas data frame

df = pd.DataFrame(player_data, columns = column_headers)

# remove commas and pct signs
df["DVOA"] = df["DVOA"].str.replace('%', '')
df["VOA"] = df["VOA"].str.replace('%', '')
df["CatchRate"] = df["CatchRate"].str.replace('%', '')
df["Yards"] = df["Yards"].str.replace(',', '')
df["EYds"] = df["EYds"].str.replace(',', '')


df = df.drop_duplicates('Player')

df.to_csv('WR test.csv', index = False, header = True)

