# epm_script.R
# Purpose: Analysis/processing script for behavioral workflow data.
# Note: Public portfolio version; paths and sensitive identifiers should be parameterized. wd <- "C:/Users/PC/Desktop/file/rawdata/"
funcpath <- "C:/Users/PC/Desktop/file/"
csvname <- "data.csv"
setwd(wd)
files <- list.files(wd)
library(dplyr)
# if (file.exists("./rdata")) {unlink("./rdata", recursive = TRUE)}
# dir.create(paste(wd,"rdata",sep="/"))
# rdat <- "./rdata/"
# pointer <- list() for (q in (1:length(files))) ({ current=paste (wd,files[q],sep="") dat=scan (file=current,what="raw",skip=1) dat=c(dat,"Start") C_array <- apply(data.frame(grep("C:",dat)+1,grep("D:",dat)-1),1,function(x) (dat[x[1]:x[2]])) C_array <- as.data.frame(C_array[-grep(":", C_array)]) colnames(C_array) <- "C_array" D_array <- apply(data.frame(grep("D:",dat)+1,grep("E:",dat)-1),1,function(x) (dat[x[1]:x[2]])) D_array <- as.data.frame(D_array[-grep(":", D_array)]) colnames(D_array) <- "D_array" E_array <- apply(data.frame(grep("E:",dat)+1,grep("F:",dat)-1),1,function(x) (dat[x[1]:x[2]])) E_array <- as.data.frame(E_array[-grep(":", E_array)]) colnames(E_array) <- "E_array" F_array <- apply(data.frame(grep("F:",dat)+1,grep("G:",dat)-1),1,function(x) (dat[x[1]:x[2]])) F_array <- as.data.frame(F_array[-grep(":", F_array)]) colnames(F_array) <- "F_array" G_array <- apply(data.frame(grep("G:",dat)+1,grep("H:",dat)-1),1,function(x) (dat[x[1]:x[2]])) G_array <- as.data.frame(G_array[-grep(":", G_array)]) colnames(G_array) <- "G_array" H_array <- apply(data.frame(grep("H:",dat)+1,grep("I:",dat)-1),1,function(x) (dat[x[1]:x[2]])) H_array <- as.data.frame(H_array[-grep(":", H_array)]) colnames(H_array) <- "H_array" I_array <- apply(data.frame(grep("I:",dat)+1,grep("K:",dat)-1),1,function(x) (dat[x[1]:x[2]])) I_array <- as.data.frame(I_array[-grep(":", I_array)]) colnames(I_array) <- "I_array" K_array <- apply(data.frame(grep("K:",dat)+1,grep("L:",dat)-1),1,function(x) (dat[x[1]:x[2]])) K_array <- as.data.frame(K_array[-grep(":", K_array)]) colnames(K_array) <- "K_array" L_array <- apply(data.frame(grep("L:",dat)+1,grep("O:",dat)-1),1,function(x) (dat[x[1]:x[2]])) L_array <- as.data.frame(L_array[-grep(":", L_array)]) colnames(L_array) <- "L_array" O_array <- apply(data.frame(grep("O:",dat)+1,grep("R:",dat)-1),1,function(x) (dat[x[1]:x[2]])) O_array <- as.data.frame(O_array[-grep(":", O_array)]) colnames(O_array) <- "O_array" R_array <- apply(data.frame(grep("R:",dat)+1,grep("X:",dat)-1),1,function(x) (dat[x[1]:x[2]])) R_array <- as.data.frame(R_array[-grep(":", R_array)]) colnames(R_array) <- "R_array" X_array <- apply(data.frame(grep("X:",dat)+1,grep("X:",dat)+11),1,function(x) (dat[x[1]:x[2]])) X_array <- as.data.frame(X_array[-grep(":", X_array)]) colnames(X_array) <- "X_array"
}) data <- bind_rows(C_array,D_array,E_array,F_array,G_array,H_array, I_array,K_array,L_array,O_array,R_array,X_array)
data[] <- lapply(data, function(x) x[order(is.na(x))])
data <- data[rowSums(is.na(data)) < ncol(data),]
Subject <- gsub("/","-",dat[grep("Experiment",dat)-1])
Subject <- as.data.frame(Subject) for (q in (1:length(files))) ({ current=paste (wd,files[q],sep="") dat=scan (file=current,what="raw",skip=1) dat=c(dat,"Start") Subject <- gsub("/","-",dat[grep("Experiment",dat)-1])
})
# Subject
data$Subject <- Subject
data <- data[,c(13,1,2,3,4,5,6,7,8,9,10,11,12)]
data
# write.csv(data,file=paste(funcpath,csvname,sep=""), row.names=FALSE) 