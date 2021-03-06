/****** Script for SelectTopNRows command from SSMS  ******/
SELECT [Date]
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

OR TwoPointConv = 'SUCCESS'
