library(readr)
library(data.table)

pbp_2017 <- read_csv("./pbp-2017.csv")


# calculate snap counts by game
pbp_dt <- setDT(pbp_2017)


snap_counts <- pbp_2017[!is.na(OffenseTeam),
                        .(total_snaps = .N,
                          total_pass_plays = sum(ifelse(PlayType == "PASS", 1, 0), na.rm = T),
                          total_run_plays = sum(ifelse(PlayType == "RUSH", 1, 0), na.rm = T)
                          ),
                        by = .(OffenseTeam, DefenseTeam, GameId, GameDate)]