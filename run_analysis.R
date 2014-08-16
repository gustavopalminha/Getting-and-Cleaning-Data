# Pre script requirements:
# When using this R code please adjust the working setwd() directory accordingly;
# Before running this code you should have donwloaded and unziped the data
# provided which should be left inside UCI HAR Dataset folder;  

#set local working directory
setwd("d:/temp/gcd")

#libraries used...
library(plyr)

#0) Read all test and training data to objects...
testData <- read.table("./UCI HAR Dataset/test/X_test.txt",header=FALSE)
testDataAct <- read.table("./UCI HAR Dataset/test/y_test.txt",header=FALSE)
testDataSub <- read.table("./UCI HAR Dataset/test/subject_test.txt",header=FALSE)
trainData <- read.table("./UCI HAR Dataset/train/X_train.txt",header=FALSE)
trainDataAct <- read.table("./UCI HAR Dataset/train/y_train.txt",header=FALSE)
trainDataSub <- read.table("./UCI HAR Dataset/train/subject_train.txt",header=FALSE)

#3) Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table("./UCI HAR Dataset/activity_labels.txt",header=FALSE,colClasses="character")
trainDataAct$V1 <- gsub("_", " ", tolower(factor(trainDataAct$V1,levels=activityLabels$V1,labels=activityLabels$V2)))
testDataAct$V1 <- gsub("_", " ", tolower(factor(testDataAct$V1,levels=activityLabels$V1,labels=activityLabels$V2)))

#4) Appropriately labels the data set with descriptive variable names. 
dataFeatures <- read.table("./UCI HAR Dataset/features.txt",header=FALSE,colClasses="character")
colnames(testData) <- dataFeatures$V2
colnames(trainData) <- dataFeatures$V2
colnames(testDataAct) <- c("Activity")
colnames(trainDataAct) <- c("Activity")
colnames(testDataSub) <- c("Subject")
colnames(trainDataSub) <- c("Subject")

#1) Merges the training and the test sets to create one data set.
testData <- cbind(testDataAct,testData)
testData <- cbind(testDataSub,testData)
trainData <- cbind(trainDataAct,trainData)
trainData <- cbind(trainDataSub,trainData)
mergeData <- rbind(testData,trainData)

#2) Extracts only the measurements on the mean and standard deviation for each measurement. 
importantCI <- grep("(mean|std)\\(\\)", names(mergeData))
importantCI <- c(1:2, importantCI)
mergeData <- mergeData[,importantCI]

#tidyng measure names to a more descriptive meaning
mergeDataCollumns <- names(mergeData)
mergeDataCollumns <- gsub("(Body)\\1", "\\1", mergeDataCollumns)
mergeDataCollumns <- gsub("-", "", mergeDataCollumns)
mergeDataCollumns <- gsub("^f", "Frequency", mergeDataCollumns)
mergeDataCollumns <- gsub("Acc", "Accelerometer", mergeDataCollumns)
mergeDataCollumns <- gsub("^t", "Time", mergeDataCollumns)
mergeDataCollumns <- gsub("mean", "Mean", mergeDataCollumns)
mergeDataCollumns <- gsub("std", "StandardDeviation", mergeDataCollumns)
mergeDataCollumns <- gsub("([X-Z]$)", "\\1Direction", mergeDataCollumns)
mergeDataCollumns <- gsub("Gyro", "Gyroscope", mergeDataCollumns)
mergeDataCollumns <- gsub("Mag", "Magnitude", mergeDataCollumns)
mergeDataCollumns <- gsub("\\(\\)", "", mergeDataCollumns)

#assigning column names....
names(mergeData) <- mergeDataCollumns

#5) Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
mergeDataMean <- ddply(mergeData, .(Activity, Subject), colwise(mean))
write.table(mergeDataMean, "tidy_data.txt", row.names=F)