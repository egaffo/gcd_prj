---
title: "Getting and Cleaning Data course project Codebook"
author: "enrAico"
date: "24 July 2015"
output:
html_document:
keep_md: yes
---

## Project Description
Getting and Cleaning Data course project

##Collection of the raw data
Raw data is downloaded from [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

##Creating the tidy datafile

###0a. Raw data download

If not already present, download raw data in the current directory. Save as `data.zip` and unzip the package. Do not overwrite existing files.
```r
data.url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data.fn <- "data.zip"
if(!file.exists(data.fn)){
download.file(data.url, data.fn, method = "curl")
}
unzip(data.fn, overwrite = F)
```
###0b. Initialize file names variables

Store input file name paths in variables to save some code space. 

Use `file.path()` to build path to make the paths platform independent
```r
data_dir      <- file.path("UCI HAR Dataset")
test_set.fp   <- file.path(data_dir, "test", "X_test.txt")
train_set.fp  <- file.path(data_dir, "train", "X_train.txt")
features.fp   <- file.path(data_dir, "features.txt")
activities.fp <- file.path(data_dir, "activity_labels.txt")
test_activity.fp <- file.path(data_dir, "test", "y_test.txt")
train_activities.fp <- file.path(data_dir, "train", "y_train.txt")
test_sbj.fp  <- file.path(data_dir, "test", "subject_test.txt")
train_sbj.fp <- file.path(data_dir, "train", "subject_train.txt")
```
###1. Merges the training and the test sets to create one data set.

Load the `plyr` package to use the `ldply()` function. Used with the `read.table()` function, it loads the test and training set files specified in the input list and combine them into a single data frame `full_set`
```r    
library(plyr)
full_set <- ldply(c(test_set.fp, train_set.fp), function(x)read.table(x, header = F, colClasses = "numeric"))
```
###2. Extracts only the measurements on the mean and standard deviation for each measurement.

Read the feature description file as a data frame and pipe it to the `filter` function of the `dplyr` package. 
The filtering is performed according to regular expression, matching either `mean(` or `std(` string in the feature descriptor by means of logical grep `grepl()`. Mean and standard deviation table is stored in the `ms.features` table. `ms.features` table columns are given `feature_id` and `feature_description` names. Note that the parenthesis in the pattern is put on purpose to prevent the matching of `meanFreq` entries. The `full_set` is subsetted by index column selection, according to the `feature_id` numeric variable in the `ms.features` table that specified the column number relative to each feature descriptor. 
```r
library(dplyr)
ms.features <- read.table(features.fp, stringsAsFactors = F, 
col.names = c("feature_id", "feature_description")) %>% 
filter(grepl(pattern = "mean\\(|std\\(", feature_description))
full_set.s <- full_set[, ms.features$feature_id]
```
###3. Uses descriptive activity names to name the activities in the data set.

Read the activity ID/description table into `activities` variable and give it header names `activity_id` and `activity_description`. Read and concatenate test and trainig measurment (row) activity labels into `r.activities` variable by means of `ldply()`. Even if we are reading single column table, this approach resulted simplier than using `scan()`. Note: in the script code, test and trainig variables are always concatenated in the same order to preserve correspondence of data rows with other data frames suche as `full_set` and `full_set.s`.
Descriptive analysis names (`dan` vector variable) are matched through row indexing of the `activities` table.

```r
activities <- read.table(activities.fp, col.names = c("activity_id", "activity_description"))
r.activities <- ldply(c(test_activity.fp, train_activities.fp), function(x)read.table(x))
dan <- activities[r.activities[,1], "activity_description"]
```

###4. Appropriately labels the data set with descriptive variable names. 

Just assign `feature_description` table variable to the `full_set.s` column names. Also, add the `activity` column prepared before (`dan` in step 3.) to the data frame by means of `mutate()`.
```r
colnames(full_set.s) <- ms.features$feature_description
full_set.s <- mutate(full_set.s, activity = dan)
```
###5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Retrieve subject labels in the same way as for the activities, save them into the `r.subjects` table and plug it to the `full_set.s` using `mutate()`. Save the mutated data frame as `itd` to preserve `full_set.s`, even though modifing the `full_set.s` would have not hurt. Use `dplyr` functions to compute averages per (subject, activity): group `itd` by `subjects` and `activity` columns and piping it to `summarise_each()` specifing `mean` as function in `funs()`. Store the results in a new variable `tidy_ds` and write the table to the `tidyDS.txt` file.
```r
r.subjects <- ldply(c(test_sbj.fp, train_sbj.fp), function(x)read.table(x))
itd <- mutate(full_set.s, subjects = r.subjects[,1])
tidy_ds <- group_by(itd, subjects, activity) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))
write.table(tidy_ds, "tidyDS.txt", row.names = F)
```
