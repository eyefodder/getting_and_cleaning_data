downloadData <- function(){
  uri <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  archive_name <- 'dataset.zip'
  if (file.exists(archive_name)){
    message("archive exists, no need to download")
  }else{
    download.file(uri, destfile=archive_name, method='curl')
  }
  data_folder <- 'UCI HAR Dataset'
  if (file.exists(data_folder)){
    message("archive already extracted")
  }else{
    unzip(archive_name)
  }
  data_folder
}