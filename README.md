# Getting and cleaning data course project
This read me file explains how the run_analysis.R works and how to run the code. 

## Grabbing the raw data
The raw data for the analysis is provided [here] (https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
If you're on a mac, the included [downloadData.R](downloadData.R) has a single function ```downloadData()``` that will grab the archive and unzip it if the archive doesn't yet exist. It may work on other OS's but hasn't been tested on them. Either way, to start the analysis you want to have the data archive expanded into a folder next to [run_analysis.R](run_analysis.R). The folder name is expected to be ```UCI HAR Dataset```

## Required Packages
In order for the analysis to run, you will need to have the ```dplyr``` and ```reshape2``` packages installed.

## Running the analysis 
Once you have the data archive downloaded and expanded, you can run the analysis. This is done simply by executing the following:
```
run_analysis()

```
or, if you have changed the name / path of the archive folder:
```
run_analysis('path to archive folder')
```

## Output of analysis
The analysis gathers data from the test and training set, extracts only measurements on the mean or standard deviation, and summarizes the value by subject and activity. The result is a table that is written out to a file [analyzed_activity_data.txt](analyzed_activity_data.txt). The function will also display the table on screen.

If you want to read the table back into R, you can do so with the following code:
```
file_path <- 'analyzed_activity_data.txt'
data <- read.table(file_path, header = TRUE)
View(data)
```

## The code book
The code book describing each of the variables can be found [here](codebook.md)

## The Analysis, step by step

### Step 1: "Merge the training and the test sets to create one data set."
For this we need to join together 6 separate files. Within the ```test``` folder, ```X_test.txt``` represents the variables, ```y_test.txt``` represents the activities being performed, and ```subject_test.txt``` represents which subject the observation refers to. A similar pattern is found in the ```train``` folder. So the steps are to combine test data, combine training data, and lastly combine these together to form a master set of raw data.

#### 1a. Combine Test Data
* Read in the features from the test data set:
 ``` raw_test_x <- read.table(paste(data_folder, "test", "X_test.txt", sep="/")) ```
* Read in the activity classification from the test data set; label the column:
 ``` raw_test_y <- read.table(paste(data_folder, "test", "y_test.txt", sep="/"), col.names=c('activity')) ```
* Read in the subject identification from the test data; label the column:
 ``` raw_test_subject <- read.table(paste(data_folder, "test", "subject_test.txt", sep="/"), col.names=c('subject')) ```
* Combine these frames together:
 ``` combined_test <- cbind(raw_test_x, raw_test_y, raw_test_subject) ``` 
 
#### 1b. Read in the training data
This follows exactly the same pattern as above, except the folder is named ```train``` and the files are named ```X_train.txt```, ```y_train.txt```, and ```subject_train.txt``` respectively. The resulting combined set is named ```combined_train```

#### 1c. Combine test and training data
This is done by simply ```rbind```-ing the two datasets together:
```
combined_raw <- rbind(combined_test, combined_train)
```

#### Step 1 result
After step 1, there is a data frame: ```combined_raw``` containing all the data in the test and training set:
| Features (1:561) | Activity(562) | Subject |
| ---------------- | ------------- | ------- |
| test data        |               |         |
| training data | |

### Step 2: "Extract only the measurements on the mean and standard deviation for each measurement."
For this, we need to know which columns refer to measurements that are means or standard deviations of a measurement. From the codebook ```features_info.txt``` that comes with the data, we can see that the measurements are denoted by {signal}{variable}{axis}, for example: ```tBodyAcc-mean()-X``` for the mean of the Body Acceleration in the X direction. So, in order to get at the data we want, we will need all columns that refer to a variable containing ```mean()``` and ```std()``` 

Additionally, there are:

> Additional vectors obtained by averaging the signals in a signal window sample
 
I have taken these to also represent 'Mean' values, so have included them in the dataset. These variables all end in ```Mean```

In order to filter the data, we read in the file that gives us the name of each feature: ```features.txt``` and use it to filter the dataset.

#### 2a. Read in the list of features to a vector
```
feature_names <- read.table(paste(data_folder, "features.txt", sep='/'), col.names=c('index', 'feature'))

  #the actual names are in the 'feature' column, so lets grab that
  feature_names <- as.character(feature_names$feature)

```

#### 2b. Get the inidices of features we want
Reminder, these are all features that include ```mean()```, ```std()```, or ```Mean```
```
indices <- grep('mean()|std()|Mean', feature_names)
```

#### 2c. Add Indices for the subject and activity
As a reminder, our combined data set looks something like this:

| Features (1:561) | Activity(562) | Subject |
| ---------------- | ------------- | ------- |
| test data        |               |         |
| training data | |