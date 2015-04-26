run_analysis <- function(data_folder='UCI HAR Dataset'){
  library("dplyr")
  library("reshape2")
  # This script assumes you have the raw data downloaded and unzipped.
  # You can then run this function, passing in the name of the folder containing the data.
  
  ## STEP 1: Merge the test and training data into one data set
  
  ## 1a. Read in the test data
  
  # read in the features from the test data set
  raw_test_x <- read.table(paste(data_folder, "test", "X_test.txt", sep="/"))
  
  #read in the activity classification from the test data set
  raw_test_y <- read.table(paste(data_folder, "test", "y_test.txt", sep="/"), col.names=c('activity'))
  
  # read in the subject identification from the test data set
  raw_test_subject <- read.table(paste(data_folder, "test", "subject_test.txt", sep="/"), col.names=c('subject'))
  
  #combine these together
  combined_test <- cbind(raw_test_x, raw_test_y, raw_test_subject)
  
  ## 1b. Read in the training data
  
  #read in the raw training features
  raw_train_x <- read.table(paste(data_folder, "train", "X_train.txt", sep="/"))
  
  #read in the activity classification from the training data set
  raw_train_y <- read.table(paste(data_folder, "train", "y_train.txt", sep="/"), col.names=c('activity'))
  
  # read in the subject identification from the test data set
  raw_train_subject <- read.table(paste(data_folder, "train", "subject_train.txt", sep="/"), col.names=c('subject'))
  
  #combine these together
  combined_train <- cbind(raw_train_x, raw_train_y, raw_train_subject)
  
  #1c. combine the two datasets together
  combined_raw <- rbind(combined_test, combined_train)
  
  
  # STEP 2: Extract only the measurements on the mean and standard deviation for each measurement.
  #
  
  # 2a. read in the feature names data
  feature_names <- read.table(paste(data_folder, "features.txt", sep='/'), col.names=c('index', 'feature'))
  #the actual names are in the 'feature' column, so lets grab that
  feature_names <- as.character(feature_names$feature)
  
  # 2b. get indices of names with mean | std dev
  # from the supporting doc 'features_info.txt'
  # The main measurements' means and std deviations are denoted by mean() and std()
  # There are additional vectors at the end which also involve averaging signals in a signal window sample
  # this could be said to be a mean, so I've included them
  indices <- grep('mean()|std()|Mean', feature_names)
  
  # 2c. add indices for subject & activity (last two columns from step 1)
  # the feature table has 561 measures, so 562 and 563 are the added activity and subject data
  indices <- c(indices, 562,563)
  
  # 2d. filter combined_raw into a new dataset using those values
  filtered_raw <- combined_raw[indices] 
  
  
  
  # STEP 3: User Descriptive Activity Names in the set
  
  #3a. load in the activity labels
  activity_labels <- read.table(paste(data_folder, "activity_labels.txt", sep='/'))
  
  #3b. These labels have the same row order as the factor variables, soo that:
  # activity_labels$V2[1] = WALKING which is the label for activity 1 and so on
  activity_labelled <- mutate(filtered_raw, activity=activity_labels$V2[activity])
  
  # STEP 4: Appropriately label the data set with descriptive variable names
  
  # 4a. Add the variable names for activity and subject to the feature names
  feature_names <- c(feature_names, 'activity', 'subject')
  
  # 4b. Use the indices vector from step 2 to get our filtered feature names
  filtered_feature_names <- feature_names[indices]
  
  # 4c. rename our column names
  names(activity_labelled) <- filtered_feature_names
  
  # 5. Create a second, independent, tidy data set with the average of each variable for each activity and each subject
  
  # 5a. melt the data set, specifying ID variables as activity & subject. All other columns are taken to be measurements
  melted <- melt(activity_labelled, id.vars=c('activity', 'subject'))
  
  # 5b. reshape the set, specifying you want to use the mean of variables when subject + activity the same
  # i.e. if there are 10 values for tBodyAcc-mean()-X for subject 1 standing, the value returned will be the mean of those measurements
  activity_data <- dcast(melted, subject + activity ~ variable, mean)
  
  #5c. Write out the data set as a text file
  outfile <- 'analyzed_activity_data.txt'
  write.table(activity_data, file=outfile, row.names=FALSE)
  
  #5d. Tell ppl where to find the data
  message(paste("Cleaned and analyzed data written out to", outfile))
  
  #5e. Show the data on screen so we can take a look at it
  View(activity_data)
}