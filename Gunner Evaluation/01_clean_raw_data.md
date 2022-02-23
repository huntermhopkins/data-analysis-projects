---
title: '1. Combining Data and Early Cleaning '
output:
  html_document:
    df_print: paged
    keep_md: true
---
The original data had three files: *plays.csv*, *games.csv*, *PFFScoutingData.csv*, along with the tracking data for the 2018, 2019, and 2020 seasons. I wanted to combine all of these into one data set, reduce it to the observations and variables that I needed for my analysis, and clean/change some variables.

## 1.1 Importing 2018 Data


```r
source("E:/R Projects/gunner_evaluation/R/00_source.R")

library(tidyverse)
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.1 --
```

```
## v ggplot2 3.3.5     v purrr   0.3.4
## v tibble  3.1.5     v dplyr   1.0.7
## v tidyr   1.1.4     v stringr 1.4.0
## v readr   2.0.2     v forcats 0.5.1
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
trackingData <- read.csv(paste0(wd$data, 'tracking2018.csv'))
playData <- read.csv(paste0(wd$data, 'plays.csv'))
gameData <- read.csv(paste0(wd$data, 'games.csv'))
PFFData <- read.csv(paste0(wd$data, 'PFFScoutingData.csv'))

mergedData <- trackingData %>% 
  inner_join(PFFData) %>% 
  inner_join(playData) %>% 
  inner_join(gameData)
```

```
## Joining, by = c("gameId", "playId")
```

```
## Joining, by = c("gameId", "playId")
```

```
## Joining, by = "gameId"
```

## 1.2 Clean 2018 Punt Plays
Looking at 5 rows shows the structure of some important variables. This dataset includes all special teams plays. Gunners and vises/jammers are listed with their team abbreviation and jersey number separated by a semi-colon. There could also be a different number of gunners and jammers on each play.

```r
mergedData[c(6628454, 1407808, 23, 56465), c("specialTeamsPlayType", "gunners", "vises", "returnerId")]
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["specialTeamsPlayType"],"name":[1],"type":["chr"],"align":["left"]},{"label":["gunners"],"name":[2],"type":["chr"],"align":["left"]},{"label":["vises"],"name":[3],"type":["chr"],"align":["left"]},{"label":["returnerId"],"name":[4],"type":["chr"],"align":["left"]}],"data":[{"1":"Field Goal","2":"NA","3":"NA","4":"NA","_rn_":"6628454"},{"1":"Punt","2":"SF 13; SF 11; SF 26","3":"CHI 22; CHI 36; CHI 31; CHI 30","4":"44932","_rn_":"1407808"},{"1":"Kickoff","2":"NA","3":"NA","4":"44837","_rn_":"23"},{"1":"Punt","2":"BAL 26; BAL 28","3":"CLE 27; CLE 31","4":"46174","_rn_":"56465"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### 1.2.1 Exploring How Many Gunners, Jammers, and Returners are Usually Fielded
Since the players in each position (gunner, jammer, returner) are separated by a semi-colon, the number of players can be found by counting the number of semi-colons and adding one. Here we can see that most plays feature 2 gunners, 2 jammers, and 1 returner. For simplicity, I will only be looking at these plays in my analysis. 


```r
ggplot(data=PFFData, aes(x=str_count(gunners, ';') + 1)) +
  geom_bar(stat="count", fill = "steelblue") +
  ggtitle("Number of Gunners in Each Play") +
  xlab("Number of Gunners Fielded")
```

![](01_clean_raw_data_files/figure-html/unnamed-chunk-3-1.png)<!-- -->


```r
ggplot(data=PFFData, aes(x=str_count(vises, ';') + 1)) +
  geom_bar(stat="count", fill = "steelblue") +
  ggtitle("Number of Jammers in Each Play") +
  xlab("Number of Jammers Fielded")
```

![](01_clean_raw_data_files/figure-html/unnamed-chunk-4-1.png)<!-- -->


```r
ggplot(data=playData, aes(x=str_count(returnerId, ';') + 1)) +
  geom_bar(stat="count", fill = "steelblue") +
  ggtitle("Number of Returners in Each Play") +
  xlab("Number of Returners Fielded")
```

![](01_clean_raw_data_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

### 1.2.2 Condense Play Selection
Any non-punt plays can be removed by filtering the *specialTeamsPlayType* variable to 'Punt'. Plays with an unwanted number of gunners, jammers, or returners can be removed by counting the number of semi-colons. I will also be removing plays that were muffed.

```r
puntPlays <- (mergedData %>% filter(specialTeamsPlayType == 'Punt' &
                                    specialTeamsResult != 'Muffed' &
                                    str_count(gunners, ';') == 1 & 
                                    str_count(vises, ';') == 1 & 
                                    str_count(returnerId, ';') == 0))
```

### 1.2.3 Remove Rows with NAs in Certain Columns
Later in the analysis, I will need to know at which point the ball is caught. This is possible using the *event* variable. This variable designates if an important event happened at the frame e.g., "fair_catch", "punt_received", "punt_land". However, there are some plays where none of these events are listed. To estimate when the ball is caught, I can add the *operationTime* and *hangTime* variables to the frame that the ball was snapped. Because these variables are needed, I will remove any rows that contain an NA value in these columns.

```r
sapply(puntPlays[c("operationTime", "hangTime")], 
       function(x) sum(is.na(x)))
```

```
## operationTime      hangTime 
##          1978          3795
```

```r
puntPlays <- puntPlays[complete.cases(puntPlays[c('operationTime', 'hangTime')]), ]
```
### 1.2.4 Flip Plays
Some plays are going left-to-right while others are going right-to-left. To make each play consistent, I can subtract the yardline number and players' x-coordinate from 120.

```r
puntPlays$x <- ifelse(puntPlays$playDirection == 'left',
                      120 - puntPlays$x, 
                      puntPlays$x)

puntPlays$absoluteYardlineNumber <- ifelse(puntPlays$playDirection == 'left', 
                                           120 - puntPlays$absoluteYardlineNumber,
                                           puntPlays$absoluteYardlineNumber)
```

### 1.2.5 Add *teamAbbr* Variable
The data does not include a variable that explicitly states what team each player plays for. Only a variable that says if the player is home or away and variables that list the home and away teams.

```r
puntPlays$teamAbbr <- ifelse(puntPlays$team == 'home',
                             puntPlays$homeTeamAbbr,
                             puntPlays$visitorTeamAbbr)

puntPlays[c(500, 121516, 70510), c("displayName", "team", "homeTeamAbbr", "visitorTeamAbbr", "teamAbbr")]
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["displayName"],"name":[1],"type":["chr"],"align":["left"]},{"label":["team"],"name":[2],"type":["chr"],"align":["left"]},{"label":["homeTeamAbbr"],"name":[3],"type":["chr"],"align":["left"]},{"label":["visitorTeamAbbr"],"name":[4],"type":["chr"],"align":["left"]},{"label":["teamAbbr"],"name":[5],"type":["chr"],"align":["left"]}],"data":[{"1":"Brent Urban","2":"home","3":"BAL","4":"CLE","5":"BAL","_rn_":"500"},{"1":"Nick Dzubnar","2":"away","3":"DEN","4":"LAC","5":"LAC","_rn_":"121516"},{"1":"Matthew Slater","2":"home","3":"NE","4":"NYJ","5":"NE","_rn_":"70510"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
### 1.2.6 Set The Return Yards to Zero on Plays That Resulted in a Fair Catch
Currently, the data lists the return yardage as NA for plays that resulted in a fair catch. For my purposes, it makes sense to count them as zero yard returns to reflect how many yards a gunner gave up.

```r
puntPlays$returnYds[which(puntPlays$specialTeamsResult == 'Fair Catch')] <- 0
```

**Note: This process was then repeated for the 2019 and 2020 data sets.**
