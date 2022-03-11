############################################################
## Processing Play-Level Information
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

########################################
# Create new DF
########################################
puntPlaysID <- unique(puntPlays[c('gameId', 'playId')])

puntPlayInfo <- data.frame(gameId = puntPlaysID$gameId,
                           playId = puntPlaysID$playId,
                           snapFrame = numeric(nrow(puntPlaysID)),
                           catchFrame = numeric(nrow(puntPlaysID)),
                           kickDir = character(nrow(puntPlaysID)),
                           returnYds = numeric(nrow(puntPlaysID)),
                           specialTeamsResult = character(nrow(puntPlaysID)))


########################################
# Fill snapFrame, catchFrame, and
# ballCatchRow Columns
########################################

## When is ball snapped?
ballSnapFrame <- puntPlays$frameId[puntPlays$event == 'ball_snap' &
                                  puntPlays$displayName == 'football']
table(ballSnapFrame)

for (i in 1:nrow(puntPlayInfo)) {
  play <- puntPlays %>% filter(gameId == puntPlayInfo$gameId[i] & 
                                 playId == puntPlayInfo$playId[i])
  
  puntPlayInfo$snapFrame[i] <- play$frameId[which(play$event == 'ball_snap')][1]
  
  if (is.na(puntPlayInfo$snapFrame[i])) {
    puntPlayInfo$snapFrame[i] <- 11
  }
  
  catchFrameCands <- play$frameId[which(play$event == 'fair_catch' | 
                                          play$event == 'punt_received' |
                                          play$event == 'punt_land')]
  if(length(catchFrameCands) > 0) {
    puntPlayInfo$catchFrame[i] <- max(catchFrameCands)
  } else {
    puntPlayInfo$catchFrame[i] <- puntPlayInfo$snapFrame[i] + 
      ceiling(play$operationTime[1] * 10) + 
      ceiling(play$hangTime[1] * 10)
  }
}

head(puntPlayInfo)

########################################
# Fill kickDir Column
########################################
for (i in 1:nrow(puntPlayInfo)) {
  play <- puntPlays %>% filter(gameId == puntPlayInfo$gameId[i] & 
                               playId == puntPlayInfo$playId[i])
  
  puntPlayInfo$kickDir[i] <- play$kickDirectionActual[1]
}

head(puntPlayInfo)

########################################
# Fill returnYds and specialTeamsResult
# Columns
########################################
returnYds <- numeric(nrow(puntPlayInfo))
for (i in 1:nrow(puntPlayInfo)) {
  play <- puntPlays %>% filter(gameId == puntPlayInfo$gameId[i] & 
                                 playId == puntPlayInfo$playId[i])
  
  puntPlayInfo$specialTeamsResult[i] <- play$specialTeamsResult[1]
  returnYds[i] <- play$kickReturnYardage[1]
}
puntPlayInfo$returnYds <- returnYds

head(puntPlayInfo)

########################################
# Write to .csv
########################################
write.csv(puntPlayInfo, here("data", "punt_play_info.csv"), row.names = FALSE)