# Getting and cleaning data course project
This read me file explains how the run_analysis.R works and how to run the code. 

## Grabbing the raw data
The raw data for the analysis is provided [here] (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
If you're on a mac, the included [downloadData.R](downloadData.R) has a single function ```downloadData()``` that will grab the archive and unzip it if the archive doesn't yet exist. It may work on other OS's but hasn't been tested on them. Either way, to start the analysis you want to have the data archive expanded into a folder next to [run_analysis.R](run_analysis.R). The folder name is expected to be ```UCI HAR Dataset``
