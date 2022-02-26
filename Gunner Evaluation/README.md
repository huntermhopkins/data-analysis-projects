# Business Case
Despite being some of the most important players on the roster, there are currently no publicly available stats for NFL gunners. Quarterbacks have easily digestible measurements such as touchdowns thrown or pass completion percentage. Wide Receivers have receiving yards and catches. Being able to evaluate gunners at a quick glance in the same way could help add important context to their contributions to their team.

Scott Pioli, an NFL Media Analyst said, "The final 5-10 spots on the roster are often made up of players who are core special teams contibuters." Not only could data help coaches and front offices decide who should take up those final spots, but also how much money they should earn.

The NFL uses [Next Gen Stats](https://operations.nfl.com/gameday/technology/nfl-next-gen-stats/) to track ball and player movement during each play. How can teams leverage this to assess their players and make more informed roster decisions? My goal was to first turn this tracking data into player measurements such as the time it takes a gunner to beat the jammer defending them, or their distance from the returner at the point of the ball being caught. Using these basic measurements, a coach could see where this player stacks up against other players in that postion. Furthermore, I used these basic measurements to create two models to create some more advanced statistics: One that predicts how many yards a gunner is expected to give up on a punt play, and one that predicts a gunner's probability of forcing a fair catch.

# Table of Contents
<details open>
  <summary> Show/Hide</summary>
  
  1. [File Descriptions](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/README.md#file-descriptions)
  2. [Structure of Notebooks](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/README.md#structure-of-notebooks)
  3. [Executive Summary](https://github.com/huntermhopkins/data-analysis-projects/blob/main/Gunner%20Evaluation/README.md#executive-summary)
  
</details>

# File Descriptions
<details>
  <summary> Show/Hide</summary>
  
  * [data](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/data): Folder containing all data files
    * trackingData2018.csv: Tracking data for all special team plays during the 2018 NFL season.
    * trackingData2019.csv: Tracking data for all special team during the 2019 NFL season.
    * trackingData2020.csv: Tracking data for all special team during the 2020 NFL season.
    * plays.csv: Play-level information from each game.
    * games.csv: Contains the teams playing in each game.
    * PFFScoutingData.csv: Play-level scouting information provided by [PFF](https://www.pff.com/).
    * punt_play_info.csv: Additional processed play-level information.
    * punt_plays.csv: Combination of tracking data, play data, game data, and PFF data for punt plays.
    * specialist_data.csv: Derived features for gunners and some play-level information.
    * FMD_data.csv: Subset of specialist_data.csv containing only the first gunner down the field. Used for training model.
    * gunner_stats_FCP.csv: Logistic model results showing the probability of a gunner causing a fair catch.
    * gunner_stats_exYds.csv: Linear model results showing the expected return yards for each gunner.
  * [images](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/images): Player headshots used in plots.
  * [notebooks](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/notebooks): R notebooks overviewing analysis process and code.
  * [output](https://github.com/huntermhopkins/data-analysis-projects/tree/main/Gunner%20Evaluation/output): Model outputs and plots.
  
</details>

# Structure of Notebooks
<details>
  <summary> Show/Hide</summary>
  
</details>

# Executive Summary
<details>
  <summary> Show/Hide</summary>
  
</details>
