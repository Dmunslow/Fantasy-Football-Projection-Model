library(RODBC)
library(nflscrapR)
library(data.table)

db <- odbcConnect("NFLFFDB")


pbp_all <- setDT(sqlQuery(db, "SELECT *
                    ,V1.SCHEDULE_WEEK
                    ,V1.SCHEDULE_SEASON
                    
                    
                    FROM [NFLFFDB].[dbo].[PBP_RAW] P1
                    LEFT JOIN VEGAS_LINES V1
                    ON V1.SCHEDULE_DATE = P1.[DATE] 
                    AND V1.HOME_TEAM = P1.HOMETEAM
                    
                    
                    WHERE p1.playtype not in ('Punt', 
                                            'Kickoff', 
                                            'Extra Point', 
                                            'End of Game', 
                                            'Field Goal',
                                            'TIMEOUT',
                                            'QUARTER END',
                                            'TWO MINUTE WARNING',
                                            'HALF END')
                    
                    and (P1.PENALTYTYPE NOT IN('ENCROACHMENT',
                                                'FALSE START',
                                                'DELAY OF GAME')
                    
                            OR P1.PENALTYTYPE IS NULL)
                    
                    AND P1.[DESC] NOT LIKE '%BLANK%PLAY%' 
                    
                    AND P1.POSTEAM <> '' "))


all_dt <- pbp_all


## Create summary df
counts <- all_dt[,.(OFF_SNAPS = .N,
                    RUN_PLAYS = sum(RushAttempt),
                    PASS_PLAYS = sum(PassAttempt),
                    PASS_PCT = sum(PassAttempt)/ (sum(PassAttempt) + sum(RushAttempt)),
                    RUN_PCT = sum(RushAttempt)/ (sum(PassAttempt) + sum(RushAttempt)))
                         ,
                 by = .(SCHEDULE_WEEK, SCHEDULE_SEASON, posteam, DefensiveTeam)
                 ][!is.na(SCHEDULE_WEEK)]


new_col_names <- c("SCHEDULE_WEEK", "SCHEDULE_SEASON", "OFF_TEAM", "DEF_TEAM",
                   "OFF_SNAPS", "RUN_PLAYS", "PASS_PLAYS", "PASS_PCT", "RUN_PCT")


colnames(counts) <- new_col_names

## create table in SQL database
db <- odbcConnect("NFLFFDB")

sqlSave(db, counts, "TEAM_OFF_SNAP_COUNTS", rownames = F)

