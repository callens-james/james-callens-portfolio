# epm_script_different_version.R
# Purpose: Analysis/processing script for behavioral workflow data.
# Note: Public portfolio version; paths and sensitive identifiers should be parameterized. wd <- "C:/Users/PC/Desktop/tanni/rawdata/"
funcpath <- "C:/Users/PC/Desktop/tanni/"
csvname <- "data_test.csv"
num_rats <- 20
#-----------------------------------------------
setwd(wd)
files <- list.files(wd) list.of.packages = c("dplyr", "qpcR")
new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages) library(dplyr)
library(qpcR)
#-----------------------------------------------
current=paste (wd,files[1],sep="") dat=scan (file=current,what="raw",skip=1) dat=c(dat,"Start")
closed_arm <- apply(data.frame(grep("C:",dat)+1,grep("D:",dat)-1),1,function(x) (dat[x[1]:x[2]]))
closed_arm <- as.data.frame(closed_arm[-grep(":", closed_arm)])
colnames(closed_arm) <- "closed_arm"
junction <- apply(data.frame(grep("B:",dat)+2,grep("M:",dat)-1),1,function(x) (dat[x[1]:x[2]]))
junction <- as.data.frame(junction[-grep(":", junction)])
colnames(junction) <- "junction"
open_arm <- apply(data.frame(grep("O:",dat)+1,grep("R:",dat)-1),1,function(x) (dat[x[1]:x[2]]))
open_arm <- as.data.frame(open_arm[-grep(":", open_arm)])
colnames(open_arm) <- "open_arm"
runway_data <- apply(data.frame(grep("R:",dat)+3,grep("X:",dat)-4),1,function(x) (dat[x[1]:x[2]]))
runway_data <- as.data.frame(runway_data[-grep(":", runway_data)])
colnames(runway_data) <- "runway_data"
Subject <- gsub("/","-",dat[grep("Experiment",dat)-1])
Subject <- as.data.frame(Subject)
Subject <- t(Subject)
colnames(Subject) <- c("Subject")
rownames(Subject) <- NULL
closed_arm <- t(closed_arm)
colnames(closed_arm) <- c("Closed_Explorations", "Closed_Entrances", "Time_in_Closed_Runways")
rownames(closed_arm) <- NULL
open_arm <- t(open_arm)
colnames(open_arm) <- c("Open_Explorations", "Open_Entrances", "Time_in_Open_Runways")
rownames(open_arm) <- NULL
runway_data <- t(runway_data)
colnames(runway_data) <- c("Full_Entrances_Runway_1_Closed", "Full_Entrances_Runway_2_Open", "Full_Entrances_Runway_3_Closed", "Full_Entrances_Runway_4_Open")
rownames(runway_data) <- NULL
junction <- t(junction)
colnames(junction) <- c("Junction")
rownames(junction) <- NULL
data <- qpcR:::cbind.na(Subject, closed_arm, open_arm, runway_data, junction)
rownames(data) <- NULL pointer=data.frame(matrix(ncol = 12, nrow = num_rats))
colnames(pointer) <- colnames(data)
#-----------------------------------------------
for (q in (1:length(files))) ({ current=paste (wd,files[q],sep="") dat=scan (file=current,what="raw",skip=1) dat=c(dat,"Start") closed_arm <- apply(data.frame(grep("C:",dat)+1,grep("D:",dat)-1),1,function(x) (dat[x[1]:x[2]])) closed_arm <- as.data.frame(closed_arm[-grep(":", closed_arm)]) colnames(closed_arm) <- "closed_arm" junction <- apply(data.frame(grep("B:",dat)+2,grep("M:",dat)-1),1,function(x) (dat[x[1]:x[2]])) junction <- as.data.frame(junction[-grep(":", junction)]) colnames(junction) <- "junction" open_arm <- apply(data.frame(grep("O:",dat)+1,grep("R:",dat)-1),1,function(x) (dat[x[1]:x[2]])) open_arm <- as.data.frame(open_arm[-grep(":", open_arm)]) colnames(open_arm) <- "open_arm" runway_data <- apply(data.frame(grep("R:",dat)+3,grep("X:",dat)-4),1,function(x) (dat[x[1]:x[2]])) runway_data <- as.data.frame(runway_data[-grep(":", runway_data)]) colnames(runway_data) <- "runway_data" Subject <- gsub("/","-",dat[grep("Experiment",dat)-1]) Subject <- as.data.frame(Subject) Subject <- t(Subject) colnames(Subject) <- c("Subject") rownames(Subject) <- NULL closed_arm <- t(closed_arm) colnames(closed_arm) <- c("Closed_Explorations", "Closed_Entrances", "Time_in_Closed_Runways") rownames(closed_arm) <- NULL open_arm <- t(open_arm) colnames(open_arm) <- c("Open_Explorations", "Open_Entrances", "Time_in_Open_Runways") rownames(open_arm) <- NULL runway_data <- t(runway_data) colnames(runway_data) <- c("Full_Entrances_Runway_1_Closed", "Full_Entrances_Runway_2_Open", "Full_Entrances_Runway_3_Closed", "Full_Entrances_Runway_4_Open") rownames(runway_data) <- NULL junction <- t(junction) colnames(junction) <- c("Junction") rownames(junction) <- NULL data <- qpcR:::cbind.na(Subject, closed_arm, open_arm, runway_data, junction) rownames(data) <- NULL colnames(pointer) <- colnames(data) pointer <- rbind(data, pointer)
})
#-----------------------------------------------
data <- pointer
data <- data[rowSums(is.na(data)) == 0,]
write.csv(data,file=paste(funcpath,csvname,sep=""), row.names=FALSE) 