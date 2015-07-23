# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.

data_dir      <- file.path("UCI HAR Dataset")
test_set.fp   <- file.path(data_dir, "test", "X_test.txt")
train_set.fp  <- file.path(data_dir, "train", "X_train.txt")
features.fp   <- file.path(data_dir, "features.txt")
activities.fp <- file.path(data_dir, "activity_labels.txt")
test_activity.fp <- file.path(data_dir, "test", "y_test.txt")
train_activities.fp <- file.path(data_dir, "train", "y_train.txt")
test_sbj.fp  <- file.path(data_dir, "test", "subject_test.txt")
train_sbj.fp <- file.path(data_dir, "train", "subject_train.txt")

library(dplyr)

## test
test_set <- read.table(test_set.fp, header = F, colClasses = "numeric")
## train
train_set <- read.table(train_set.fp, header = F, colClasses = "numeric")

## 1. merge sets and 2. extract mean and std
features <- read.table(features.fp, stringsAsFactors = F, col.names = c("feature_id", "feature_description"))

ms.features <- features[which(grepl(pattern = "mean\\(|std\\(", x = features$feature_description)),]

full_set <- rbind(test_set, train_set)[, ms.features$feature_id]

## 4. label the data set with descriptive variable names
colnames(full_set) <- ms.features$feature_description

# 3. Use descriptive activity names
activities <- read.table(activities.fp, col.names = c("activity_id", "activity_description"))

test_activity <- read.table(test_activity.fp, header = F, colClasses = "numeric", col.names = c("activity_id"))
test_activities <- merge(test_activity, activities, by = "activity_id", all.x = T, all.y = F)
r.test_activities <- as.character(test_activities$activity_description)

train_activity <- read.table(train_activities.fp, header = F, colClasses = "numeric", col.names = c("activity_id"))
train_activities <- merge(train_activity, activities, by = "activity_id", all.x = T, all.y = F)
r.train_activities <- as.character(train_activities$activity_description)

test_sbj <- scan(test_sbj.fp, what = "c")
train_sbj <- scan(train_sbj.fp, what = "c")

full_set <- mutate(full_set, activity = c(r.test_activities, r.train_activities),
                   subjects = c(test_sbj, train_sbj))

## 5. make tidy data and write it
tidy_ds <- group_by(full_set, activity, subjects) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))
# tidy_ds.act <- group_by(full_set[, colnames(full_set)!="subjects"], 
#                         activity) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))
# tidy_ds.sbj <- group_by(full_set[, colnames(full_set)!="activity"], 
#                         subjects) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))

write.table(tidy_ds, "tidyDS.txt", row.names = F)
