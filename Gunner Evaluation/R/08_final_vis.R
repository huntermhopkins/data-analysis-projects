############################################################
## Visualizing Combined Results
## Hunter Hopkins
############################################################

########################################
# Source File
########################################
library(tidyverse)
library(ggimage)
library(ggrepel)
library(here)

source(here("R", "00_source.R"))

########################################
# Import Data
########################################
gunnerExYds <- read.csv(here("data", "gunner_stats_exYds.csv"), 
                        na.strings = c('NA', NA, '', ' '))

gunnerFCL <- read.csv(here("data", "gunner_stats_FCP.csv"), 
                      na.strings = c('NA', NA, '', ' '))

# join dataframes
gunnerStats <- cbind(gunnerExYds, FCP = gunnerFCL$FCP)

########################################
# Inverse Fair Catch Probability
########################################
gunnerStats$returnProb <- (1 - gunnerStats$FCP)

########################################
# Visualization
########################################
ggplot() +
  geom_point(data = gunnerStats, aes(x = returnProb, y = exReturnYds)) +
  geom_vline(xintercept = mean(gunnerStats$returnProb), color = 'red', alpha = 0.7, linetype = 'dashed') +
  geom_hline(yintercept = mean(gunnerStats$exReturnYds), color = 'red', alpha = 0.7, linetype = 'dashed') +
  annotate('text', x = 0.41, y = 8.5, label = 'Good Before Catch, Bad After Catch') +
  annotate('text', x = 0.41, y = 4, label = 'Good Before Catch, Good After Catch') +
  annotate('text', x = 0.6625, y = 8.5, label = 'Bad Before Catch, Bad After Catch') +
  annotate('text', x = 0.6625, y = 4, label = 'Bad Before Catch, Good After Catch') +
  geom_label_repel(data = gunnerStats, aes(x = returnProb, y = exReturnYds, label = gunnerName)) +
  labs(title = 'Overall Gunner Performance', subtitle = 'Must Have Played in at Least 30 Plays') +
  xlab('Probability of Allowing Return') +
  ylab('Expected Return Yards')

########################################
# Save Plot
########################################
ggsave("final_vis.png", path = here("output"), width = 9.7082, height = 6)