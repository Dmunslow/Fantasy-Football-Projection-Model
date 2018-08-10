library(readr)
library(data.table)

spread_data <- read_csv("./spreadspoke_scores_subset.csv")
team_abrv_lookup <- read_csv("./team abbreviation lookup.csv")


spread_data$schedule_date <- as.Date(spread_data$schedule_date)

## add abreviations to colums
spread_data$team_home_abrv <- team_abrv_lookup$team_abbrv[match( spread_data$team_home, team_abrv_lookup$team_full)]
spread_data$team_away_abrv <- team_abrv_lookup$team_abbrv[match( spread_data$team_away, team_abrv_lookup$team_full)]

## create favored columns
spread_data$ht_favored_ind <- ifelse(spread_data$team_favorite_id == spread_data$team_home_abrv,
                                      1, 0)
spread_data$at_favored_ind <- ifelse(spread_data$team_favorite_id == spread_data$team_home_abrv,
                                     0, 1)

## create home and away data frames

home_data <- spread_data[,c(1:3, 18, 8, 9, 20, 14)]
away_data <- spread_data[,c(1:3, 19, 8, 9, 21, 15)]

#calculate implied totals

home_data$implied_total <- (home_data$over_under_line / 2) + ifelse(home_data$ht_favored_ind == 1, 
                                                                    -home_data$spread_favorite, 
                                                                    home_data$spread_favorite)

away_data$implied_total <- (away_data$over_under_line / 2) + ifelse(away_data$at_favored_ind == 1, 
                                                                    -away_data$spread_favorite, 
                                                                    away_data$spread_favorite)