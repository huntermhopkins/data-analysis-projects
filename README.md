# gunner-evaluation
The goal of this project is to develop novel ways to measure the performance of gunners in the National Football League using Next Gen Stats tracking data.

There are 4 folders:
  * data - all data files in .csv format
  * images - player headshots for charts using ggimage
  * output - imporant outputs (graphs, plots, model outputs)
  * R - all .R scripts

The R folder contains 18 R scripts:
  * 00_source - the source file that contains all functions and organizes the directory.
  * 01_clean_raw_data - combines 

In the first .R file (00_source.R) you have to change the first handful of lines to the path to each respective folder.
e.g., wd$data <- 'path to data folder', wd$output <- 'path to output folder', etc.

All .csv files generated from the .R scripts are included in the data folder, so it is possible to jump into any .R script without running the previous ones.
