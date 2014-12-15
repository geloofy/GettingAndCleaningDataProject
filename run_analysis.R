#read source files
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest  <- fread(file.path(pathIn, "test" , "subject_test.txt" ))
dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest  <- fread(file.path(pathIn, "test" , "Y_test.txt" ))
dtTrain <- data.table(read.table(file.path(pathIn, "train", "X_train.txt")))
dtTest <- data.table(read.table(file.path(pathIn, "test", "X_test.txt")))

#merge data sets
dtTrain <- data.table(read.table(file.path(pathIn, "train", "X_train.txt")))
dtTest <- data.table(read.table(file.path(pathIn, "test", "X_test.txt")))
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)
setkey(dt, subject, activityNum)

#extract mean and standard deviation
dtFeatures <- fread(file.path(pathIn, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with=F]

#use descriptive activity names
dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))

#label data with descriptive variable names
dt <- merge(dt, dtActivityNames, by="activityNum", all.x=T)
setkey(dt, subject, activityNum, activityName)
dt <- data.table(melt(dt, key(dt), variable.name="featureCode"))
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by="featureCode", all.x=T)
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)

#separate features from featureName
greplRegex <- function (regex) {
    grepl(regex, dt$feature)
}

n <- 2
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(greplRegex("^t"), greplRegex("^f")), ncol=nrow(y))
dt$featDomain <- factor(x %*% y, labels=c("Time", "Freq"))
x <- matrix(c(greplRegex("Acc"), greplRegex("Gyro")), ncol=nrow(y))
dt$featInstrument <- factor(x %*% y, labels=c("Accelerometer", "Gyroscope"))
x <- matrix(c(greplRegex("BodyAcc"), greplRegex("GravityAcc")), ncol=nrow(y))
dt$featAcceleration <- factor(x %*% y, labels=c(NA, "Body", "Gravity"))
x <- matrix(c(greplRegex("mean()"), greplRegex("std()")), ncol=nrow(y))
dt$featVariable <- factor(x %*% y, labels=c("Mean", "SD"))

dt$featJerk <- factor(greplRegex("Jerk"), labels=c(NA, "Jerk"))
dt$featMagnitude <- factor(greplRegex("Mag"), labels=c(NA, "Magnitude"))

n <- 3
y <- matrix(seq(1, n), nrow=n)
x <- matrix(c(greplRegex("-X"), greplRegex("-Y"), greplRegex("-Z")), ncol=nrow(y))
dt$featAxis <- factor(x %*% y, labels=c(NA, "X", "Y", "Z"))

#create tidy data set
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by=key(dt)]
write.table(dtTidy, file="Tidy.txt", row.name=F)

#create codebook
knit("codebook.Rmd", output="codebook.md", encoding="ISO8859-1", quiet=TRUE)
