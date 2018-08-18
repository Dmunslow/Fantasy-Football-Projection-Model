library(RODBC)
library(nflscrapR)



data("nflteams")

all_teams <- nflteams$abbr

rosters_2009 <- season_rosters(2009, teams = all_teams)
rosters_2010 <- season_rosters(2010, teams = all_teams)
rosters_2011 <- season_rosters(2011, teams = all_teams)
rosters_2012 <- season_rosters(2012, teams = all_teams)
rosters_2013 <- season_rosters(2013, teams = all_teams)
rosters_2014 <- season_rosters(2014, teams = all_teams)
rosters_2015 <- season_rosters(2015, teams = all_teams)


### combine all rosters

all_rosters <- rbind(rosters_2009, rosters_2010, rosters_2011,
                     rosters_2012, rosters_2013, rosters_2014,
                     rosters_2015)

## Create Roster Table in DB


db <- odbcConnect("NFLFFDB")


sqlSave(db, all_rosters, "TEMP_TEAM_ROSTERS",  rownames = F)

sqlSave(db, rosters_2017, "TEAM_ROSTERS",append = T, rownames = F)



