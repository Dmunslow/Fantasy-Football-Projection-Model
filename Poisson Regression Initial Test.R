library(RODBC)
library(nflscrapR)
library(data.table)
library(caret)

db <- odbcConnect("NFLFFDB")


snap_data <- sqlQuery(db, "SET NOCOUNT ON


                      
SELECT  V1.SCHEDULE_DATE
                      , S1.SCHEDULE_SEASON
                      , S1.SCHEDULE_WEEK
                      , S1.OFF_TEAM
                      , S1.DEF_TEAM
                      , S1.OFF_SNAPS
                      , V1.STADIUM
                      , V1.WEATHER_TEMPERATURE
                      , CASE WHEN V1.TEAM_FAVORITE_ID = S1.OFF_TEAM THEN 1 ELSE 0 END AS 'OFF_FAVORED_IND'
                      , CASE WHEN V1.HOME_TEAM = S1.OFF_TEAM THEN 1 ELSE 0 END AS 'OFF_HOME_IND'
                      , CASE WHEN V1.WEATHER_DETAIL = 'DOME' THEN 1 ELSE 0 END AS 'DOME_IND'
                      , CASE WHEN V1.WEATHER_DETAIL = 'RAIN' THEN 1 ELSE 0 END AS 'RAIN_IND'
                      , CASE WHEN V1.WEATHER_WIND_MPH >= 10 THEN 1 ELSE 0 END AS 'WIND_GTE_10_MPH_IND'
                      , CASE WHEN V1.WEATHER_WIND_MPH >= 15 THEN 1 ELSE 0 END AS 'WIND_GTE_15_MPH_IND'
                      , CASE 
                      WHEN V1.TEAM_FAVORITE_ID = S1.OFF_TEAM THEN (V1.OVER_UNDER_LINE/2) + ABS(V1.SPREAD_FAVORITE) 
                      ELSE (V1.OVER_UNDER_LINE/2) - ABS(V1.SPREAD_FAVORITE)
                      END AS 'IMPLIED_TOTAL'
                      
                      INTO #INITIALPULL
                      
                      FROM TEAM_OFF_SNAP_COUNTS S1
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = S1.SCHEDULE_SEASON
                      AND V1.SCHEDULE_WEEK = S1.SCHEDULE_WEEK
                      AND (V1.AWAY_TEAM = S1.OFF_TEAM OR V1.AWAY_TEAM = S1.DEF_TEAM)
                      
                      
                      WHERE S1.SCHEDULE_SEASON >= '2012'
                      
                      ORDER BY OFF_SNAPS 
                      
                      
                      
                      SELECT *
                      
                      ,(SELECT TOP 1 OFF_PASS_DVOA_8WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_PASS_DVOA_8WK_MA'
                      
                      ,(SELECT TOP 1 OFF_PASS_DVOA_6WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_PASS_DVOA_6WK_MA'
                      
                      ,(SELECT TOP 1 OFF_PASS_DVOA_4WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_PASS_DVOA_4WK_MA'
                      
                      ,(SELECT TOP 1 OFF_RUSH_DVOA_8WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_RUSH_DVOA_8WK_MA'
                      
                      ,(SELECT TOP 1 OFF_RUSH_DVOA_6WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_RUSH_DVOA_6WK_MA'
                      
                      ,(SELECT TOP 1 OFF_RUSH_DVOA_4WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_RUSH_DVOA_4WK_MA'
                      
                      -- DEFENSE =========================================
                      
                      ,(SELECT TOP 1 DEF_PASS_DVOA_8WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_PASS_DVOA_8WK_MA'
                      
                      ,(SELECT TOP 1 DEF_PASS_DVOA_6WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_PASS_DVOA_6WK_MA'
                      
                      ,(SELECT TOP 1 DEF_PASS_DVOA_4WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_PASS_DVOA_4WK_MA'
                      
                      ,(SELECT TOP 1 DEF_RUSH_DVOA_8WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_RUSH_DVOA_8WK_MA'
                      
                      ,(SELECT TOP 1 DEF_RUSH_DVOA_6WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_RUSH_DVOA_6WK_MA'
                      
                      ,(SELECT TOP 1 DEF_RUSH_DVOA_4WK_MA
                      
                      FROM FBO_AO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_RUSH_DVOA_4WK_MA'
                      
                      ,(SELECT TOP 1 AVG_SPP_8WK
                      
                      FROM OFF_PACE_STATS OP
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = OP.SCHEDULE_SEASON
                      AND V1.SCHEDULE_WEEK = OP.SCHEDULE_WEEK
                      AND (V1.AWAY_TEAM = OP.OFF_TEAM OR V1.HOME_TEAM = OP.OFF_TEAM)
                      
                      WHERE OP.OFF_TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'AVG_SPP_PACE'

                    	,(SELECT TOP 1 DEFENSE_DVOA

                      FROM FBO_AO_WEEKLY_DVOA OP
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = OP.[SEASON]
                      AND V1.SCHEDULE_WEEK = OP.[WEEK]
                      AND (V1.AWAY_TEAM = OP.TEAM OR V1.HOME_TEAM = OP.TEAM)
                      
                      WHERE OP.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC) AS 'DEF_DVOA_AO_CURRENT_WEEK'

                     , (SELECT TOP 1 AVG_PASS_PCT_8WK

                      FROM TEAM_OFF_SNAP_COUNTS OP
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = OP.SCHEDULE_SEASON
                      AND V1.SCHEDULE_WEEK = OP.SCHEDULE_WEEK
                      AND (V1.AWAY_TEAM = OP.OFF_TEAM OR V1.HOME_TEAM = OP.OFF_TEAM)
                      
                      WHERE OP.OFF_TEAM = P1.OFF_TEAM) AS 'AVG_PASS_PCT_8WK'
                      
                      
                      
                      FROM #INITIALPULL P1")



# CREATE DATA PARTITION
set.seed(808)
inTrain <- createDataPartition(y = snap_data$OFF_SNAPS, p = .7, list = F)

train <- snap_data[inTrain,]
test <- snap_data[-inTrain,]


# 8WK MOVING AVERAGE APPEARS TO BE BEST
reg1 <- glm( OFF_SNAPS ~ OFF_PASS_DVOA_8WK_MA, family= "poisson", data = train)
summary(reg1)
reg2 <- glm( OFF_SNAPS ~ OFF_PASS_DVOA_6WK_MA, family= "poisson", data = train)
summary(reg2)
reg3 <- glm( OFF_SNAPS ~ OFF_PASS_DVOA_4WK_MA, family= "poisson", data = train)
summary(reg3)

# 6wk MA is bes
reg4 <- glm( OFF_SNAPS ~ OFF_PASS_DVOA_4WK_MA + 
                         AVG_SPP_PACE + 
                         IMPLIED_TOTAL + 
                         OFF_HOME_IND +
                         AVG_PASS_PCT_8WK +
                         AVG_SPP_PACE:IMPLIED_TOTAL +
                        OFF_PASS_DVOA_4WK_MA, 
             family= "poisson" , data = train)
summary(reg4)


## TRY AGAIN
test_pred <- predict(reg4, test, type = "response")


pred_vs_act <- data.frame(actual = test$OFF_SNAPS, pred = test_pred)

pred_vs_act$diff <- pred_vs_act$pred - pred_vs_act$actual

