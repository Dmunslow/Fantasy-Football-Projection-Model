library(RODBC)
library(data.table)
library(ggplot2)


db <- odbcConnect("NFLFFDB")

point_data <- sqlQuery(db, "SELECT * FROM DK_POINTS")


# points per target

recieving <- setDT(point_data)[TARGETS > 3]


pt_per_target <- recieving[,
                           .(pts_per_target = DK_REC_POINTS / TARGETS),
                           
                           by = .(GSIS_ID, PLAYER_NAME, DATE)]


plot( density(pt_per_target$pts_per_target))


# antonio brown

AB <- pt_per_target[PLAYER_NAME == "A.Brown"]
obj <- pt_per_target[PLAYER_NAME == "O.Beckham"]
fitz <- pt_per_target[PLAYER_NAME == "L.Fitzgerald"]
DT <- pt_per_target[PLAYER_NAME == "D.Thomas"]

lines(density(AB$pts_per_target), col = "red")
lines(density(obj$pts_per_target), col = "blue")
lines(density(fitz$pts_per_target), col = "green")

lines(density(DT$pts_per_target), col = "orange")