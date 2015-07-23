# download data if not present in the current directory
data.url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
data.fn <- "data.zip"
if(!file.exists(data.fn)){
  download.file(data.url, data.fn, method = "curl")
}
unzip(data.fn, overwrite = F)

# input file paths
data_dir      <- file.path("UCI HAR Dataset")
test_set.fp   <- file.path(data_dir, "test", "X_test.txt")
train_set.fp  <- file.path(data_dir, "train", "X_train.txt")
features.fp   <- file.path(data_dir, "features.txt")
activities.fp <- file.path(data_dir, "activity_labels.txt")
test_activity.fp <- file.path(data_dir, "test", "y_test.txt")
train_activities.fp <- file.path(data_dir, "train", "y_train.txt")
test_sbj.fp  <- file.path(data_dir, "test", "subject_test.txt")
train_sbj.fp <- file.path(data_dir, "train", "subject_train.txt")

# 1. Merges the training and the test sets to create one data set.
library(plyr)
full_set <- ldply(c(test_set.fp, train_set.fp), function(x)read.table(x, header = F, colClasses = "numeric"))

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
library(dplyr)
ms.features <- read.table(features.fp, stringsAsFactors = F, 
                                 col.names = c("feature_id", "feature_description")) %>% 
  filter(grepl(pattern = "mean\\(|std\\(", feature_description))
full_set.s <- full_set[, ms.features$feature_id]

# 3. Uses descriptive activity names to name the activities in the data set
activities <- read.table(activities.fp, col.names = c("activity_id", "activity_description"))
r.activities <- ldply(c(test_activity.fp, train_activities.fp), function(x)read.table(x))
dan <- activities[r.activities[,1], "activity_description"]

# 4. Appropriately labels the data set with descriptive variable names. 
colnames(full_set.s) <- ms.features$feature_description
full_set.s <- mutate(full_set.s, activity = dan)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.
r.subjects <- ldply(c(test_sbj.fp, train_sbj.fp), function(x)read.table(x))
itd <- mutate(full_set.s, subjects = r.subjects[,1])

tidy_ds <- group_by(itd, subjects, activity) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))
write.table(tidy_ds, "tidyDS.txt", row.names = F)
