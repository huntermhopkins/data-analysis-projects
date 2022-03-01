# It might be necessary to increase the amount of memory allocated to R
# to be able to load in larger data sets.

# memory.limit(size = 32701)

#############################################################
## Author: Michael Lopez (edited by Hunter Hopkins)
##
## Description: Animates a random play and saves to current working directory
##              File name is saved under *gameId*_*playId*.gif
##
## Argument(s):
##  trackingData: Data frame - data frame including tracking data
##
## Returns: Animated .gif file
#############################################################

animate.random.play <- function (trackingData) {
  
  require(tidyverse)
  require(gganimate)
  require(gifski)
  require(cowplot)
  require(png)
  
  # pick a random game
  randomGame <- trackingData %>% filter(gameId == trackingData$gameId[sample(c(1:nrow(trackingData)), 1)])
  
  # pick a random play
  examplePlay <- randomGame %>% filter(playId == randomGame$playId[sample(c(1:nrow(randomGame)), 1)])
  
  # general field boundaries
  xmin <- 0
  xmax <- 160/3
  hash.right <- 38.35
  hash.left <- 12
  hash.width <- 3.3
  
  # Specific boundaries for a given play
  ymin <- max(round(min(examplePlay$x, na.rm = TRUE) - 10, -1), 0)
  ymax <- min(round(max(examplePlay$x, na.rm = TRUE) + 10, -1), 120)
  df_hash <- expand.grid(x = c(0, 23.36667, 29.96667, xmax), y = (10:110))
  df_hash <- df_hash %>% filter(!(floor(y %% 5) == 0))
  df_hash <- df_hash %>% filter(y < ymax, y > ymin)
  
  animate_play <- ggplot() +
    scale_size_manual(values = c(6, 4, 6), guide = "none") + 
    scale_shape_manual(values = c(21, 16, 21), guide = "none") +
    scale_fill_manual(values = c("#e31837", "#654321", "#002244"), guide = "none") + 
    scale_colour_manual(values = c("black", "#654321", "#c60c30"), guide = "none") +
    annotate("text", x = df_hash$x[df_hash$x < 55/2], 
             y = df_hash$y[df_hash$x < 55/2], label = "_", hjust = 0, vjust = -0.2) + 
    annotate("text", x = df_hash$x[df_hash$x > 55/2], 
             y = df_hash$y[df_hash$x > 55/2], label = "_", hjust = 1, vjust = -0.2) + 
    annotate("segment", x = xmin, 
             y = seq(max(10, ymin), min(ymax, 110), by = 5), 
             xend =  xmax, 
             yend = seq(max(10, ymin), min(ymax, 110), by = 5)) + 
    annotate("text", x = rep(hash.left, 11), y = seq(10, 110, by = 10), 
             label = c("G   ", seq(10, 50, by = 10), rev(seq(10, 40, by = 10)), "   G"), 
             angle = 270, size = 4) + 
    annotate("text", x = rep((xmax - hash.left), 11), y = seq(10, 110, by = 10), 
             label = c("   G", seq(10, 50, by = 10), rev(seq(10, 40, by = 10)), "G   "), 
             angle = 90, size = 4) + 
    annotate("segment", x = c(xmin, xmin, xmax, xmax), 
             y = c(ymin, ymax, ymax, ymin), 
             xend = c(xmin, xmax, xmax, xmin), 
             yend = c(ymax, ymax, ymin, ymin), colour = "black") + 
    geom_point(data = examplePlay, aes(x = (xmax-y), y = x, shape = team,
                                       fill = team, group = nflId, size = team, colour = team), alpha = 0.7) + 
    geom_text(data = examplePlay, aes(x = (xmax-y), y = x, label = jerseyNumber), colour = "white", 
              vjust = 0.36, size = 3.5) + 
    ylim(ymin, ymax) + 
    coord_fixed() +  
    theme_void() + 
    transition_time(frameId)  +
    ease_aes('linear') + 
    NULL
  
  ## Ensure timing of play matches 10 frames-per-second
  play.length.ex <- length(unique(examplePlay$frameId))
  playAnim <- animate(animate_play, fps = 10, nframe = play.length.ex, renderer = gifski_renderer())
  anim_save(paste(paste(examplePlay$gameId, examplePlay$playId, sep = '_'), '.gif', sep = ''), animation = playAnim)
  
}

#############################################################
## Author: Michael Lopez (edited by Hunter Hopkins)
##
## Description: Animates a specific play and saves to current working directory
##              File name is saved under *gameId*_*playId*.gif
##
## Argument(s):
##  trackingData: Data frame - data frame including tracking data
##  gameId: Game ID of desired play
##  playId: Play ID of desired play
##
## Returns: Animated .gif file
#############################################################

animate.play <- function (trackingData, gameID, playID) {
  
  require(tidyverse)
  require(gganimate)
  require(gifski)
  require(cowplot)
  require(png)

  # pick a random game
  game <- trackingData %>% filter(gameId == gameID)
  
  # pick a random play
  examplePlay <- game %>% filter(playId == playID)
  
  # general field boundaries
  xmin <- 0
  xmax <- 160/3
  hash.right <- 38.35
  hash.left <- 12
  hash.width <- 3.3
  
  # Specific boundaries for a given play
  ymin <- max(round(min(examplePlay$x, na.rm = TRUE) - 10, -1), 0)
  ymax <- min(round(max(examplePlay$x, na.rm = TRUE) + 10, -1), 120)
  df_hash <- expand.grid(x = c(0, 23.36667, 29.96667, xmax), y = (10:110))
  df_hash <- df_hash %>% filter(!(floor(y %% 5) == 0))
  df_hash <- df_hash %>% filter(y < ymax, y > ymin)
  
  animate_play <- ggplot() +
    scale_size_manual(values = c(6, 4, 6), guide = "none") + 
    scale_shape_manual(values = c(21, 16, 21), guide = "none") +
    scale_fill_manual(values = c("#e31837", "#654321", "#002244"), guide = "none") + 
    scale_colour_manual(values = c("black", "#654321", "#c60c30"), guide = "none") +
    annotate("text", x = df_hash$x[df_hash$x < 55/2], 
             y = df_hash$y[df_hash$x < 55/2], label = "_", hjust = 0, vjust = -0.2) + 
    annotate("text", x = df_hash$x[df_hash$x > 55/2], 
             y = df_hash$y[df_hash$x > 55/2], label = "_", hjust = 1, vjust = -0.2) + 
    annotate("segment", x = xmin, 
             y = seq(max(10, ymin), min(ymax, 110), by = 5), 
             xend =  xmax, 
             yend = seq(max(10, ymin), min(ymax, 110), by = 5)) + 
    annotate("text", x = rep(hash.left, 11), y = seq(10, 110, by = 10), 
             label = c("G   ", seq(10, 50, by = 10), rev(seq(10, 40, by = 10)), "   G"), 
             angle = 270, size = 4) + 
    annotate("text", x = rep((xmax - hash.left), 11), y = seq(10, 110, by = 10), 
             label = c("   G", seq(10, 50, by = 10), rev(seq(10, 40, by = 10)), "G   "), 
             angle = 90, size = 4) + 
    annotate("segment", x = c(xmin, xmin, xmax, xmax), 
             y = c(ymin, ymax, ymax, ymin), 
             xend = c(xmin, xmax, xmax, xmin), 
             yend = c(ymax, ymax, ymin, ymin), colour = "black") + 
    geom_point(data = examplePlay, aes(x = (xmax-y), y = x, shape = team,
                                       fill = team, group = nflId, size = team, colour = team), alpha = 0.7) + 
    geom_text(data = examplePlay, aes(x = (xmax-y), y = x, label = jerseyNumber), colour = "white", 
              vjust = 0.36, size = 3.5) + 
    ylim(ymin, ymax) + 
    coord_fixed() + 
    theme_void() +
    labs(subtitle = 'Frame: {frame_time}') +
    transition_time(frameId)  +
    ease_aes('linear') + 
    NULL
  
  ## Ensure timing of play matches 10 frames-per-second
  play.length.ex <- length(unique(examplePlay$frameId))
  playAnim <- animate(animate_play, fps = 10, nframe = play.length.ex, renderer = gifski_renderer())
  anim_save(paste(paste(examplePlay$gameId, examplePlay$playId, sep = '_'), '.gif', sep = ''), animation = playAnim)
  
}

#############################################################
## Author: Hunter Hopkins
##
## Description: Finds 2 dimensional Euclidean distances between 2 points
##
## Argument(s):
##  p: Vector - Vector of X coordinates
##  q: Vector - Vector of Y coordinates
##
## Returns: Number
#############################################################

eucDis <- function(p, q) {
  (sqrt((p[1] - q[1])^2 + (p[2] - q[2])^2))
}

#############################################################
## Author: Andrie (https://stackoverflow.com/users/602276/andrie)
##
## Description: Returns a sub string of characters starting from
##              The end of the string
##
## Argument(s):
##  x: String - String to pull sub string out of
##  n: Number - Number of characters to pull from end of string
##
## Returns: String
#############################################################
substrRight <- function(x, n) {
  substr(x, nchar(x)-n+1, nchar(x))
}
