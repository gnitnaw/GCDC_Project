GCDC_Project
============
Getting and Cleaning Data Course Project

In this README file, I will explain to you :
- How to use the code "run_analysis.R"
- How this code "run_analysis.R" works.
============
How to use the code "run_analysis.R"
===
1. Please download the data for the project into your work directory:
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
2. Extract (unzip) this data in the same work directory, and you will find that a new directory "UCI HAR Dataset" is created.
3. Copy my code "run_analysis.R" in your work directory
4. Launch your R (or R Studio) and use getwd() command to check if your work directory is the same as the one you put the code "run_analysis.R" and the data "UCI HAR Dataset". If not, use setwd("your_work_directory") to change.
5. In R, execute:
   source("run_analysis.R")
6. The you will find three more files "tidyData_Activity.txt", "tidyData_Subject.txt", and "tidyData_All.txt" are generated in the same directory. These files are:
- tidyData_Subject.txt: average of each variable for each subject (the columns Suject_1 - Subject_30 indicate different subjects)
- tidyData_Activity.txt: average of each variable for each activity (the columns WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING)
- tidyData_All.txt : the combination of tidyData_Subject.txt and tidyData_Activity.txt

7. You will also find there are several variables in the environments. In these variables, tidy1, tidy2, and tidyAll represent the data in tidyData_Activity.txt, tidyData_Subject.txt, and tidyData_All.txt.

============
How this code "run_analysis.R" works
===
1) Read necessary files
- The data are separated into "test" part (X_test.txt) and "train" part (X_train.txt), and each column indicates different features (features.txt); for each part was taken by 30 subjects who were performing six kinds of activities (activity_labels.txt); the information of activities (y_test.txt,y_train.txt) and subjects (subject_test.txt, subject_train.txt) also have to be included in order to get the results corresponding to different activities/subjects.

X_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
Y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
Y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
Z_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")
Z_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
Y_labels<-read.table("./UCI HAR Dataset/activity_labels.txt")
NColumn<-read.table("./UCI HAR Dataset/features.txt")

2) Merges the training and the test sets to create one data set (we will combine then later)

X<-rbind(X_test,X_train) -- All measurements
Y<-rbind(Y_test,Y_train) -- Activity information
Z<-rbind(Z_test,Z_train) -- Subject information


3) Appropriately labels the data set with descriptive variable names.
We have to convert NColumn (data.frame) into another vector(NewColNames) in order to change the column names of X.

NewColNames<-as.character(NColumn$V2)
names(X)<-NewColNames

4) Extracts only the measurements on the mean and standard deviation for each measurement. 
According to features_info.txt, the keywords "mean()" and "std()" are what we need.
So we have to search the elements in NewColNames which contains these two keywords and put the results in the vector (selectColumn), and make a subset of X according to selectColumn.
Remark: we have to set value="T", fixed="T" in order to avoid the variables we don't need (ex:gravityMean, meanFreq())

selectColumn<-grep("mean()",NewColNames, value="T", fixed="T")
selectColumn<-c(selectColumn, grep("std()",NewColNames, value="T", fixed="T"))
X2<-subset(X, select = selectColumn)

5) Remove unnecessary variable. You can remove this line if you still need these variables.

rm(X_test,Y_test,Z_test,X_train,Y_train,Z_train)

6) Uses descriptive activity names to name the activities in the data set
Here we convert the label of activities (1,2,3,4,5,or 6) from Y into the name of activity (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) and combine with X.
Notice that you have to convert the data.frame format into vector (it's easier).
Then we can combine Z with X. 
Now XYZ contains all information (All measurements, Activity, Subject).

Y_labels<-as.character(Y_labels$V2)
Activity<-Y_labels[as.numeric(Y$V1)]
Subject<-as.numeric(Z$V1)
XYZ<-cbind(X2,Activity,Subject)

7) From the data set in step 6, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
In order to make the data set more clear, I put the average of each variable for each activity in tidy1, the average of each variable for each subject in tidy2.
tidyAll is the combination of tidy1 and tidy2.
Each column is the result from different activity/subject.
The average values of each variable(tBodyAcc-mean()-X,..etc.) are listed in each rows (each row represents one variable).
I use a for loop to get the average of each variable in different activity/subject and then combine the results together.
For tidy2, I also rename the column to Subject_1~Subject_30 to indicate the subjects.

tidy1=data.frame(row.names=names(XYZ)[1:(length(names(XYZ))-2)])
for (i in Y_labels) {
    XYZ2<-subset(XYZ,Activity==i,select=-c(Activity,Subject))
    tidy1<-cbind(tidy1,sapply(XYZ2,mean))
}
names(tidy1)<-Y_labels

tidy2=data.frame(row.names=names(XYZ)[1:(length(names(XYZ))-2)])
nLabel=c()
for (i in c(1:30)) {
    XYZ2<-subset(XYZ,Subject==i,select=-c(Activity,Subject))
    tidy2<-cbind(tidy2,sapply(XYZ2,mean))
    nLabel<-c(nLabel, paste("Subject_",as.character(i),sep=""))
}
names(tidy2)<-nLabel


tidyAll<-cbind(tidy1,tidy2)

8) Output them to text file without the row names
write.table(tidy1,file="tidyData_Activity.txt", row.name=FALSE)
write.table(tidy2,file="tidyData_Subject.txt", row.name=FALSE)
write.table(tidyAll,file="tidyData_All.txt", row.name=FALSE)
