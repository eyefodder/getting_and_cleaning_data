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

| Features (1:561) | Activity(562) | Subject(563) |
| ---------------- | ------------- | ------------ |
| test data        |               |              |
| training data    |               |              |


### Step 2: "Extract only the measurements on the mean and standard deviation for each measurement."
For this, we need to know which columns refer to measurements that are means or standard deviations of a measurement. From the codebook ```features_info.txt``` that comes with the data, we can see that the measurements are denoted by {signal}{variable}{axis}, for example: ```tBodyAcc-mean()-X``` for the mean of the Body Acceleration in the X direction. So, in order to get at the data we want, we will need all columns that refer to a variable containing ```mean()``` and ```std()``` 

In order to filter the data, we read in the file that gives us the name of each feature: ```features.txt``` and use it to filter the dataset.

#### 2a. Read in the list of features to a vector
```
feature_names <- read.table(paste(data_folder, "features.txt", sep='/'), col.names=c('index', 'feature'))

  #the actual names are in the 'feature' column, so lets grab that
  feature_names <- as.character(feature_names$feature)

```

#### 2b. Get the inidices of features we want
Reminder, these are all features that include ```mean()```, or ```std()```
```
indices <- grep('mean\\(\\)|std\\(\\)', feature_names)
```

#### 2c. Add Indices for the subject and activity
As a reminder, our combined data set looks something like this:

| Features (1:561) | Activity(562) | Subject(563) |
| ---------------- | ------------- | ------------ |
| test data        |               |              |
| training data    |               |              |

So we want both the filtered feature indices we grabbed in step 2b, and the indices for ```activity``` and ```subject```:
```
indices <- c(indices, 562,563)
```

#### 2d. Use the indices we want to filter the original data set
We create a data frame ```filtered_raw``` containing just the columns we care about:
```
filtered_raw <- combined_raw[indices] 
```
#### Step 2 result
At the end of step 2, we have a dataframe—```filtered_raw``` containing 10299 observations of the measurements we care about, plus the identifiers of ```subject``` and ```activity```.

### Step 3: "Use descriptive activity names to name the activities in the data set"
Currently, our activity column is a set of numbers, each one representing an activity. The file ```activity_labels.txt``` is a guide to what these activities are. In this step, we will replace the number with the label, so that e.g. ```1``` becomes ```WALKING```, ```2``` becomes ```WALKING_UPSTAIRS``` and so on.

#### 3a. Load in the activity label data
The data are loaded into a variable named ```activity_labels```
```
activity_labels <- read.table(paste(data_folder, "activity_labels.txt", sep='/'))
```

#### 3b. Replace numeric categories for descriptive labels
If we look at the ```activity_labels``` table, we see this:

| V1 | V2                 |
| -- | ------------------ |
| 1  | WALKING            |
| 2  | WALKING_UPSTAIRS   |
| 3  | WALKING_DOWNSTAIRS |
| 4  | SITTING            |
| 5  | STANDING           |
| 6  | LAYING             |

So what we want to do is set activity(currently a number 1-6) to equal the value in that row of ```activity_labels$V2```. For this we use the ```mutate``` function from the ```dplyr``` package:
```
activity_labelled <- mutate(filtered_raw, activity=activity_labels$V2[activity])
```
#### Step 3 result
At the end of step 3, we have a dataframe ```activity_labelled``` containing the measurements we care about, with the activity they describe labelled descriptively according to the labels provided in ```activity_labels.txt```.

### Step 4: "Appropriately label the data set with descriptive variable names"
This step is all about setting the variable names of the columns of data. We have a set of descriptive variable names provided to us in ```features.txt``` that we have already used in step 2 to just select the columns we want from the raw data set. We can use this same list of feature names, along with the ```indices``` of the desired variables to give names to the columns in our filtered data. Although these variable names are concise, they are still *descriptive* in that they tell us what each variable means. The verbose meaning of each variable is described in the [code book](codebook.md)

#### 4a. Add variable names for activity and subject
Remember our combined raw data had columns 1-561 of feature data, then activity and subject glommed on the end of it? Let's do the same with the feature names vector:
```
feature_names <- c(feature_names, 'activity', 'subject')
```
#### 4b. Use the indices vector from step 2c to get our filtered set of names:
```
filtered_feature_names <- feature_names[indices]
```

#### 4c. Rename the columns
```filtered_feature_names``` represents the names of all 88 of our columns, so we use the ````names()``` function to label our data:

```names(activity_labelled) <- filtered_feature_names```

#### Step 4 result
At the end of step 4, ```activity_labelled``` now has descriptive names for each of the columns in the data set

### Step 5: "Create a second, independent tidy data set with the average of each variable for each activity and each subject"
So for this step, we want to take our filtered data, and summarize it by finding the mean of values for each measurement by subject and activity, something like this:

| Subject | Activity  | var1                                                              | var2               | ... | varx       |
| ------- | --------- | ----------------------------------------------------------------- | ------------------ | --- | ---------- |
| 1       | LAYING    | average of all values of var1 for subject 1 when they are LAYING  | likewise for var 2 | ... | up to varx |
| 1       | SITTING   | average of all values of var1 for subject 1 when they are SITTING | likewise for var 2 | ... | up to varx |
| X       | Y      | average of all values of var1 for subject X when they are Y          | likewise for var 2 | ... | up to varx |

This is accomplished via a two step reshaping, first melting the data into a very long table, then re-casting it and summarizing by ```mean```

#### 5a Melt the dataset into a (very) long table
We specify the id columns as ```subject``` and ```activity```. All other columns will be considered measurements:
```
melted <- melt(activity_labelled, id.vars=c('activity', 'subject'))
```

#### 5b. Reshape the dataset
Now we reshape the dataset, specifying that we want to use the ```mean``` to summarize data:

```
activity_data <- dcast(melted, subject + activity ~ variable, mean)
```

#### 5c. Write the data out to a file
This file is used to upload the result to the coursera submission page:
``` 
outfile <- 'analyzed_activity_data.txt'
write.table(activity_data, file=outfile, row.names=FALSE)
```

#### 5d. Tell the user where to find the data
It's always nice to know where to find your hard work!
```
message(paste("Cleaned and analyzed data written out to", outfile))
```

#### 5e. Show the data on screen
And it's also kind of nice to see the result of that hard work too:
```
View(activity_data)
```
#### Step 5 result
The result of this, final, step is what was requested in the brief: 
> A second, independent tidy data set with the average of each variable for each activity and each subject.

The data is written out to ```analyzed_activity_data.txt``` and is also displayed on screen for the user.

