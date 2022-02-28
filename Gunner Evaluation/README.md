# Business Case
Despite being some of the most important players on the roster, there are currently no publicly available stats for NFL gunners. Quarterbacks have easily digestible measurements such as touchdowns thrown or pass completion percentage. Wide Receivers have receiving yards and catches. Being able to evaluate gunners at a quick glance in the same way could help add important context to their contributions to their team.

Scott Pioli, an NFL Media Analyst said, "The final 5-10 spots on the roster are often made up of players who are core special teams contibuters." Not only could data help coaches and front offices decide who should take up those final spots, but also how much money they should earn.

The NFL uses [Next Gen Stats](https://operations.nfl.com/gameday/technology/nfl-next-gen-stats/) to track ball and player movement during each play. How can teams leverage this to assess their players and make more informed roster decisions? My goal was to first turn this tracking data into player measurements such as the time it takes a gunner to beat the jammer defending them, or their distance from the returner at the point of the ball being caught. Using these basic measurements, a coach could see where this player stacks up against other players in that postion. Furthermore, I used these basic measurements to create two models to create some more advanced statistics: One that predicts how many yards a gunner is expected to give up on a punt play, and one that predicts a gunner's probability of forcing a fair catch.

Email: hopkinshunterm@gmail.com

# Background
Gunners are fielded during punt plays. Teams will most often punt the ball on their final down in an attempt to pin the opposing team as far back as they can before possession changes. The gunner's job is to run down the sideline as quickly as possible to tackle the returner. The returner might also be tempted to signal for a fair catch, in which case the ball is called dead as soon as they catch it. The gunner's complement on the oppsing team is known as a jammer or vise. Jammers are tasked with stopping the gunner from making it downfield to give the returner room to advance the ball.

These two positions engage in a physical battle every play. It involves pushing, pulling, and grabbing at each other all while running at top speed. An example can be seen below.

![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/gunner_example.gif)

Notice the gunner in the white jersey at the top of the screen make his way past the two jammers defending him. After a quick shove and some nimble movement, he's able to blow by them and make a shoestring tackle on the returner.

# Table of Contents
<details open>
<summary>Show/Hide</summary>
<br>
  
1. [File Descriptions](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/README.md#file-descriptions)
2. [Structure of Notebooks](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/README.md#structure-of-notebooks)
3. [Executive Summary](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/README.md#executive-summary)
</details>

# File Descriptions
<details>
<summary>Show/Hide</summary>
<br>
  
* [data](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/data): Folder containing all data files
  * **trackingData2018.csv**: Tracking data for all special team plays during the 2018 NFL season.
  * **trackingData2019.csv**: Tracking data for all special team during the 2019 NFL season.
  * **trackingData2020.csv**: Tracking data for all special team during the 2020 NFL season.
  * **plays.csv**: Play-level information from each game.
  * **games.csv**: Contains the teams playing in each game.
  * **PFFScoutingData.csv**: Play-level scouting information provided by [PFF](https://www.pff.com/).
  * **punt_play_info.csv**: Additional processed play-level information.
  * **punt_plays.csv**: Combination of tracking data, play data, game data, and PFF data for punt plays.
  * **specialist_data.csv**: Derived features for gunners and some play-level information.
  * **FMD_data.csv**: Subset of specialist_data.csv containing only the first gunner down the field. Used for training model.
  * **gunner_stats_FCP.csv**: Logistic model results showing the probability of a gunner causing a fair catch.
  * **gunner_stats_exYds.csv**: Linear model results showing the expected return yards for each gunner.
* [images](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/images): Player headshots used in plots.
* [notebooks](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/notebooks): R notebooks overviewing analysis process and code.
    * **00_functions.html**: Documentation of functions used throughout project
    * **01_clean_raw_data.html**: Condense data and process some variables
    * **02_collect_punt_info.html**: Processing and storing some important play-level information
    * **03_collect_gunner_data.html**: Engineering features for models
    * **04_logistic_regression.html**: Creating and evaluating logistic model
    * **05_probability_of_fair_catch.html**: Visualizing results of logistic model
    * **06_linear_regression.html**: Creating and evaluating linear model
    * **07_expected_yards.html**: Visualizing results of linear model
    * **08_final_vis.html**: Visualizing combined results of logistic and linear model
* [output](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/output): Model outputs and plots.
</details>

# Structure of Notebooks
<details>
<summary>Show/Hide</summary>
<br>
  
0. Functions
    * 0.1 Animate Random Play
    * 0.2 Animate Play
    * 0.3 Find Euclidean Distance
    * 0.4 Find Substring From End of String
  
1. Combining Data and Early Cleaning
    * 1.1 Importing 2018 Data
    * 1.2 Clean 2018 Punt Plays
      * 1.2.1 Exploring How Many Gunners, Jammers, and Returners are Usually Fielded
      * 1.2.2 Condense Play Selection
      * 1.2.3 Remove Rows with NAs in Certain Columns
      * 1.2.4 Flip Plays
      * 1.2.5 Add *teamAbbr* Variable
      * 1.2.6 Set The Return Yards to Zero on Plays That Resulted in a Fair Catch
  
2. Gathering Play Information
    * 2.1 Imports
    * 2.2 Create New Dataframe to Store Important Play Information
    * 2.3 Fill *snapFrame*, *catchFrame*, and *ballCatchRow* Columns
    * 2.4 Fill *kickDir* Column
    * 2.5 Fill *returnYds* and *specialTeamsResult* Columns
    * 2.6 Write to .csv
  
3. Collecting Gunner Data (Feature Engineering)
    * 3.1 Imports
    * 3.2 Create New Dataframe to Store Gunner Data
    * 3.3 Store Identifying Information for Gunners and Jammers
      * 3.3.1 Remove Plays with Missing Player IDs
    * 3.4 Remove Odd Plays
    * 3.5 Match Gunners to Jammer Defending Them
    * 3.6 Fill *returnYds* and *specialTeamsResult* Columns
    * 3.7 Fill *timeToBeatVise* Column
    * 3.8 Fill *firstManDown* Column
    * 3.9 Fill *disFromLOS* Column
    * 3.10 Fill *disFromReturner* Column
    * 3.11 Fill *speedDev* Column
    * 3.12 Fill *topSpeed* Column
    * 3.13 Fill *squeezeDis* Column
    * 3.14 Record if Gunner Made a Tackle
    * 3.15 Record if Gunner Missed a Tackle
    * 3.16 Record Gunner Release Types
      * 3.16.1 Record Which Side of the Field Each Gunner is Lined Up
      * 3.16.2 Classify as Inside or Outside
      * 3.16.3 Record Kick Direction Relative to Gunner's Position
      * 3.16.4 Categorize Each Release Type
      * 3.16.5 Categorize Each Release as Correct or Incorrect
    * 3.17 Remove Unnecessary Variables
    * 3.18 Write to .csv
  
4. Logistic Model
    * 4.1 Imports
    * 4.2 Change Variables to Factors
    * 4.3 Subset Data to Only Include First Man Down
    * 4.4 Create Models
    * 4.5 Compare Models
      * 4.5.1 Model Summaries
      * 4.5.2 Likelihood Ratio Test
    * 4.6 Evaluate Model
    * 4.7 Conclusion
    * 4.8 Write to .csv

5. Visualizing Logistic Model Results
    * 5.1 Imports
    * 5.2 Record Model Results
      * 5.2.1 Create Dataframe to Store Gunner Data
      * 5.2.2 Record Gunner Averages
      * 5.2.3 Predict Probability of Causing a Fair Catch Based on Averages
      * 5.2.4 Filter to Gunners Who Played in at Least 30 Plays
    * 5.3 Visualization
    * 5.4 Write to .csv
    * 5.5 Save Plot
 
6. Linear Model
    * 6.1 Imports
    * 6.2 Model Creation
    * 6.3 Model Evaulation
      * 6.3.1 Checking For Collinearity
      * 6.3.2 Summarizing Model
    * 6.4 Conclusion
  

7. Visualizing Logistic Model Results
    * 7.1 Imports
    * 7.2 Record Model Results
      * 7.2.1 Create Dataframe to Store Gunner Data
      * 7.2.2 Record Gunner Averages
      * 7.2.3 Predict Expected Yards Given Up Based on Averages
      * 7.2.4 Filter to Gunners Who Played in at Least 30 Plays
    * 7.3 Visualization
    * 7.4 Write to .csv
    * 7.5 Save Plot
  
8. Visualizing Combined Results
    * 8.1 Imports
    * 8.2 Inverse Fair Catch Probability
    * 8.3 Visualization
    * 8.4 Save Plot
</details>

# Executive Summary

### Early Cleaning
<details open>
<summary>Show/Hide</summary>
<br>
These charts show the number of gunners, jammers, and returners fielded in each play. Based on these frequencies, I decided to only look at plays with 2 gunners, 2 jammers, and 1 returner. I did not think it was fair to judge a gunner going against one jammer in the same way as a gunner being double teamed. This also helped simplify many of the calculations made in the analysis.
<br>

![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/number_of_gunners.png)
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/number_of_jammers.png)
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/number_of_returners.png)
  
I also decided to remove punts that were muffed or dropped by the returner. I felt that there were a lot of variables that could lead to the punt being dropped outside of the gunner's control. A returner might drop the ball due to nerves, weather. or a moment's lapse of focus. Including these might muddy the results of the models.

</details>

### Feature Engineering
<details open>
<summary>Show/Hide</summary>
<br>
The NFL's tracking data records each players x and y coordinates on the field every tenth of a second. A lot of insights can be made from this data, but it is not very useful in its raw state. My goal was to turn this data into useable measurements.
  
#### Time to Beat Jammer
This measures the time it takes the gunner to get past the jammer defending them in seconds. The gunner must then be able to continuously stay past the jammer up until the ball is caught. If a gunner is able to get past their jammer quickly, they have a straight shot at the returner. This should either cause a fair catch or allow the gunner to make a quick tackle.
  
This is done by comparing the gunner's distance to the returner with the jammer's distance to the returner for each frame of the play. Once the gunner is closer to the returner and has beaten the jammer defending him, it's possible to find the time it has taken by dividing the frame number by ten.
  
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/time_to_beat.gif)
  
#### Distance from Line of Scrimmage
This is the gunner’s distance from the line of scrimmage at the point of the ball being caught. A gunner who is able to make it further down the field should either be able to force a fair catch, or make a tackle quicker.
  
This is possible by finding the frame at which the ball is caught, and then finding the difference between the gunner's position and the line of scrimmage.

![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/dis_los.gif)
  
#### Distance from Returner
This is the gunner’s distance from the returner at the point of the ball being caught.
  
Again, I checked the distance between the jammer and the returner at the frame when the ball was caught.
  
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/dis_returner.gif)
  
#### Speed Deviation
This is the standard deviation of a gunner’s speed up until the point of the ball being caught. My thinking is that a more consistent speed indicates that the gunner is skilled or strong enough to keep their top speed while the jammer pushes and pulls on them.
  
The tracking data also provides each player's speed at each frame. This made measuring this as easy as finding all of the frames up to the ball being caught, and taking the standard deviation of the speed.
  
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/speed_dev.gif)
  
#### Top Speed
This tracks a gunner’s top speed up until the ball is caught.
  
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/speed.gif)
  
#### Squeeze Distance
Once the ball is caught, gunners are trained to move towards the center of the field and push the returner towards the sideline. This creates a net for the rest of the team to trap the returner in. This measurement attempts to show how well a gunner is able to push the returner to the sideline by taking the difference between the returners position when they caught the ball, and their average position after they caught the ball.
  
![](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/squeeze_dis.gif)
  
#### Release Types

A release is essentially how the gunner moves off of the line of scrimmage. This can be classified in two ways. One way is either an inside or outside release. An inside release is when the gunner begins moving towards the center of the field, and an outside release is when they start moving towards the sideline. Another way I classified each gunner’s release was as correct or incorrect. A correct release would be releasing in the direction that gives the gunner the most direct route to the ball. In the example below, both gunners would be taking the correct release asumming that the ball was kicked to the right.
  
Each release was classified as inside or outside by comparing the gunner's position to the jammer's position three seconds after the ball was snapped. This was to ensure that the gunner was actually moving in that direction and not just trying to misdirect the jammer.
  
Once each release was classified as inside or outside, it was possible to label it as correct or incorrect by comparing it with which side of the field the ball was kicked.
  
<h5 align="center">Inside Release (Left) vs. Outside Release (Right)</h5>
<table><tr><td><img src='https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/inside.gif' width=500></td><td><img src='https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/outside.gif' width=500></td></tr></table>
  

</details>
