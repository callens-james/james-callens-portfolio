# Nosepoke_FR_Script.R
# Purpose: Analysis/processing script for behavioral workflow data.
# Note: Public portfolio version; paths and sensitive identifiers should be parameterized. wd <- "C:/Users/PC/Desktop/nosepoke/rawdata/"
savepath <- "C:/Users/PC/Desktop/nosepoke/"
csvname <- "nosepoke_output.csv"
setwd(wd)
files <- list.files(wd) for (q in (1:length(files))) ({ current <- paste(wd, files[1], sep="") dat <- scan(file = current, what = "raw", skip=1) dat <- c(dat,"Start") b_array <- apply(data.frame(grep("B:", dat)+1, grep("C:", dat)-1), 1, function(x) (dat[x[1]:x[2]])) b_array <- b_array[- grep(":", b_array),] total_pokes <- as.data.frame(b_array[c(1),]) colnames(total_pokes) <- c("tot_pokes") active_trial <- as.data.frame(b_array[c(2),]) colnames(active_trial) <- c("act_trial") inactive_trial <- as.data.frame(b_array[c(3),]) colnames(inactive_trial) <- c("inact_trial") null_trial <- as.data.frame(b_array[c(4),]) colnames(null_trial) <- c("null_trial") head_trial <- as.data.frame(b_array[c(5),]) colnames(head_trial) <- c("head_trial") active_timeout <- as.data.frame(b_array[c(6),]) colnames(active_timeout) <- c("act_timeout") inactive_timeout <- as.data.frame(b_array[c(7),]) colnames(inactive_timeout) <- c("inact_timeout") null_timeout <- as.data.frame(b_array[c(8),]) colnames(null_timeout) <- c("null_timeout") head_timeout <- as.data.frame(b_array[c(9),]) colnames(head_timeout) <- c("head_timeout") b_array <- cbind(total_pokes, active_trial, inactive_trial, null_trial, head_trial, active_timeout, inactive_timeout, null_timeout, head_timeout) # subjects <- apply(data.frame(grep("Subject:", dat), grep("Experiment:", # dat)), 1, function(x) (dat[x[1]:x[2]])) # subjects <- subjects[- grep(":", subjects),] # rownames(b_array) <- subjects # b_array <- b_array[-c(2:5),] rownames(b_array) <- c("26","27","28","29","30") b_array$RatID <- rownames(b_array) b_array <- b_array[, c(10, 1, 2, 3, 4, 5, 6, 7, 8, 9)] rownames(b_array) <- NULL
}) # b_array
# write.csv(b_array,file=paste(savepath,csvname,sep=""), row.names=FALSE) # setwd(savepath)
# file1 <- read.csv("nosepoke_output1.csv")
# file2 <- read.csv("nosepoke_output2.csv")
# file3 <- read.csv("nosepoke_output3.csv")
# file4 <- read.csv("nosepoke_output4.csv")
# file5 <- read.csv("nosepoke_output5.csv") # file <- rbind(file1, file2, file3, file4, file5)
# write.csv(file,file=paste(savepath,csvname,sep=""), row.names=FALSE) # file <- read.csv("nosepoke_output.csv")
# file <- file[order(file$RatID),]
# file # b_array$RatID <- c("1","4","5","8","9","11","13","14","15","16","17","20",
# "21","22","23","24","26","27","28","29","30") 