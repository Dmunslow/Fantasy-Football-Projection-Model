library(RODBC)
library(nflscrapR)
library(data.table)

db <- odbcConnect("NFLFFDB")

## test read in data

pbp_all <- sqlQuery(db, "SELECT [Date]
                    ,[GameID]
                    ,[play_id]
                    ,[Drive]
                    ,[qtr]
                    ,[posteam]
                    ,[DefensiveTeam]
                    ,[desc]
                    ,[YardsGained]
                    ,[Touchdown]
                    ,[TwoPointConv]
                    ,[PuntResult]
                    ,[PlayType]
                    ,[Passer]
                    ,[Passer_ID]
                    ,[PassAttempt]
                    ,[Rusher]
                    ,[Rusher_ID]
                    ,[RushAttempt]
                    ,[Receiver]
                    ,[Receiver_ID]
                    ,[Reception]
                    ,[ReturnResult]
                    ,[Returner]
                    ,[Fumble]
                    ,[RecFumbTeam]
                    ,[Sack]
                    ,[HomeTeam]
                    ,[AwayTeam]
                    , P1.Season
                    , R1.GSIS_ID
                    , R1.Pos
                    
                    
                    FROM [NFLFFDB].[dbo].[PBP_RAW] P1
                    LEFT JOIN [NFLFFDB].[dbo].[TEAM_ROSTERS] R1
                    ON 
                    
                    (R1.[NAME] = CASE WHEN TwoPointConv = 'SUCCESS' AND Receiver IS NOT NULL THEN Receiver
                    WHEN TwoPointConv = 'SUCCESS' AND Rusher IS NOT NULL THEN Rusher END
                    and R1.SEASON = P1.Season) OR 
                    
                    (R1.[GSIS_ID] = CASE WHEN Receiver_ID <> 'None' THEN [Receiver_ID]
                    WHEN Rusher_ID <> 'None' THEN [Rusher_ID] 
                    ELSE PassLength END
                    and R1.SEASON = P1.Season ) 
                    
                    
                    
                    
                    WHERE R1.POS IN ('WR', 'TE', 'RB')
                    
                    OR ReturnResult = 'Touchdown'
                    
                    OR TwoPointConv = 'SUCCESS'")


## convert all factors to character
pbp_all[sapply(pbp_all, is.factor)] <- lapply(pbp_all[sapply(pbp_all, is.factor)], 
                                              as.character)

pbp_dt <- setDT(pbp_all) 

## Create player box score stats
receiving_stats <- pbp_dt[PlayType == "Pass",
                          .(targets = .N,
                            receptions = sum(as.integer(Reception)),
                            rec_yards = sum(YardsGained),
                            rec_touchdowns = sum(Touchdown),
                            rec_two_pt_conv = as.integer(sum( ifelse(TwoPointConv == "Success",1,0))),
                            rec_fumble = as.integer(sum(ifelse(Fumble == 1 & RecFumbTeam != posteam,1,0)))
                          ),
                          by = .(Season, HomeTeam, AwayTeam, Date, Receiver_ID, Pos,
                                 posteam)]


receiving_stats<- receiving_stats[Receiver_ID != "None"]

receiving_stats$rec_two_pt_conv[is.na(receiving_stats$rec_two_pt_conv)] <- 0
receiving_stats$rec_fumble[is.na(receiving_stats$rec_fumble)] <- 0


rushing_stats <- pbp_dt[PlayType == "Run",
                        .(rush_att = .N,
                          rush_yards = sum(YardsGained),
                          rush_touchdowns = sum(Touchdown),
                          rush_two_pt_conv = as.integer(sum( ifelse(TwoPointConv == "Success",1,0))),
                          rush_fumble = as.integer(sum(ifelse(Fumble == 1 & RecFumbTeam != posteam,1,0)))
                        ),
                        by = .(Season, HomeTeam, AwayTeam, Date, Rusher_ID, Pos,
                               posteam)]

rushing_stats$rush_two_pt_conv[is.na(rushing_stats$rush_two_pt_conv)] <- 0
rushing_stats$rush_fumble[is.na(rushing_stats$rush_fumble)] <- 0



kicking_tds <- pbp_dt[ReturnResult == "Touchdown" & 
                        (PuntResult != "Blocked" | is.na(pbp_dt$PuntResult)) &
                        PlayType %in% c("Kickoff", "Punt")]

# extract returner name for kickoff KR touchdowns
kicking_tds$Returner[is.na(kicking_tds$Returner)] <-substr(kicking_tds$desc[is.na(kicking_tds$Returner)], # list of strings 
                                                           regexpr("\\d\\.\\s", kicking_tds$desc[is.na(kicking_tds$Returner)]) +3, # starting point
                                                           regexpr("\\d\\.\\s", kicking_tds$desc[is.na(kicking_tds$Returner)]) + 
                                                             regexpr('\\s', substring(kicking_tds$desc[is.na(kicking_tds$Returner)], regexpr("\\d\\.\\s", kicking_tds$desc[is.na(kicking_tds$Returner)]) +3, nchar(kicking_tds$desc[is.na(kicking_tds$Returner)]))) + 1
)



## setup joins

rec_cols <- colnames(receiving_stats)
rush_cols <- colnames(rushing_stats)


## setkey to first 6 columns
setkeyv(receiving_stats, colnames(receiving_stats)[1:6])
setkeyv(rushing_stats, colnames(rushing_stats)[1:6])


test <- receiving_stats[rushing_stats]



test2 <- merge(receiving_stats, rushing_stats, all = TRUE)



