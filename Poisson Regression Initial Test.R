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
                      , CASE WHEN V1.TEAM_FAVORITE_ID = OFF_TEAM THEN 1 ELSE 0 END AS 'OFF_FAVORED_IND'
                      , CASE WHEN V1.HOME_TEAM = S1.OFF_TEAM THEN 1 ELSE 0 END AS 'OFF_HOME_IND'
                      , CASE WHEN V1.WEATHER_DETAIL = 'DOME' THEN 1 ELSE 0 END AS 'DOME_IND'
                      , CASE WHEN V1.WEATHER_DETAIL = 'RAIN' THEN 1 ELSE 0 END AS 'RAIN_IND'
                      , CASE WHEN V1.WEATHER_WIND_MPH >= 10 THEN 1 ELSE 0 END AS 'WIND_GTE_10_MPH_IND'
                      , CASE WHEN V1.WEATHER_WIND_MPH >= 15 THEN 1 ELSE 0 END AS 'WIND_GTE_15_MPH_IND'
                      
                      INTO #INITIALPULL
                      
                      FROM TEAM_OFF_SNAP_COUNTS S1
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = S1.SCHEDULE_SEASON
                      AND V1.SCHEDULE_WEEK = S1.SCHEDULE_WEEK
                      AND (V1.AWAY_TEAM = S1.OFF_TEAM OR V1.AWAY_TEAM = S1.DEF_TEAM)
                      --LEFT JOIN FBO_WEEKLY_DVOA DVO
                      --		ON S1.OFF_TEAM = DVO.TEAM
                      --		AND  DVO.[WEEK] = CASE 
                      --								WHEN S1.SCHEDULE_WEEK = 1 THEN 16 
                      --								ELSE S1.SCHEDULE_WEEK-1 
                      --							END
                      --		AND  DVO.SEASON = CASE 
                      --								WHEN S1.SCHEDULE_WEEK = 1 THEN S1.SCHEDULE_SEASON-1 
                      --								ELSE S1.SCHEDULE_SEASON 
                      --							END
                      --LEFT JOIN FBO_WEEKLY_DVOA DVD
                      --		ON S1.DEF_TEAM = DVD.TEAM
                      --		AND  DVD.[WEEK] = CASE 
                      --								WHEN S1.SCHEDULE_WEEK = 1 THEN 16 
                      --								ELSE S1.SCHEDULE_WEEK-1 
                      --							END
                      --		AND  DVD.SEASON = CASE 
                      --								WHEN S1.SCHEDULE_WEEK = 1 THEN S1.SCHEDULE_SEASON-1 
                      --								ELSE S1.SCHEDULE_SEASON 
                      --							END
                      
                      WHERE S1.SCHEDULE_SEASON >= '2012'
                      
                      ORDER BY OFF_SNAPS 
                      
                      
                      
                      SELECT *
                      
                      ,(SELECT TOP 1 OFF_DVOA_8WK_MA
                      
                      FROM FBO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_DVOA_8WK_MA'
                      
                      ,(SELECT TOP 1 OFF_DVOA_6WK_MA
                      
                      FROM FBO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_DVOA_6WK_MA'
                      
                      ,(SELECT TOP 1 OFF_DVOA_4WK_MA
                      
                      FROM FBO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.OFF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'OFF_DVOA_4WK_MA'
                      
                      
                      ,(SELECT TOP 1 DEF_DVOA_8WK_MA
                      
                      FROM FBO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_DVOA_8WK_MA'
                      
                      ,(SELECT TOP 1 DEF_DVOA_6WK_MA
                      
                      FROM FBO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_DVOA_6WK_MA'
                      
                      ,(SELECT TOP 1 DEF_DVOA_4WK_MA
                      
                      FROM FBO_WEEKLY_DVOA DVO 
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = DVO.SEASON
                      AND V1.SCHEDULE_WEEK = DVO.[WEEK]
                      AND (V1.AWAY_TEAM = DVO.TEAM OR V1.HOME_TEAM = DVO.TEAM)
                      
                      WHERE DVO.TEAM = P1.DEF_TEAM
                      
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE
                      
                      ORDER BY V1.SCHEDULE_DATE DESC
                      
                      ) AS 'DEF_DVOA_4WK_MA'
                      
                      , ((SELECT SUM(T.[SEC/PLAY])
                      
                      FROM 
                      
                      (SELECT TOP 4 [SEC/PLAY]
                      
                      FROM OFF_PACE_STATS S1
                      LEFT JOIN VEGAS_LINES V1
                      ON V1.SCHEDULE_SEASON = S1.SCHEDULE_SEASON
                      AND V1.SCHEDULE_WEEK = S1.SCHEDULE_WEEK
                      AND (V1.AWAY_TEAM = S1.OFF_TEAM OR V1.HOME_TEAM = S1.OFF_TEAM)
                      
                      WHERE S1.OFF_TEAM = P1.OFF_TEAM
                      
                      -- GAMES PRIOR TO THIS ONE
                      AND P1.SCHEDULE_DATE >  V1.SCHEDULE_DATE)  AS T) / 4) AS 'TIME_BTWN_PLAYS'
                      
                      
                      FROM #INITIALPULL P1
                      
                      ")

# CREATE DATA PARTITION
set.seed(808)
inTrain <- createDataPartition(y = snap_data$OFF_SNAPS, p = .7, list = F)

train <- snap_data[inTrain,]
test <- snap_data[-inTrain,]


# 8WK MOVING AVERAGE APPEARS TO BE BEST
reg1 <- glm( OFF_SNAPS ~ OFF_DVOA_8WK_MA, family= "poisson", data = train)
summary(reg1)
reg2 <- glm( OFF_SNAPS ~ OFF_DVOA_6WK_MA, family= "poisson", data = train)
summary(reg2)
reg3 <- glm( OFF_SNAPS ~ OFF_DVOA_4WK_MA, family= "poisson", data = train)
summary(reg3)

# 6wk MA is bes
reg4 <- glm( OFF_SNAPS ~ OFF_DVOA_6WK_MA + DEF_DVOA_8WK_MA, family= "poisson", data = train)
summary(reg4)


reg5 <- glm( OFF_SNAPS ~ OFF_DVOA_6WK_MA + 
                         DEF_DVOA_6WK_MA + 
                         OFF_HOME_IND, 
             family= "poisson", data = train)
summary(reg5)


reg6 <- glm( OFF_SNAPS ~ OFF_DVOA_6WK_MA + 
                 DEF_DVOA_6WK_MA + 
                 OFF_HOME_IND  +
                 OFF_TEAM + 
                 STADIUM, 
             family= "poisson", data = train)
summary(reg6)



## PREDICT BASED ON TEST SET

test_pred <- predict(reg6, test, type = "response")


pred_vs_act <- data.frame(actual = test$OFF_SNAPS, pred = test_pred)



