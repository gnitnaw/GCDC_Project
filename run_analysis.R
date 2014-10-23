# Read necessary files
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
Y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
Y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
Z_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")
Z_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
Y_labels<-read.table("./UCI HAR Dataset/activity_labels.txt")
NColumn<-read.table("./UCI HAR Dataset/features.txt")

# 1. Merges the training and the test sets to create one data set.
X<-rbind(X_test,X_train)
Y<-rbind(Y_test,Y_train)
Z<-rbind(Z_test,Z_train)

# 4. Appropriately labels the data set with descriptive variable names. 
NewColNames<-as.character(NColumn$V2)
names(X)<-NewColNames

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
selectColumn<-grep("mean()",NewColNames, value="T", fixed="T")
selectColumn<-c(selectColumn, grep("std()",NewColNames, value="T", fixed="T"))
X2<-subset(X, select = selectColumn)

# Remove unnecessary variable
rm(X_test,Y_test,Z_test,X_train,Y_train,Z_train)

# 3. Uses descriptive activity names to name the activities in the data set
Y_labels<-as.character(Y_labels$V2)
Activity<-Y_labels[as.numeric(Y$V1)]
Subject<-as.numeric(Z$V1)
XYZ<-cbind(X2,Activity,Subject)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# tidy1 is the tidy data set with the average of each variable for each activity
tidy1=data.frame(row.names=names(XYZ)[1:(length(names(XYZ))-2)])
for (i in Y_labels) {
    XYZ2<-subset(XYZ,Activity==i,select=-c(Activity,Subject))
    tidy1<-cbind(tidy1,sapply(XYZ2,mean))
}
names(tidy1)<-Y_labels

# tidy2 is the tidy data set with the average of each variable for each subject
tidy2=data.frame(row.names=names(XYZ)[1:(length(names(XYZ))-2)])
nLabel=c()
for (i in c(1:30)) {
    XYZ2<-subset(XYZ,Subject==i,select=-c(Activity,Subject))
    tidy2<-cbind(tidy2,sapply(XYZ2,mean))
    nLabel<-c(nLabel, paste("Subject_",as.character(i),sep=""))
}
names(tidy2)<-nLabel

# tidyAll is the combination of tidy1 and tidy2
tidyAll<-cbind(tidy1,tidy2)

write.table(tidy1,file="tidyData_Activity.txt", row.name=FALSE)
write.table(tidy2,file="tidyData_Subject.txt", row.name=FALSE)
write.table(tidyAll,file="tidyData_All.txt", row.name=FALSE)
