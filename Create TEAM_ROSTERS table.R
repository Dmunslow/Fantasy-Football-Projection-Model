library(RODBC)
library(nflscrapR)



data("nflteams")

all_teams <- nflteams$abbr

rosters_2016 <- season_rosters(2016, teams = all_teams)
rosters_2017 <- season_rosters(2017, teams = all_teams)



## Create Roster Table in DB

db <- odbcConnect("NFLFFDB")


sqlSave(db, rosters_2016, "TEAM_ROSTERS",  rownames = F)
sqlSave(db, rosters_2017, "TEAM_ROSTERS",append = T, rownames = F)



