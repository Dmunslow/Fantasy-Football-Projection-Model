# -*- coding: utf-8 -*-
"""
Created on Sun Aug  5 12:17:50 2018

@author: Duncan
"""


import requests
import pandas as pd
from bs4 import BeautifulSoup

from selenium import webdriver
from selenium.webdriver.support.ui import Select

##  allow druver to be used in get_snap_count_page function
global driver 

## definition array for player position
positions = [ ["QB","RB", "WR", "TE"],["10", "20", "30", "40"] ]


def buildURL (pos, week, year):
    baseurl = "http://fftoday.com/stats/playerstats.php?"
    
    
    url_season = "Season=" + year
    
    url_week = "&GameWeek=" + week
    
    ## decode position ID from string
    url_position = "&PosID=" + positions[1][positions[0].index(pos)]
    
      # PPR scoring for draftkings
    url_stat_type = "&LeagueID=107644"
    
    url = baseurl + url_season + url_week + url_position + url_stat_type
    
    return url;

pos = "QB"
week = "15"
season = "2017"

test_url = buildURL(pos, week, season)