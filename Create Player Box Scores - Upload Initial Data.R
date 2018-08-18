library(RODBC)
library(nflscrapR)
library(data.table)

db <- odbcConnect("NFLFFDB")

## test read in data

roster_info_all <- sqlQuery(db, "SELECT * FROM TEAM_ROSTERS")

roster_info_all[sapply(roster_info_all, is.factor)] <- lapply(roster_info_all[sapply(roster_info_all, is.factor)], 
                                              as.character)


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
rush_rec_stats <- pbp_dt[PlayType %in% c("Pass", "Run") & Pos %in% c('WR', 'TE', 'RB'),
                          .(targets = sum(as.integer(PassAttempt)),
                            receptions = sum(as.integer(Reception)),
                            rec_yards = sum(YardsGained * PassAttempt),
                            rec_touchdowns = sum(Touchdown * PassAttempt),
                            rec_two_pt_conv = as.integer(sum( ifelse(TwoPointConv == "Success",1,0) * PassAttempt)),
                            rec_fumble = as.integer(sum(ifelse(Fumble == 1 & RecFumbTeam != posteam,1,0) * PassAttempt)),
                            
                            rush_att = sum(as.integer(RushAttempt)),
                            rush_yards = sum(YardsGained * RushAttempt),
                            rush_touchdowns = sum(Touchdown * RushAttempt),
                            rush_two_pt_conv = as.integer(sum( ifelse(TwoPointConv == "Success",1,0) * RushAttempt)),
                            rush_fumble = as.integer(sum(ifelse(Fumble == 1 & RecFumbTeam != posteam,1,0) * RushAttempt))
                            
                          ),
                          by = .(Season, HomeTeam, AwayTeam, Date, GSIS_ID, 
                                 posteam, Pos)]


## GET KICKING DATA ------------------------------------------------------------
kicking_tds <- sqlQuery(db, "
                    SELECT  [Date]
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
                    FROM PBP_RAW P1
                    LEFT JOIN TEAM_ROSTERS R1
                    ON R1.[NAME] = P1.Returner
                    AND (P1.DefensiveTeam = R1.Team OR P1.posteam = R1.Team)
                    
                    WHERE Touchdown = 1
                    
                    AND PassAttempt = 0
                    
                    AND RushAttempt = 0
                    
                    AND PlayType IN ('KICKOFF', 'PUNT')
                    
                    AND (PuntResult <> 'BLOCKED' OR PuntResult IS NULL)")


kicking_tds[sapply(kicking_tds, is.factor)] <- lapply(kicking_tds[sapply(kicking_tds, is.factor)], 
                                              as.character)


# extract returner name for kickoff KR touchdowns
kicking_tds$Returner[is.na(kicking_tds$Returner)] <-substr(kicking_tds$desc[is.na(kicking_tds$Returner)], # list of strings 
                                                           as.integer(regexpr("\\d\\.\\s", kicking_tds$desc[is.na(kicking_tds$Returner)]) +3), # starting point
                                                           as.integer(regexpr("\\d\\.\\s", kicking_tds$desc[is.na(kicking_tds$Returner)])) + 
                                                                          as.integer(regexpr('\\s', substr(kicking_tds$desc[is.na(kicking_tds$Returner)], as.integer(regexpr("\\d\\.\\s", kicking_tds$desc[is.na(kicking_tds$Returner)]) +3), nchar(as.character(kicking_tds$desc[is.na(kicking_tds$Returner)])))))+1
)

## drop rows with player names RECOVERED
kicking_tds <- kicking_tds[kicking_tds$Returner != "RECOVERED",]


## get player IDS for players without ID
kicking_tds$GSIS_ID[is.na(kicking_tds$GSIS_ID)] <- roster_info_all$GSIS_ID[match(kicking_tds$Returner[is.na(kicking_tds$GSIS_ID)], roster_info_all$name )]


## calculate kicking TD stats

return_tds <- setDT(kicking_tds)[!is.na(GSIS_ID),
                                 .(return_tds = sum(Touchdown)),
                                 by = .(Season, HomeTeam, AwayTeam, 
                                        Date, GSIS_ID, posteam)]


## JOIN return TDS with other stat data ----------------------------------------

## Get Player IDs for returners where value is NA

## setkey to first 6 columns
setkeyv(return_tds, colnames(return_tds)[1:6])
setkeyv(rush_rec_stats, colnames(rush_rec_stats)[1:6])


full_stats <- merge(rush_rec_stats, return_tds, all = TRUE)


full_stats$Pos[is.na(full_stats$Pos)] <- roster_info_all$Pos[match(full_stats$GSIS_ID[is.na(full_stats$Pos)], roster_info_all$GSIS_ID )]


full_stats[is.na(full_stats)] <- 0

full_stats$player_name <-  roster_info_all$name[match(full_stats$GSIS_ID, roster_info_all$GSIS_ID )]

# Rearrange Columns

full_stats <- full_stats[, c(5,20,6, 1:4, 7:19)]

## Rename and format columns
column_names <- colnames(full_stats)

column_names[3] <- "PLAYER_TEAM"
column_names[5] <- "HOME_TEAM"
column_names[6] <- "AWAY_TEAM"

column_names <- toupper(column_names)

## Assign to full stats 
colnames(full_stats) <- column_names



## CREATE DK SCORE ------------------------------------------------------------

full_stats_dt <- setDT(full_stats)

dk_points <-full_stats_dt[  ,
                                .(  DK_REC_POINTS = REC_TOUCHDOWNS * 6 +
                                                        REC_YARDS * .1 +
                                                        ifelse(REC_YARDS >= 100, 3, 0) +
                                                        RECEPTIONS +
                                                        REC_TWO_PT_CONV * 2 +
                                                        REC_FUMBLE * -1,
                                    
                                    DK_RUSH_POINTS = RUSH_TWO_PT_CONV * 6 + 
                                                        RUSH_YARDS * .1 +
                                                        ifelse(RUSH_YARDS >= 100, 3, 0) +
                                                        REC_TWO_PT_CONV * 2 +
                                                        RUSH_FUMBLE * -1,
                                    
                                    DK_TOTAL_POINTS = RUSH_TWO_PT_CONV * 6 + 
                                                        RUSH_YARDS * .1 +
                                                        REC_TOUCHDOWNS * 6 +
                                                        REC_YARDS * .1 +
                                                        ifelse(RUSH_YARDS >= 100, 3, 0) +
                                                        ifelse(REC_YARDS >= 100, 3, 0) +
                                                        RECEPTIONS +
                                                        RETURN_TDS * 6 +
                                                        RUSH_TWO_PT_CONV * 2 +
                                                        REC_TWO_PT_CONV * 2 +
                                                        RUSH_FUMBLE * -1 +
                                                        REC_FUMBLE * -1 
                                    ),
                                
                                by = .(GSIS_ID, PLAYER_NAME, PLAYER_TEAM, SEASON,
                                       HOME_TEAM, AWAY_TEAM, DATE, POS)
                              ]


## JOIN COLUMNS
setkeyv(full_stats_dt, colnames(full_stats_dt)[1:8])
setkeyv(dk_points, colnames(dk_points)[1:8])


FINAL_STATS <- full_stats[dk_points]



# CREATE NEW SQL TABLE AND INSERT

db <- odbcConnect("NFLFFDB")


sqlSave(db, FINAL_STATS, "DK_POINTS", append = T, rownames = F)





