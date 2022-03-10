# Business Case
Despite being some of the most important players on the roster, there are currently no publicly available stats for NFL gunners. Quarterbacks have easily digestible measurements such as touchdowns thrown or pass completion percentage. Wide receivers have receiving yards and catches. Being able to evaluate gunners at a quick glance in the same way could help add important context to their contributions to their team.

Scott Pioli, an NFL Media Analyst said, "The final 5-10 spots on the roster are often made up of players who are core special teams contributers." Not only could data help coaches and front offices decide who should take up those final spots, but also how much money they should earn.

The NFL uses [Next Gen Stats](https://operations.nfl.com/gameday/technology/nfl-next-gen-stats/) to track ball and player movement during each play. How can teams leverage this to assess their players and make more informed roster decisions? My goal was to first turn this tracking data into player measurements such as the time it takes a gunner to beat the jammer defending them, or their distance from the returner at the point of the ball being caught. Using these basic measurements, a coach could see where this player stacks up against other players in that position. Furthermore, I used these basic measurements to create two models to create some more advanced statistics: One that predicts how many yards a gunner is expected to give up on a punt play, and one that predicts a gunner's probability of forcing a fair catch.

Email: hopkinshunterm@gmail.com

# Background
Gunners are fielded during punt plays. Teams will most often punt the ball on their final down in an attempt to pin the opposing team as far back as they can before possession changes. The gunner's job is to run down the sideline as quickly as possible to tackle the returner. The returner might also be tempted to signal for a fair catch, in which case the ball is called dead as soon as they catch it. The gunner's complement on the opposing team is known as a jammer or vise. Jammers are tasked with stopping the gunner from making it downfield to give the returner room to advance the ball.

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

A release is essentially how the gunner moves off of the line of scrimmage. This can be classified in two ways. One way is either an inside or outside release. An inside release is when the gunner begins moving towards the center of the field, and an outside release is when they start moving towards the sideline. Another way I classified each gunner’s release was as correct or incorrect. A correct release would be releasing in the direction that gives the gunner the most direct route to the ball. In the example below, both gunners would be taking the correct release assuming that the ball was kicked to the right.

Each release was classified as inside or outside by comparing the gunner's position to the jammer's position three seconds after the ball was snapped. This was to ensure that the gunner was actually moving in that direction and not just trying to misdirect the jammer.

Once each release was classified as inside or outside, it was possible to label it as correct or incorrect by comparing it with which side of the field the ball was kicked.

<h5 align="center">Inside Release (Left) vs. Outside Release (Right)</h5>
<table><tr><td><img src='https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/inside.gif' width=500></td><td><img src='https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/output/outside.gif' width=500></td></tr></table>

#### Other Variables
Some other variables already provided in the data that I included were:
* Tackles - Designates whether the gunner made a tackle during the play
* Missed Tackles - Designates whether the gunner missed a tackle during the play
</details>

### Logistic Regression Model
<details open>
<summary>Show/Hide</summary>
<br>

#### Model Creation
Using regression techniques, I will attempt to grade each gunner in two areas: before the ball is caught and after the ball is caught. To grade them before the ball is caught, I will be using a logistic regression model to estimate each gunners' probability of causing a fair catch. Forcing a fair catch is one of the most favorable outcomes for the punting team as it doesn't allow the receiving team to advance the ball at all.

I created two logistic models to compare using forward-stepwise selection. This is a process of adding variables into the model one-by-one to select the variables with the most predictive power. The first model was selected using Akaike information criterion (AIC) as the selection criterion. The final variables selected were the time it takes the gunner to beat the jammer, their distance from the returner, their distance from the line of scrimmage, and their top speed.

<details>
<summary>Show/Hide Stepwise Selection Ouput</summary>
<br>

```
## Start:  AIC=2858.11
## fairCatch ~ 1
##
##                   Df Deviance    AIC
## + timeToBeatVise   1   2421.6 2425.6
## + disFromReturner  1   2463.4 2467.4
## + release          1   2830.5 2834.5
## + disFromLOS       1   2838.5 2842.5
## + correctRelease   1   2847.3 2851.3
## + topSpeed         1   2847.5 2851.5
## + speedDev         1   2848.7 2852.7
## <none>                 2856.1 2858.1
##
## Step:  AIC=2425.58
## fairCatch ~ timeToBeatVise
##
##                   Df Deviance    AIC
## + disFromReturner  1   2212.1 2218.1
## + disFromLOS       1   2390.1 2396.1
## + topSpeed         1   2408.7 2414.7
## + speedDev         1   2417.9 2423.9
## <none>                 2421.6 2425.6
## + release          1   2420.7 2426.7
## + correctRelease   1   2421.1 2427.1
##
## Step:  AIC=2218.14
## fairCatch ~ timeToBeatVise + disFromReturner
##
##                  Df Deviance    AIC
## + disFromLOS      1   2090.8 2098.8
## + topSpeed        1   2157.4 2165.4
## + speedDev        1   2195.9 2203.9
## + release         1   2208.6 2216.6
## <none>                2212.1 2218.1
## + correctRelease  1   2212.1 2220.1
##
## Step:  AIC=2098.81
## fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS
##
##                  Df Deviance    AIC
## + topSpeed        1   2086.8 2096.8
## + speedDev        1   2087.7 2097.7
## <none>                2090.8 2098.8
## + release         1   2090.6 2100.6
## + correctRelease  1   2090.6 2100.6
##
## Step:  AIC=2096.77
## fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS + topSpeed
##
##                  Df Deviance    AIC
## <none>                2086.8 2096.8
## + speedDev        1   2086.2 2098.2
## + correctRelease  1   2086.6 2098.6
## + release         1   2086.7 2098.7
```
</details>
    
Next, I created another model using forward-stepwise selection, but this time with Bayesian Information Criterion (BIC) as the selection criterion. BIC is a more conservative selection criterion and should select less variables in the model. Having two models allows me to make comparisons and select the most accurate model. Using BIC ended up dropping top speed from the model.
    
<details>
<summary>Show/Hide Stepwise Selection Output</summary>
<br>

```
## Start:  AIC=2863.76
## fairCatch ~ 1
##
##                   Df Deviance    AIC
## + timeToBeatVise   1   2421.6 2436.9
## + disFromReturner  1   2463.4 2478.7
## + release          1   2830.5 2845.8
## + disFromLOS       1   2838.5 2853.8
## + correctRelease   1   2847.3 2862.6
## + topSpeed         1   2847.5 2862.8
## <none>                 2856.1 2863.8
## + speedDev         1   2848.7 2864.0
##
## Step:  AIC=2436.88
## fairCatch ~ timeToBeatVise
##
##                   Df Deviance    AIC
## + disFromReturner  1   2212.1 2235.1
## + disFromLOS       1   2390.1 2413.0
## + topSpeed         1   2408.7 2431.6
## <none>                 2421.6 2436.9
## + speedDev         1   2417.9 2440.9
## + release          1   2420.7 2443.6
## + correctRelease   1   2421.1 2444.0
##
## Step:  AIC=2235.09
## fairCatch ~ timeToBeatVise + disFromReturner
##
##                  Df Deviance    AIC
## + disFromLOS      1   2090.8 2121.4
## + topSpeed        1   2157.4 2188.0
## + speedDev        1   2195.9 2226.5
## <none>                2212.1 2235.1
## + release         1   2208.6 2239.2
## + correctRelease  1   2212.1 2242.7
##
## Step:  AIC=2121.41
## fairCatch ~ timeToBeatVise + disFromReturner + disFromLOS
##
##                  Df Deviance    AIC
## <none>                2090.8 2121.4
## + topSpeed        1   2086.8 2125.0
## + speedDev        1   2087.7 2125.9
## + release         1   2090.6 2128.8
## + correctRelease  1   2090.6 2128.9
```
</details>

#### Comparing Models

Looking at the model summaries, the model selected using AIC has a lower residual deviance value than the model selected using BIC. This indicates that the first model fits the data better. Additionally, the first model has a lower AIC value. This also indicates that it is the superior model.

<details>
<summary>Show/Hide Model Outputs</summary>
<br>

##### Model Selected Using AIC

```
##
## Call:
## glm(formula = fairCatch ~ timeToBeatVise + disFromReturner +
##     disFromLOS + topSpeed, family = "binomial", data = FMDData)
##
## Deviance Residuals:
##     Min       1Q   Median       3Q      Max  
## -2.9045  -0.7645   0.4366   0.7836   2.5075  
##
## Coefficients:
##                 Estimate Std. Error z value Pr(>|z|)    
## (Intercept)      9.76882    1.00781   9.693  < 2e-16 ***
## timeToBeatVise  -0.45296    0.03313 -13.674  < 2e-16 ***
## disFromReturner -0.16662    0.01072 -15.538  < 2e-16 ***
## disFromLOS      -0.08949    0.01104  -8.109  5.1e-16 ***
## topSpeed        -0.21651    0.10805  -2.004   0.0451 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for binomial family taken to be 1)
##
##     Null deviance: 2856.1  on 2101  degrees of freedom
## Residual deviance: 2086.8  on 2097  degrees of freedom
## AIC: 2096.8
##
## Number of Fisher Scoring iterations: 5
```
                                                    
##### Model Selected Using BIC
```
##
## Call:
## glm(formula = fairCatch ~ timeToBeatVise + disFromReturner +
##     disFromLOS, family = "binomial", data = FMDData)
##
## Deviance Residuals:
##     Min       1Q   Median       3Q      Max  
## -2.9385  -0.7702   0.4369   0.7836   2.5794  
##
## Coefficients:
##                  Estimate Std. Error z value Pr(>|z|)    
## (Intercept)      8.016199   0.481439   16.65   <2e-16 ***
## timeToBeatVise  -0.433127   0.031153  -13.90   <2e-16 ***
## disFromReturner -0.164789   0.010658  -15.46   <2e-16 ***
## disFromLOS      -0.100603   0.009634  -10.44   <2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for binomial family taken to be 1)
##
##     Null deviance: 2856.1  on 2101  degrees of freedom
## Residual deviance: 2090.8  on 2098  degrees of freedom
## AIC: 2098.8
##
## Number of Fisher Scoring iterations: 5
```
</details>

Because the two models are hierarchical, a Likelihood Ratio Test can be used to compare the models. The test shows that the p-value is 0.0444. This means the null hypothesis can be rejected at a .05 significance level, suggesting that the complex model (AIC) provides a better fit to the data.

<details>
<summary>Show/Hide LRT Results</summary>
<br>

| Df         | LogLik     | Df       | Chisq    | Pr(>Chisq) |
| ---------- | ---------- | -------- | -------- | ---------- |
| 4          | -1045.405  |          |          |            |
| 5          | -1043.385  | 1        | 4.041304 | 0.04439949 |
</details>

#### Evaluate Model

To estimate the accuracy of the model, the data was split into a training and testing set. The model is trained on the training set and the values in the testing set are fitted using the resulting model. The use of a logistic regression model ensures that the fitted values are between 0 and 1, representing the probability of the play resulting in a fair catch. These estimated probabilities are compared to a cut-off point, in this case 0.5, to classify each observation as a fair catch or return. Any probability greater than 0.5 is classified as a fair catch and anything lower than 0.5 is classified as a return according to the model. The model's predicted classifications are then compared to the true classifications in the testing set. Furthermore, this process was done using k-fold cross validation. This allows for this accuracy test to be performed on a number of training and testing sets to give a more accurate estimation.

The results can be seen in the confusion matrix below. Out of 2102 plays, the model correctly classified 1035 plays that resulted in a fair catch and 545 plays that resulted in a return. 190 plays that resulted in a fair catch were predicted to be returned and 332 plays that were returned were predicted to have resulted in a fair catch. This gives the model an accuracy of about 75.17%.

[]!()

#### Visualizing Model Results
I then took the per game averages of each gunner for these predictor variables. These averages were fitted using the model to show the best gunners in the NFL during the 2018-2020 seasons based on their predicted probability of causing a fair catch.

[]!()
</details>

### Linear Regression Model
<details open>
<summary>Show/Hide</summary>
<br>

To evaluate the gunners' performance after the ball is caught, I will be adding the squeeze distance, tackles, and missed tackles variables to a linear model. The previous variables discussed will still be included because they will have an impact on what happens after the catch. This model will attempt to predict how many return yards a gunner will give up in the event that the ball is returned.

##### Model Creation
Similar to the logistic regression model, I will be using forward stepwise selection to pick out the variables with the most predictive power. These turned out to be the time it takes the gunner to beat their jammer, their distance from the returner, their speed deviation, their distance from the line of scrimmage, and the number of tackles they missed.

<details>
<summary>Show/Hide Stepwise Selection Output</summary>
<br>

```
## Start:  AIC=8153.49
## returnYds ~ 1
## 
##                   Df Sum of Sq    RSS    AIC
## + timeToBeatVise   1   11187.1 190730 8058.1
## + disFromReturner  1    6510.5 195406 8099.5
## + squeezeDis       1    5211.4 196706 8110.8
## + speedDev         1    1516.5 200400 8142.6
## + disFromLOS       1     484.1 201433 8151.4
## + correctRelease   1     427.5 201489 8151.9
## + topSpeed         1     376.3 201541 8152.3
## <none>                         201917 8153.5
## + missedTackle     1      74.2 201843 8154.9
## + release          1      22.7 201894 8155.3
## 
## Step:  AIC=8058.13
## returnYds ~ timeToBeatVise
## 
##                   Df Sum of Sq    RSS    AIC
## + squeezeDis       1    3792.3 186938 8025.8
## + disFromReturner  1    3327.7 187402 8030.1
## + speedDev         1    3099.6 187630 8032.1
## + topSpeed         1    1648.4 189081 8045.3
## + disFromLOS       1     878.1 189852 8052.3
## + correctRelease   1     324.9 190405 8057.2
## <none>                         190730 8058.1
## + missedTackle     1     189.7 190540 8058.4
## + release          1       3.5 190726 8060.1
## 
## Step:  AIC=8025.83
## returnYds ~ timeToBeatVise + squeezeDis
## 
##                   Df Sum of Sq    RSS    AIC
## + disFromReturner  1    3213.8 183724 7998.2
## + speedDev         1    2806.7 184131 8002.0
## + topSpeed         1    1516.5 185421 8013.9
## + disFromLOS       1     803.9 186134 8020.5
## + correctRelease   1     275.9 186662 8025.3
## + missedTackle     1     238.3 186699 8025.7
## <none>                         186938 8025.8
## + release          1       0.4 186937 8027.8
## 
## Step:  AIC=7998.21
## returnYds ~ timeToBeatVise + squeezeDis + disFromReturner
## 
##                  Df Sum of Sq    RSS    AIC
## + speedDev        1    4730.3 178993 7955.7
## + topSpeed        1    4505.7 179218 7957.8
## + disFromLOS      1    4233.8 179490 7960.4
## + missedTackle    1     648.5 183075 7994.2
## + correctRelease  1     299.5 183424 7997.4
## <none>                        183724 7998.2
## + release         1      31.3 183692 7999.9
## 
## Step:  AIC=7955.66
## returnYds ~ timeToBeatVise + squeezeDis + disFromReturner + speedDev
## 
##                  Df Sum of Sq    RSS    AIC
## + disFromLOS      1   2185.97 176807 7936.7
## + topSpeed        1    843.66 178150 7949.6
## + missedTackle    1    491.30 178502 7953.0
## <none>                        178993 7955.7
## + correctRelease  1    207.83 178786 7955.7
## + release         1     12.99 178980 7957.5
## 
## Step:  AIC=7936.67
## returnYds ~ timeToBeatVise + squeezeDis + disFromReturner + speedDev + 
##     disFromLOS
## 
##                  Df Sum of Sq    RSS    AIC
## + missedTackle    1    442.23 176365 7934.4
## <none>                        176807 7936.7
## + correctRelease  1     81.98 176725 7937.9
## + topSpeed        1     77.03 176730 7937.9
## + release         1     18.44 176789 7938.5
## 
## Step:  AIC=7934.4
## returnYds ~ timeToBeatVise + squeezeDis + disFromReturner + speedDev + 
##     disFromLOS + missedTackle
## 
##                  Df Sum of Sq    RSS    AIC
## <none>                        176365 7934.4
## + correctRelease  1   105.047 176260 7935.4
## + topSpeed        1    74.646 176291 7935.7
## + release         1    13.594 176352 7936.3
```
</details>

#### Model Evaluation
The model selected both the distance from returner and the distance from the line of scrimmage. Due to these measurements being similar in nature, they may have collinearity issues. We can see if this is an issue by measuring each variables' Variable Inflation Factor (VIF). Since each variables' VIF is close to one, we can say that there are no collinearity issues with any of the variables in the model.

<details>
<summary>Show/Hide VIF</summary>
<br>

```
##  timeToBeatVise disFromReturner        speedDev      squeezeDis      disFromLOS 
##        1.085289        1.433633        1.196985        1.014758        1.464056 
##    missedTackle 
##        1.036119
```
</details>

The model summary shows that each variable is significant to the model based on their low p-values. However, the model's adjusted $R{2}$ is very low at 0.1235. This means that the model can only account for 12.35% of the variability in the data. The low adjusted $R{2}$ combined with the significant variables tells me that the variables selected have predictive power, but more variables need to be included in the model to improve accuracy.

<details>
<summary>Show/Hide VIF</summary>
<br>

```
## 
## Call:
## lm(formula = returnYds ~ timeToBeatVise + disFromReturner + speedDev + 
##     squeezeDis + disFromLOS + missedTackle, data = na.omit(returns))
## 
## Residuals:
##     Min      1Q  Median      3Q     Max 
## -25.501  -5.266  -1.324   3.188  83.181 
## 
## Coefficients:
##                  Estimate Std. Error t value Pr(>|t|)    
## (Intercept)     -18.85802    2.48533  -7.588 5.33e-14 ***
## timeToBeatVise    0.72978    0.08684   8.403  < 2e-16 ***
## disFromReturner   0.34669    0.04056   8.549  < 2e-16 ***
## speedDev          3.44783    0.68928   5.002 6.26e-07 ***
## squeezeDis       -0.18482    0.03315  -5.576 2.86e-08 ***
## disFromLOS        0.19452    0.04285   4.540 6.03e-06 ***
## missedTackle      2.01879    0.97751   2.065   0.0391 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 10.18 on 1701 degrees of freedom
## Multiple R-squared:  0.1265, Adjusted R-squared:  0.1235 
## F-statistic: 41.07 on 6 and 1701 DF,  p-value: < 2.2e-16
```
</details>

#### Visualizing Model Results

Again, I took the per-game averages for each gunner and fit these with the model. Below are the top ten gunners in expected return yards between the 2018-2020 NFL seasons.

![]()
</details>

### Visualizing Combined Results
<details open>
<summary>Show/Hide</summary>
<br>

These two new measurements: probability of causing a fair catch and expected return yards given up can be combined to show how each gunner performs in each area. The inverse of the probability of causing a fair catch is plotted instead, which is the probability of allowing a return. This allows both measurements to be read the same way (lower number is better, higher number is worse). Players like Justin Bethel, Mack Hollins, Tavierre Thomas, and Matthew Slater perform well overall. Players like Sherrick McManis allow few return yards when the ball is returned, but might need to work on beating their man to force more fair catches.

![]()
</details>

### Conclusions, Shortcomings, and Future Research
<details open>
<summary>Show/Hide</summary>
<br>

One question that may arise is, "Why should predicted values be used in place of the observed values?" To estimate the probability of a gunner causing a fair catch, it would be possible to just divide the number of plays that resulted in a fair catch by the total number of plays. It is also possible to simply compute the average yards each gunner gave up. However, one problem with this is that there are two gunners in each play, but only one result. This means one gunner's averages might become inflated by virtue of playing with a top gunner. By predicting these values based on each gunners' individual measurements, the models provide insight into how each gunner is contributing to the result of the play. The process of feature engineering also created variables that hold predictive power and can be used on their own to evaluate gunners.

The models may have been held back by the fact that I was only looking at one-on-one scenarios. Looking at how gunners perform when being double teamed might have improved the results of the model. The biggest downfall of the linear model is the lack of variables to explain a complex scenario. If more research was done into this analysis, it would be necessary to include more variables. One thing I have in mind is missed tackle opportunities. The data included missed tackles, but I believe this only counted scenarios where the gunner physically lunged at the returner and failed to bring him down. There are also times when a gunner may be in a position to make a tackle, but doesn't or isn't able to physically lunge at the player. Maybe the returner was able to misdirect them and trip them up, or they might've been able to outrun them before they could attempt a tackle. Including this in the analysis would show how well a gunner is able to make tackles in the open field, which is an important skill. It would also be beneficial to include safeties in the analysis somehow. Safeties are sometimes fielded further downfield to assist jammers in stopping the gunners.

The logistic model is not superbly accurate. However, I believe it is accurate enough to provide useful insights, and be used in conjunction with a coach's or general manager's intuition. The linear model performed very poorly, but all of the variables selected in the model were deemed highly significant. There may be value in using these individual measurements to evaluate and compare gunners.
</details>
