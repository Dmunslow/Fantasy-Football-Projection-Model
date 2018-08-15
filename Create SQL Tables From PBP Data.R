library(RODBC)
library(nflscrapR)
library(data.table)

db <- odbcConnect("NFLFFDB")


pbp_2016 <- season_play_by_play(2016)
pbp_2017 <- season_play_by_play(2017)


sqlSave(db, pbp_2017, "PBP_RAW", append = T)
sqlSave(db, pbp_2016, "PBP_RAW", append = T)
