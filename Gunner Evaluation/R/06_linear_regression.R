############################################################
## Linear Model (Expected Yards Given Up on a Return)
## Hunter Hopkins
############################################################

########################################
# Source File
########################################
library(tidyverse)
library(car)
library(MASS)
library(here)

source(here("R", "00_source.R"))

########################################
# Import Data
########################################
specialistData <- read.csv(here("data", "specialist_data.csv"), 
                           na.strings = c('NA', NA, '', ' '))

# subset data to only returns
returns <- specialistData[which(specialistData$specialTeamsResult == 'Return'), ]

########################################
# Model Creation
########################################
fullModel <- lm(returnYds ~ timeToBeatVise + disFromLOS + disFromReturner + topSpeed + squeezeDis + missedTackle + speedDev + release + correctRelease,
                data = na.omit(returns))

nullModel <- lm(returnYds ~ 1, data = na.omit(returns))

stepAIC(nullModel, scope = list(lower = nullModel, upper = fullModel), k = 2, direction = "forward")

fSelectedAIC <- lm(returnYds ~ timeToBeatVise + disFromReturner + speedDev + 
                     squeezeDis + disFromLOS + missedTackle, 
                   data = na.omit(returns))

########################################
# Model Evaluation
########################################

## Check For Collinearity
car::vif(fSelectedAIC)

## Summarizing Model
summary(fSelectedAIC)