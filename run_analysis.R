# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
#    of each variable for each activity and each subject.

library(dplyr)

## test
test_set <- read.table("UCI HAR Dataset/test/X_test.txt", header = F, colClasses = "numeric")

## train
train_set <- read.table("UCI HAR Dataset/train/X_train.txt", header = F, colClasses = "numeric")

## 1. merge sets and 2. extract mean and std
features <- read.table("UCI HAR Dataset/features.txt", stringsAsFactors = F,
                       col.names = c("feature_id", "feature_description"))
ms.features <- features[which(grepl(pattern = "mean|std", x = features$feature_description)),]
full_set <- rbind(test_set, train_set)[, ms.features$feature_id]
## 4. label the data set with descriptive variable names
colnames(full_set) <- ms.features$feature_description
# 3. Use descriptive activity names
activities <- read.table("UCI HAR Dataset/activity_labels.txt", 
                         col.names = c("activity_id", "activity_description"))
test_activity <- read.table("UCI HAR Dataset/test/y_test.txt", header = F, 
                            colClasses = "numeric", col.names = c("activity_id"))
test_activities <- merge(test_activity, activities, by = "activity_id", all.x = T, all.y = F)
r.test_activities <- as.character(test_activities$activity_description)
train_activity <- read.table("UCI HAR Dataset/train/y_train.txt", header = F, 
                             colClasses = "numeric", col.names = c("activity_id"))
train_activities <- merge(train_activity, activities, by = "activity_id", all.x = T, all.y = F)
r.train_activities <- as.character(train_activities$activity_description)

test_sbj <- scan("UCI HAR Dataset/test/subject_test.txt", what = "c")
train_sbj <- scan("UCI HAR Dataset/train/subject_train.txt", what = "c")
full_set <- mutate(full_set, activity = c(r.test_activities, r.train_activities),
                   subjects = c(test_sbj, train_sbj))

## make tidy data
tidy_ds <- group_by(full_set, activity, subjects) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))
tidy_ds.act <- group_by(full_set[, colnames(full_set)!="subjects"], 
                        activity) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))
tidy_ds.sbj <- group_by(full_set[, colnames(full_set)!="activity"], 
                        subjects) %>% summarise_each(funs(mean, "mean", mean(., na.rm = TRUE)))

#write.table(tidy_ds, "tidyDS.txt", row.names = F)
