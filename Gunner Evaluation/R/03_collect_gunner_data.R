############################################################
## Collecting Gunner Data (Feature Engineering)
## Hunter Hopkins
############################################################

########################################
# Source File
########################################
library(tidyverse)
library(here)

source(here("R", "00_source.R"))

########################################
# Import Data
########################################
puntPlays <- read.csv(here("data", "punt_plays.csv"))
puntPlayInfo <- read.csv(here("data", "punt_play_info.csv"))

########################################
# Create New DF
########################################
specialistData <- data.frame(gameId = rep(puntPlayInfo$gameId, each = 2),
                             playId = rep(puntPlayInfo$playId, each = 2),
                             gunnerTeam = character(2 * nrow(puntPlayInfo)),
                             gunnerId = numeric(2 * nrow(puntPlayInfo)),
                             gunnerName = character(2 * nrow(puntPlayInfo)),
                             viseTeam = character(2 * nrow(puntPlayInfo)),
                             viseId = numeric(2 * nrow(puntPlayInfo)),
                             viseName = character(2 * nrow(puntPlayInfo)),
                             firstManDown = numeric(2 * nrow(puntPlayInfo)),
                             timeToBeatVise = numeric(2 * nrow(puntPlayInfo)),
                             disFromLOS = numeric(2 * nrow(puntPlayInfo)),
                             disFromReturner = numeric(2 * nrow(puntPlayInfo)),
                             speedDev = numeric(2 * nrow(puntPlayInfo)),
                             topSpeed = numeric(2 * nrow(puntPlayInfo)),
                             tackle = numeric(2 * nrow(puntPlayInfo)),
                             missedTackle = numeric(2 * nrow(puntPlayInfo)),
                             squeezeDis = numeric(2 * nrow(puntPlayInfo)),
                             gunnerSide = numeric(2 * nrow(puntPlayInfo)),
                             release = numeric(2 * nrow(puntPlayInfo)),
                             kickDirRelGun = numeric(2 * nrow(puntPlayInfo)),
                             cat = numeric(2 * nrow(puntPlayInfo)),
                             correctRelease = numeric(2 * nrow(puntPlayInfo)))

specialistData <- specialistData %>%
  inner_join(puntPlayInfo)

########################################
# Gunner Info (Team, Name, ID)
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] & 
                                 playId == specialistData$playId[i])
  gunners <- play$gunner[1]
  gunnerTeam <- play$possessionTeam[1]
  gunner1 <- unlist(strsplit(gunners, split = '; '))[1]
  gunner2 <- unlist(strsplit(gunners, split = '; '))[2]
  gunner1Number <- substrRight(gunner1, 2)
  gunner2Number <- substrRight(gunner2, 2)
  
  specialistData$gunnerId[i] <- play$nflId[which(play$teamAbbr == gunnerTeam & 
                                                   play$jerseyNumber == gunner1Number)][1]
  specialistData$gunnerId[i + 1] <- play$nflId[which(play$teamAbbr == gunnerTeam & 
                                                       play$jerseyNumber == gunner2Number)][1]
  specialistData$gunnerName[i] <- play$displayName[which(play$teamAbbr == gunnerTeam & 
                                                           play$jerseyNumber == gunner1Number)][1]
  specialistData$gunnerName[i + 1] <- play$displayName[which(play$teamAbbr == gunnerTeam & 
                                                               play$jerseyNumber == gunner2Number)][1]
  specialistData$gunnerTeam[c(i, i + 1)] <- gunnerTeam
}

########################################
# Jammer Info (Team, Name, ID)
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] & 
                                 playId == specialistData$playId[i])
  vises <- play$vises[1]
  viseTeam <- gsub(" .*$", "", vises)
  vise1 <- unlist(strsplit(vises, split = '; '))[1]
  vise2 <- unlist(strsplit(vises, split = '; '))[2]
  vise1Number <- substrRight(vise1, 2)
  vise2Number <- substrRight(vise2, 2)
  
  specialistData$viseId[i] <- play$nflId[which(play$teamAbbr == viseTeam & 
                                                 play$jerseyNumber == vise1Number)][1]
  specialistData$viseId[i + 1] <- play$nflId[which(play$teamAbbr == viseTeam & 
                                                     play$jerseyNumber == vise2Number)][1]
  specialistData$viseName[i] <- play$displayName[which(play$teamAbbr == viseTeam & 
                                                         play$jerseyNumber == vise1Number)][1]
  specialistData$viseName[i + 1] <- play$displayName[which(play$teamAbbr == viseTeam & 
                                                             play$jerseyNumber == vise2Number)][1]
  specialistData$viseTeam[c(i, i + 1)] <- viseTeam
}

head(specialistData)

########################################
# Remove Plays With Missing Player IDs
########################################
missingIDs <- which(is.na(specialistData$gunnerId) | is.na(specialistData$viseId))
gameID <- specialistData$gameId
playID <- specialistData$playId
rowsRemove <- numeric(0)
for (i in missingIDs) {
  if (gameID[i] == gameID[i + 1] & playID[i] == playID[i + 1]) {
    rowsRemove <- c(rowsRemove, i,  i + 1)
  } else {
    rowsRemove <- c(rowsRemove, i, i - 1)
  }
}
specialistData <- specialistData[-rowsRemove, ]

sum(is.na(specialistData$gunnerId))

########################################
# Remove Odd Plays
########################################
specialistData <- specialistData[-c(2049:2050, 2673:2674, 3943:3944), ]

########################################
# Match Gunners to Jammer Defending Them
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  gunnerID <- specialistData$gunnerId[i]
  vise1ID <- specialistData$viseId[i]
  vise2ID <- specialistData$viseId[i + 1]
  vise1Name <- specialistData$viseName[i]
  vise2Name <- specialistData$viseName[i + 1]
  
  playStartRows <- which(puntPlays$gameId == specialistData$gameId[i] & 
                           puntPlays$playId == specialistData$playId[i] & 
                           puntPlays$frameId == 1)
  
  # first frame of play
  playStart <- puntPlays[playStartRows, ]
  
  # distance between gunner and jammer 1
  dis1 <- abs(as.numeric(playStart[which(playStart$nflId == gunnerID), "y"]) - 
                as.numeric(playStart[which(playStart$nflId == vise1ID), "y"]))
  
  # distance between gunner and jammer 2
  dis2 <- abs(as.numeric(playStart[which(playStart$nflId == gunnerID), "y"]) - 
                as.numeric(playStart[which(playStart$nflId == vise2ID), "y"]))
  
  # compare distance
  if (dis2 < dis1) {
    specialistData$viseId[i] <- vise2ID
    specialistData$viseName[i] <- vise2Name
    specialistData$viseId[i + 1] <- vise1ID
    specialistData$viseName[i + 1] <- vise1Name
  }
}

head(specialistData)

########################################
# Fill returnYds and specialTeamsResults
# Columns
########################################
returnYds <- numeric(nrow(specialistData))
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  specialistData$specialTeamsResult[c(i, i + 1)] <- play$specialTeamsResult[1]
  returnYds[c(i, i + 1)] <- play$kickReturnYardage[1]
}
specialistData$returnYds <- returnYds

head(specialistData)

########################################
# Fill timeToBeatVise Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  # find rows containing each player
  returnerRows <- which(play$nflId == play$returnerId)
  gunner1Rows <- which(play$nflId == specialistData$gunnerId[i])
  vise1Rows <- which(play$nflId == specialistData$viseId[i])
  gunner2Rows <- which(play$nflId == specialistData$gunnerId[i + 1])
  vise2Rows <- which(play$nflId == specialistData$viseId[i + 1])
  
  # for each frame, store gunner's distance to returner and jammer's distance to returner
  framesGunner1PastVise1 <- numeric(0)
  for (j in 1:length(gunner1Rows)) {
    gunner1DisReturner <- eucDis(play[gunner1Rows[j], c("x", "y")], play[returnerRows[j], c("x", "y")])
    vise1DisReturner <- eucDis(play[vise1Rows[j], c("x", "y")], play[returnerRows[j], c("x", "y")])
    
    # store frames where gunner is closer to returner (past jammer)
    if (gunner1DisReturner < vise1DisReturner) {
      framesGunner1PastVise1 <- c(framesGunner1PastVise1, j)
    }
  }
  
  # split frames where gunner is past jammer into sequences and save last sequence
  sequentialFrames1 <- split(framesGunner1PastVise1, cumsum(c(TRUE, diff(framesGunner1PastVise1) != 1)))
  specialistData$timeToBeatVise[i] <- sequentialFrames1[[length(sequentialFrames1)]][1] / 10
  
  # repeat for other gunner
  framesGunner2PastVise2 <- numeric(0)
  for (j in 1:length(gunner2Rows)) {
    gunner2DisReturner <- eucDis(play[gunner2Rows[j], c("x", "y")], play[returnerRows[j], c("x", "y")])
    vise2DisReturner <- eucDis(play[vise2Rows[j], c("x", "y")], play[returnerRows[j], c("x", "y")])
    
    if (gunner2DisReturner < vise2DisReturner) {
      framesGunner2PastVise2 <- c(framesGunner2PastVise2, j)
    }
  }
  
  sequentialFrames2 <- split(framesGunner2PastVise2, cumsum(c(TRUE, diff(framesGunner2PastVise2) != 1)))
  specialistData$timeToBeatVise[i + 1] <- sequentialFrames2[[length(sequentialFrames2)]][1] / 10
}

head(specialistData)

########################################
# Fill firstManDown Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  comp <- c(specialistData$timeToBeatVise[i], specialistData$timeToBeatVise[i + 1])
  
  if (sum(is.na(comp)) == 0) {
    specialistData$firstManDown[i + (which(comp == min(comp)) - 1)] <- 1
  } else if (sum(is.na(comp)) == 1) {
    specialistData$firstManDown[i + (which(!is.na(comp)) - 1)] <- 1
  }
}

head(specialistData)

########################################
# Fill disFromLOS Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  LOS <- play$absoluteYardlineNumber[1]
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  
  snapFrame <- puntPlayInfo$snapFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                              puntPlayInfo$playId == play$playId[1])]
  
  catchFrame <- puntPlayInfo$catchFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                                puntPlayInfo$playId == play$playId[1])]
  
  # Row indices when ball is caught
  caughtRow <- play[which(play$frameId == catchFrame), c('nflId', 'x')]
  if (nrow(caughtRow) == 0) {
    caughtRow <- play[which(play$frameId == max(play$frameId)), c('nflId', 'x')]
  }
  
  # player pos when ball is caught
  gunner1Pos <- caughtRow[which(caughtRow$nflId == gunner1), 2]
  gunner2Pos <- caughtRow[which(caughtRow$nflId == gunner2), 2]
  
  specialistData$disFromLOS[i] <- abs(gunner1Pos - LOS)
  specialistData$disFromLOS[i + 1] <- abs(gunner2Pos - LOS)
}

head(specialistData)

########################################
# Fill disFromReturner Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  # ID players
  returner <- play$returnerId[1]
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  
  snapFrame <- puntPlayInfo$snapFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                              puntPlayInfo$playId == play$playId[1])]
  
  catchFrame <- puntPlayInfo$catchFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                                puntPlayInfo$playId == play$playId[1])]
  
  # Row indices when ball is caught
  caughtRow <- play[which(play$frameId == catchFrame), c('nflId', 'x', 'y')]
  if (nrow(caughtRow) == 0) {
    caughtRow <- play[which(play$frameId == max(play$frameId)), c('nflId', 'x', 'y')]
  }
  
  # player pos when ball is caught
  gunner1Pos <- caughtRow[which(caughtRow$nflId == gunner1), c("x", "y")]
  gunner2Pos <- caughtRow[which(caughtRow$nflId == gunner2), c("x", "y")]
  returnerPos <- caughtRow[which(caughtRow$nflId == returner), c("x", "y")]
  
  specialistData$disFromReturner[i] <- as.numeric(eucDis(gunner1Pos, returnerPos))
  specialistData$disFromReturner[i + 1] <- as.numeric(eucDis(gunner2Pos, returnerPos))
}

head(specialistData)

########################################
# Fill speedDev Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  
  snapFrame <- puntPlayInfo$snapFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                              puntPlayInfo$playId == play$playId[1])]
  
  catchFrame <- puntPlayInfo$catchFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                                puntPlayInfo$playId == play$playId[1])]
  
  # gunner tracking data after ball is snapped and before ball is caught
  gunner1Frames <- play %>% filter(frameId >= snapFrame & frameId <= catchFrame & nflId == gunner1)
  gunner2Frames <- play %>% filter(frameId >= snapFrame & frameId <= catchFrame & nflId == gunner2)
  
  specialistData$speedDev[i] <- sd(gunner1Frames$s)
  specialistData$speedDev[i + 1] <- sd(gunner2Frames$s)
}

head(specialistData)

########################################
# Fill topSpeed Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  
  snapFrame <- puntPlayInfo$snapFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                              puntPlayInfo$playId == play$playId[1])]
  
  catchFrame <- puntPlayInfo$catchFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                                puntPlayInfo$playId == play$playId[1])]
  
  # gunner tracking data after ball is snapped and before ball is caught
  gunner1Frames <- play %>% filter(frameId >= snapFrame & frameId <= catchFrame & nflId == gunner1)
  gunner2Frames <- play %>% filter(frameId >= snapFrame & frameId <= catchFrame & nflId == gunner2)
  
  specialistData$topSpeed[i] <- max(gunner1Frames$s)
  specialistData$topSpeed[i + 1] <- max(gunner2Frames$s)
}

head(specialistData)

########################################
# Fill squeezeDis Column
########################################
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  # squeezeDis is only applicable to returns
  if (play$specialTeamsResult[1] == 'Fair Catch') {
    next
  }
  
  returner <- play$returnerId[1]
  
  snapFrame <- puntPlayInfo$snapFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                              puntPlayInfo$playId == play$playId[1])]
  
  catchFrame <- puntPlayInfo$catchFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                                puntPlayInfo$playId == play$playId[1])]
  
  # returner pos when ball is caught
  returnerCaughtYPos <- play$y[which(play$nflId == returner & play$frameId == catchFrame)]
  returnerCaughtXPos <- play$x[which(play$nflId == returner & play$frameId == catchFrame)]
  
  # pos of sidelines
  sidelines <- c(0, 53.3)
  
  # determine closest sideline
  dis1 <- abs(returnerCaughtYPos - sidelines[1])
  dis2 <- abs(returnerCaughtYPos - sidelines[2])
  if (dis1 < dis2) {
    sidelineClose <- 0
  } else {
    sidelineClose <- 53.3
  }
  
  # returner pos after ball is caught
  returnerYPos <- play$y[which(play$nflId == play$returnerId & play$frameId > catchFrame)]
  # how far is returner from sideline when they catch ball
  returnerDisSidelineCaught <- abs(returnerCaughtYPos - sidelineClose)
  # mean pos during return
  returnerMeanYPos <- mean(play$y[which(play$nflId == returner & play$frameId > catchFrame)])
  
  # mean distance to closest sideline during return
  avgSidelineDis <- abs(returnerMeanYPos - sidelineClose)
  
  specialistData$squeezeDis[c(i, i+1)] <- returnerDisSidelineCaught - avgSidelineDis
}

specialistData$squeezeDis <- ifelse(specialistData$specialTeamsResult == 'Fair Catch', NA, specialistData$squeezeDis)

head(specialistData)

########################################
# Record if Gunner Made a Tackle
########################################
tackle <- numeric(nrow(specialistData))
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  tackler <- play$tackler[1]
  
  # If tackle was made, grab player ID of tackler
  if (!(is.na(tackler))) {
    tacklerTeam <- gsub(" .*$", "", tackler)
    tacklerNumber <- substrRight(tackler, 2)
    
    tacklerID <- play$nflId[which(play$teamAbbr == tacklerTeam & 
                                    play$jerseyNumber == tacklerNumber)][1]
    
    # skip play if tackler can't be ID
    if (is.na(tacklerID)) {
      next
    }
    
    # check if tackler ID matches either gunner ID
    if (tacklerID == gunner1) {
      tackle[i] <- 1
    } else if (tacklerID == gunner2) {
      tackle[i + 1] <- 1
    }
  }
}
specialistData$tackle <- tackle

head(specialistData)

########################################
# Record if Gunner Missed a Tackle
########################################
missedTackle <- numeric(nrow(specialistData))
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  missedTackler <- play$missedTackler[1]
  
  # If missed tackle occurred, grab player ID of missed tackler
  if (!(is.na(missedTackler))) {
    missedTacklerTeam <- gsub(" .*$", "", missedTackler)
    missedTacklerNumber <- substrRight(missedTackler, 2)
    
    missedTacklerID <- play$nflId[which(play$teamAbbr == missedTacklerTeam & 
                                          play$jerseyNumber == missedTacklerNumber)][1]
    
    # skip play if player can't be ID
    if (is.na(missedTacklerID)) {
      next
    }
    
    # check if ID matches either gunner ID
    if (missedTacklerID == gunner1) {
      missedTackle[i] <- 1
    } else if (missedTacklerID == gunner2) {
      missedTackle[i + 1] <- 1
    }
  }
}
specialistData$missedTackle <- missedTackle

head(specialistData)

########################################
# Record Gunner Release Types
########################################

## Which Side of the Field Is Each Gunner Lined Up?
for (i in seq(1, nrow(specialistData), 2)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  # ID players
  gunner1 <- specialistData$gunnerId[i]
  gunner2 <- specialistData$gunnerId[i + 1]
  
  # get y pos of gunners at start
  gunner1StartYPos <- play$y[which(play$nflId == gunner1 & play$frameId == 1)]
  gunner2StartYPos <- play$y[which(play$nflId == gunner2 & play$frameId == 1)]
  
  # compare y pos to middle of field
  if (gunner1StartYPos > 26.65) {
    specialistData$gunnerSide[i] <- 'L'
  } else {
    specialistData$gunnerSide[i] <- 'R'
  }
  
  if (gunner2StartYPos > 26.65) {
    specialistData$gunnerSide[i + 1] <- 'L'
  } else {
    specialistData$gunnerSide[i + 1] <- 'R'
  }
}

head(specialistData)

## Classify as Inside or Outside Release
for (i in 1:nrow(specialistData)) {
  play <- puntPlays %>% filter(gameId == specialistData$gameId[i] &
                                 playId == specialistData$playId[i])
  
  # ID players
  gunnerID <- specialistData$gunnerId[i]
  viseID <- specialistData$viseId[i]
  
  snapFrame <- puntPlayInfo$snapFrame[which(puntPlayInfo$gameId == play$gameId[1] &
                                              puntPlayInfo$playId == play$playId[1])]
  # gunner y pos at start
  gunnerStartYPos <- play$y[which(play$nflId == gunnerID & play$frameId == snapFrame)]
  
  # gunner and jammer y pos 3 sec after ball is snapped
  # pos taken after 3 sec to make sure gunner isn't just trying to misdirect jammer
  gunnerReleaseYPos <- play$y[which(play$nflId == gunnerID & play$frameId == snapFrame + 30)]
  viseReleaseYPos <- play$y[which(play$nflId == viseID & play$frameId == snapFrame + 30)]
  
  # left side of field , right of jammer
  if (gunnerStartYPos < 26.65 & gunnerReleaseYPos > viseReleaseYPos) {
    specialistData$release[i] <- 1 # inside
  }
  
  # left side of field, left of jammer
  if (gunnerStartYPos < 26.65 & gunnerReleaseYPos < viseReleaseYPos) {
    specialistData$release[i] <- 0 # outside
  }
  
  # right side of field, right of jammer
  if (gunnerStartYPos > 26.65 & gunnerReleaseYPos > viseReleaseYPos) {
    specialistData$release[i] <- 0 # outside
  }
  
  # right side of field, left of jammer
  if (gunnerStartYPos > 26.65 & gunnerReleaseYPos < viseReleaseYPos) {
    specialistData$release[i] <- 1 # inside
  }
  
}

head(specialistData)

## Record Kick Direction Relative to Gunner's Position
specialistData$kickDirRelGun <- ifelse(specialistData$gunnerSide == specialistData$kickDir, 
                                       'SS', 
                                       specialistData$kickDirRelGun)

specialistData$kickDirRelGun <- ifelse(specialistData$kickDir == 'C', 
                                       'C', 
                                       specialistData$kickDirRelGun)

specialistData$kickDirRelGun <- ifelse(specialistData$kickDir != 'C' & 
                                         specialistData$gunnerSide != specialistData$kickDir,
                                       'OS', 
                                       specialistData$kickDirRelGun)

specialistData$kickDirRelGun[which(is.na(specialistData$kickDir))] <- NA

head(specialistData)

## Categorize Each Release Type
specialistData$cat[which(specialistData$release == 0 & specialistData$kickDirRelGun == 'SS')] <- 0
specialistData$cat[which(specialistData$release == 0 & specialistData$kickDirRelGun == 'OS')] <- 1
specialistData$cat[which(specialistData$release == 0 & specialistData$kickDirRelGun == 'C')] <- 2
specialistData$cat[which(specialistData$release == 1 & specialistData$kickDirRelGun == 'C')] <- 3
specialistData$cat[which(specialistData$release == 1 & specialistData$kickDirRelGun == 'OS')] <- 4
specialistData$cat[which(specialistData$release == 1 & specialistData$kickDirRelGun == 'SS')] <- 5

head(specialistData)

## Categorize Each Release as Correct or Incorrect
specialistData$correctRelease[which(specialistData$cat == 0 | 
                                      specialistData$cat == 4 | 
                                      specialistData$cat == 3)] <- 1

specialistData$correctRelease[which(specialistData$cat == 1 | 
                                      specialistData$cat == 5 | 
                                      specialistData$cat == 2)] <- 0

head(specialistData)

########################################
# Remove Unnecessary Variables
########################################
specialistData <- specialistData[c("gameId", "playId", "gunnerTeam", "gunnerId",
                                   "gunnerName","viseTeam", "viseId", "viseName", 
                                   "timeToBeatVise", "firstManDown", "disFromLOS", 
                                   "disFromReturner", "speedDev", "topSpeed", 
                                   "tackle", "missedTackle", "squeezeDis", "returnYds", 
                                   "specialTeamsResult", "release", "correctRelease")]

########################################
# Write to .csv
########################################
write.csv(specialistData, file = here("data", "specialist_data.csv"), row.names = FALSE)