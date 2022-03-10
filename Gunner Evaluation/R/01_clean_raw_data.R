############################################################
## Combining Data and Early Cleaning
## Hunter Hopkins
############################################################

########################################
# Source File
########################################
library(tidyverse)
library(here)

source(here("R", "00_source.R"))

########################################
# Import 2018 Data
########################################

trackingData <- read.csv(here("data", "trackingData2018.csv"))
playData <- read.csv(here("data", "plays.csv"))
gameData <- read.csv(here("data", "games.csv"))
PFFData <- read.csv(here("data", "PFFScoutingData.csv"))

mergedData <- trackingData %>% 
  inner_join(PFFData) %>% 
  inner_join(playData) %>% 
  inner_join(gameData)

# remove unneeded data frames to save on memory if needed
# rm(trackingData, playData, gameData, PFFData)
# gc()

str(mergedData)

###########################################
# Clean punt plays
###########################################

# exploring how many gunners, jammers, and returners are usually fielded
ggplot(data=PFFData, aes(x=str_count(gunners, ';') + 1)) +
  geom_bar(stat="count", fill = "steelblue") +
  ggtitle("Number of Gunners in Each Play") +
  xlab("Number of Gunners Fielded")

ggplot(data=PFFData, aes(x=str_count(vises, ';') + 1)) +
  geom_bar(stat="count", fill = "steelblue") +
  ggtitle("Number of Jammers in Each Play") +
  xlab("Number of Jammers Fielded")

ggplot(data=playData, aes(x=str_count(returnerId, ';') + 1)) +
  geom_bar(stat="count", fill = "steelblue") +
  ggtitle("Number of Returners in Each Play") +
  xlab("Number of Returners Fielded")

# subset to punt plays with 1-on-1 matchups and 1 returner
puntPlays <- (mergedData %>% filter(specialTeamsPlayType == 'Punt' &
                                      specialTeamsResult != 'Muffed' &
                                      str_count(gunners, ';') == 1 & 
                                      str_count(vises, ';') == 1 & 
                                      str_count(returnerId, ';') == 0))
head(puntPlays)

# remove unneeded data frames to save on memory if needed
# rm(mergedData)
# gc()

# remove plays with missing returner ID. Causes problems with processing data down the line
puntPlays <- puntPlays[complete.cases(puntPlays[c('returnerId', 'operationTime', 'hangTime')]), ]


# make all plays go in the same direction
puntPlays$x <- ifelse(puntPlays$playDirection == 'left',
                      120 - puntPlays$x, 
                      puntPlays$x)

puntPlays$absoluteYardlineNumber <- ifelse(puntPlays$playDirection == 'left', 
                                           120 - puntPlays$absoluteYardlineNumber,
                                           puntPlays$absoluteYardlineNumber)


# add a column that shows what team the player plays for
puntPlays$teamAbbr <- ifelse(puntPlays$team == 'home',
                             puntPlays$homeTeamAbbr,
                             puntPlays$visitorTeamAbbr)


head(puntPlays)

# remove unneccesary variables
puntPlays <- puntPlays[, c('x', 'y', 's', 'event', 'nflId', 'displayName',
                           'jerseyNumber', 'team', 'frameId', 'gameId', 'playId',
                           'operationTime', 'hangTime', 'kickDirectionActual',
                           'missedTackler', 'tackler', 'gunners', 'vises',
                           'possessionTeam', 'specialTeamsResult',
                           'returnerId', 'kickReturnYardage', 'kickLength',
                           'absoluteYardlineNumber', 'teamAbbr')]

puntPlays$kickReturnYardage[which(puntPlays$specialTeamsResult == 'Fair Catch')] <- 0

data.table::fwrite(puntPlays, file = here("data", "punt_plays2018.csv"))

# remove unneeded data frames to save on memory
rm(puntPlays, mergedData, trackingData)
gc()

########################################
# Import 2019 Data
########################################

trackingData <- read.csv(here("data", "trackingData2019.csv"))

# read other files if removed
# playData <- read.csv(here("data", "plays.csv"))
# gameData <- read.csv(here("data", "games.csv"))
# PFFData <- read.csv(here("data", "PFFScoutingData.csv"))

mergedData <- trackingData %>% 
  inner_join(PFFData) %>% 
  inner_join(playData) %>% 
  inner_join(gameData)

# remove unneeded data frames to save on memory if needed
# rm(trackingData, playData, gameData, PFFData)
# gc()


str(mergedData)

###########################################
# Clean punt plays
###########################################

# subset to punt plays with 1-on-1 matchups and 1 returner
puntPlays <- (mergedData %>% filter(specialTeamsPlayType == 'Punt' &
                                      specialTeamsResult != 'Muffed' &
                                      str_count(gunners, ';') == 1 & 
                                      str_count(vises, ';') == 1 & 
                                      str_count(returnerId, ';') == 0))
head(puntPlays)

# remove unneeded data frames to save on memory if needed
# rm(mergedData)
# gc()


# remove plays with missing returner ID. Causes problems with proccessing data down the line
puntPlays <- puntPlays[complete.cases(puntPlays[c('returnerId', 'operationTime', 'hangTime')]), ]

# make all plays go in the same direction
puntPlays$x <- ifelse(puntPlays$playDirection == 'left',
                      120 - puntPlays$x, 
                      puntPlays$x)

puntPlays$absoluteYardlineNumber <- ifelse(puntPlays$playDirection == 'left', 
                                           120 - puntPlays$absoluteYardlineNumber,
                                           puntPlays$absoluteYardlineNumber)


# add a column that shows what team the player plays for
puntPlays$teamAbbr <- ifelse(puntPlays$team == 'home',
                             puntPlays$homeTeamAbbr,
                             puntPlays$visitorTeamAbbr)

# remove unneccesary variables
puntPlays <- puntPlays[, c('x', 'y', 's', 'event', 'nflId', 'displayName',
                           'jerseyNumber', 'team', 'frameId', 'gameId', 'playId',
                           'operationTime', 'hangTime', 'kickDirectionActual',
                           'missedTackler', 'tackler', 'gunners', 'vises',
                           'possessionTeam', 'specialTeamsResult',
                           'returnerId', 'kickReturnYardage', 'kickLength',
                           'absoluteYardlineNumber', 'teamAbbr')]

head(puntPlays)

puntPlays$kickReturnYardage[which(puntPlays$specialTeamsResult == 'Fair Catch')] <- 0

data.table::fwrite(puntPlays, file = here("data", "punt_plays2019.csv"))

# remove unneeded data frames to save on memory
rm(puntPlays, mergedData, trackingData)
gc()

########################################
# Import 2020 Data
########################################

trackingData <- read.csv(here("data", "trackingData2020.csv"))

# read other files if removed
# playData <- read.csv(here("data", "plays.csv"))
# gameData <- read.csv(here("data", "games.csv"))
# PFFData <- read.csv(here("data", "PFFScoutingData.csv"))

mergedData <- trackingData %>% 
  inner_join(PFFData) %>% 
  inner_join(playData) %>% 
  inner_join(gameData)

# remove unneeded data frames to save on memory if needed
# rm(trackingData, playData, gameData, PFFData)
# gc()


str(mergedData)

###########################################
# Clean punt plays
###########################################

# subset to punt plays with 1-on-1 matchups and 1 returner
puntPlays <- (mergedData %>% filter(specialTeamsPlayType == 'Punt' &
                                      specialTeamsResult != 'Muffed' &
                                      str_count(gunners, ';') == 1 & 
                                      str_count(vises, ';') == 1 & 
                                      str_count(returnerId, ';') == 0))
head(puntPlays)

# remove unneeded data frames to save on memory if needed
# rm(mergedData)
# gc()


# remove plays with missing returner ID. Causes problems with proccessing data down the line
puntPlays <- puntPlays[complete.cases(puntPlays[c('returnerId', 'operationTime', 'hangTime')]), ]

# make all plays go in the same direction
puntPlays$x <- ifelse(puntPlays$playDirection == 'left',
                      120 - puntPlays$x, 
                      puntPlays$x)

puntPlays$absoluteYardlineNumber <- ifelse(puntPlays$playDirection == 'left', 
                                           120 - puntPlays$absoluteYardlineNumber,
                                           puntPlays$absoluteYardlineNumber)


# add a column that shows what team the player plays for
puntPlays$teamAbbr <- ifelse(puntPlays$team == 'home',
                             puntPlays$homeTeamAbbr,
                             puntPlays$visitorTeamAbbr)

# remove unneccesary variables
puntPlays <- puntPlays[, c('x', 'y', 's', 'event', 'nflId', 'displayName',
                           'jerseyNumber', 'team', 'frameId', 'gameId', 'playId',
                           'operationTime', 'hangTime', 'kickDirectionActual',
                           'missedTackler', 'tackler', 'gunners', 'vises',
                           'possessionTeam', 'specialTeamsResult',
                           'returnerId', 'kickReturnYardage', 'kickLength',
                           'absoluteYardlineNumber', 'teamAbbr')]

head(puntPlays)

puntPlays$kickReturnYardage[which(puntPlays$specialTeamsResult == 'Fair Catch')] <- 0

data.table::fwrite(puntPlays, file = here("data", "punt_plays2020.csv"))

# remove unneeded data frames to save on memory
rm(puntPlays, mergedData, trackingData, gameData, PFFData, playData)
gc()

########################################
# Combine all punt plays
########################################

puntPlays2018 <- read.csv(here("data", "punt_plays2018.csv"))
puntPlays2019 <- read.csv(here("data", "punt_plays2019.csv"))
puntPlays2020 <- read.csv(here("data", "punt_plays2020.csv"))

puntPlaysMerged <- rbind(puntPlays2018, puntPlays2019, puntPlays2020)

data.table::fwrite(puntPlaysMerged, file = here("data", "punt_plays.csv"))
