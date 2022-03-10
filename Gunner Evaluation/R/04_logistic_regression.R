############################################################
## Logistic Model (Probability of Causing a Fair Catch)
## Hunter Hopkins
############################################################

########################################
# Source File
########################################
library(tidyverse)
library(caret)
library(lmtest)
library(MASS)
library(here)

source(here("R", "00_source.R"))

########################################
# Import Data
########################################
specialistData <- read.csv(here("data", "specialist_data.csv"), 
                           na.strings = c('NA', NA, '', ' '))

########################################
# Change Variables to Factors
########################################
specialistData$fairCatch <- ifelse(specialistData$specialTeamsResult == 'Fair Catch', 1, 0)

specialistData$correctRelease <- as.factor(specialistData$correctRelease)
specialistData$release <- as.factor(specialistData$release)

########################################
# Subset Data to Only Include
# First Man Down
########################################
FMDData <- specialistData %>% filter(firstManDown == 1)

# remove NAs
FMDData <- FMDData[complete.cases(FMDData[c('timeToBeatVise', 'returnYds')]), ]

########################################
# Create Models
########################################
# create full model
FMDLogitFull <- glm(fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS + release + correctRelease + topSpeed + speedDev, 
                    data = FMDData, 
                    family = 'binomial')

# null model
FMDLogitNull <- glm(fairCatch ~ 1, data = FMDData, family = 'binomial')

# select vars with forward stepwise selection (AIC)
stepAIC(FMDLogitNull, scope = list(lower = FMDLogitNull, upper = FMDLogitFull), 
        k = 2, direction = "forward")

fSelectedLogitAIC <- glm(fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS + topSpeed, 
                         family = "binomial", 
                         data = FMDData)

## Using BIC
stepAIC(FMDLogitNull, scope = list(lower = FMDLogitNull, upper = FMDLogitFull), 
        k = log(nrow(FMDData)), direction = "forward")

fSelectedLogitBIC <- glm(fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS, 
                         family = "binomial", 
                         data = FMDData)

########################################
# Compare Models
########################################

## Model Summaries
summary(fSelectedLogitAIC)
summary(fSelectedLogitBIC)

## Likelihood Ratio Test
lrtest(fSelectedLogitBIC, fSelectedLogitAIC)

########################################
# Evaluate Model
########################################
set.seed(60)

k <- 10
kFoldAccuracy <- numeric(k)
CVFolds <- createFolds(FMDData$fairCatch, k=k, returnTrain = T)

concatConfMatrix <- matrix(0, nrow = 2, ncol = 2)

for (i in 1:k) {
  folds <- CVFolds[[i]]
  train <- FMDData[folds, ]
  valid <- FMDData[-folds, ]
  
  fSelectedLogitAIC <- glm(fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS + topSpeed, 
                           family = "binomial", 
                           data = FMDData)
  
  fitted.results <- predict(fSelectedLogitAIC,newdata = valid,type = 'response')
  fitted.results <- ifelse(fitted.results > 0.5,1,0)
  misClasificError <- mean(fitted.results != valid$fairCatch)
  
  kFoldAccuracy[i] <- 1 - misClasificError
  
  confMatrix <- confusionMatrix(as.factor(fitted.results), as.factor(valid$fairCatch))
  
  concatConfMatrix <- confMatrix$table + concatConfMatrix
}

mean(kFoldAccuracy)

## Concatenated Confusion Matrix
confusionDF <- data.frame(trueClass = factor(c(0, 0, 1, 1)),
                          predictedClass = factor(c(0, 1, 0, 1)),
                          Y = c(concatConfMatrix[1, 1], concatConfMatrix[2, 1], concatConfMatrix[1, 2], concatConfMatrix[2, 2]))

ggplot(confusionDF, aes(x = trueClass, y = predictedClass)) +
  geom_tile(aes(fill = Y)) +
  geom_text(aes(label = sprintf("%1.0f", Y)), vjust = 1) +
  scale_fill_gradient(low = "red",
                      high = "blue",
                      trans = "log") +
  scale_x_discrete(labels = c("0" = "Return", "1" = "Fair Catch")) +
  scale_y_discrete(labels = c("0" = "Return", "1" = "Fair Catch")) +
  theme(legend.position = "none") + 
  xlab("True Class") +
  ylab("Predicted Class") +
  ggtitle("Concatenated Confusion Matrix")

########################################
# Save Plot
########################################
ggsave("confusion_matrix.png", path = here("output"), width = 9.7082, height = 6)

########################################
# Write to .csv
########################################
write.csv(FMDData, file = here("data", "FMD_data.csv"), row.names = FALSE)