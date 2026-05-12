#CREATORS AND EDITORS ----
# Master Script Assembled by James Callens
# Sub Scripts Created by James Callens, Johann Du Hoffmann, Annie Ly #----------------------------------------
#SELECTION SCRIPT ----
#Created by James Callens experiment_selection = function(wd)({ list.of.packages = c("plyr", "readr", "shiny", "tidyr", "dplyr", "openxlsx", "ggplot2", "reshape2", "rsconnect", "data.table") new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])] if(length(new.packages)) install.packages(new.packages) if (experiment == "fr") { fr_summary.rFUNC(wd,funcpath) }else if (experiment == "pr") { pr.rFUNC(wd,funcpath) }else if (experiment == "of") { open_field.rFunc(savePDF,wd,funcpath,saveHeatMap) }else if (experiment == "split_xl_to_csv") { library(readxl) split_excel_sheets_to_csv.rFUNC(wd) }else if (experiment == "clear_workspace") { clear_workspace.rFUNC(wd)} }) #----------------------------------------
#CLEAR WORKSPACE SCRIPT ----
#Created by James Callens clear_workspace.rFUNC = function(wd)({ if(!is.null(dev.list())) dev.off() cat("\014") rm(list=ls())
})
#----------------------------------------
#PROGRESSIVE RATIO SCRIPT ----
#Created by Johann Du Hoffmann
# Edited by James Callens pr.rFUNC=function(wd,funcpath) ({ setwd(wd) files=list.files(wd) dir.create(paste(wd,"save",sep="/")) dir.create(paste(wd,"rdata",sep="/")) savepath = "./save/" rdat = "./rdata/" bigout=list() pointer=data.frame() for (q in (1:length(files))) ({ current=paste (wd,files[q],sep="") dat=scan (file=current,what="raw",skip=1) infusionT=apply (data.frame (grep("A:",dat)+1,grep("B:",dat)-1),1,function(x) (dat[x[1]:x[2]])) infusionT=apply(infusionT,2,function(x) (x[-grep(":",x)] )) effortReq=apply (data.frame (grep("J:",dat)+1,grep("J:",dat)+31),1,function(x) (dat[x[1]:x[2]])) if (is.na(effortReq[25,1]==NA)==T) (effortReq=apply (data.frame (grep("J:",dat)+1,grep("J:",dat)+24),1,function(x) (dat[x[1]:x[2]]))) else ({ if (effortReq[25,1]=="Start") (effortReq=apply (data.frame (grep("J:",dat)+1,grep("J:",dat)+24),1,function(x) (dat[x[1]:x[2]]))) }) effortReq=apply(effortReq,2,function(x) (x[-grep(":",x)] )) effortReq=apply(effortReq,2,function(x) (as.numeric(x))) eventidx=data.frame(grep("C:",dat,ignore.case = FALSE,fixed=T)+1,grep("J:",dat,ignore.case = FALSE)-1) fixRlever.rFunc=function(x) ({ tofill=x tocol=cbind(tofill,rep(NA,length(tofill))) tocol[which(tofill=="0.200"),2]="rew" tocol[which(tofill=="0.500")-1,2]="inact" tocol[which(tofill=="0.200")-1,2]="act" tocol=tocol[-which(tocol[,1]=="0.500"),] tocol[which (is.na(tocol[,2])),2]="act" fixed=as.vector (unlist (t(tocol))) fixed[which(fixed=="act")]="0.500" fixed=fixed[-which(fixed=="inact")] fixed=fixed[-which(fixed=="rew")] }) if (nrow(eventidx)>1) ({ events=apply (eventidx,1,function(x) (dat[x[1]:x[2]])) events=lapply(events,function(x) (x[-grep(":",x)])) events=lapply(events,function(x) (x[-1])) actpressIDX=lapply(events,function(x)(which(x=="0.500"))) rewIDX=lapply(events,function(x)(which(x=="0.200"))) probidx=seq(1,nrow(eventidx)) probfiles=lapply(probidx,function(x) (length(actpressIDX[[x]])<max (cumsum (effortReq[1:length(rewIDX[[x]]),1])))) tofix=which (unlist(probfiles)==T) if (length(tofix)>1) ({ fixed=lapply(tofix,function(x) (fixRlever.rFunc(events[[x]]))) events[tofix]=fixed actpressIDX=lapply(events,function(x)(which(x=="0.500"))) rewIDX=lapply(events,function(x)(which(x=="0.200"))) }) }) else ({ events=dat[eventidx[1,1]:eventidx[1,2]] events=events[-grep(":",events)] events=events[-1] actpressIDX=as.vector (which(events=="0.500")) newactpressIDX=list() newactpressIDX[[1]]=actpressIDX actpressIDX=newactpressIDX newR=list() newR[[1]]=as.vector (which(events=="0.200")) rewIDX=newR }) if (nrow(eventidx)==1) ({ makelist=list() eventsI=as.vector(events) makelist[[1]]=eventsI events=makelist }) idx=as.list (seq(1,length(actpressIDX))) inactivepress=lapply(idx,function(x) (which (seq(1,length(events[[x]])) %in% sort (c(actpressIDX[[x]],actpressIDX[[x]]-1,rewIDX[[x]]))==F))) if (nrow(eventidx)>1) ({ noact=unlist (lapply(actpressIDX,FUN=length)) noinact=unlist (lapply(inactivepress,FUN=length)) acts=which(noact!=0) inacts=which(noinact!=0) }) else ({ noact=length(actpressIDX[[1]]) noinact=length (inactivepress[[1]]) acts=which(noact!=0) inacts=which(noinact!=0) }) events=lapply(events,function(x) (as.numeric(x) )) gettime=events sessionT=list() for (i in (1:length(gettime))) ({ gettime[[i]][actpressIDX[[i]]]=0 gettime[[i]][rewIDX[[i]]]=0 naidx=which(gettime[[i]]==0) gettime[[i]]=gettime[[i]]*0.01 out=cumsum (gettime[[i]]) out[naidx]=0 sessionT[[i]]=out }) if (nrow(eventidx)==1) (sessionT[[1]]=as.vector (unlist (sessionT[[1]]))) rewT=lapply (idx,function(x) (sessionT[[x]][rewIDX[[x]]-2])) activeT=lapply (idx,function(x) (sessionT[[x]][actpressIDX[[x]]-1])) inactiveT=lapply (idx,function(x) (sessionT[[x]][inactivepress[[x]]])) tidx=lapply(idx,function(x) (findInterval (activeT[[x]],rewT[[x]]+0.0000001))+1) intidx=lapply(idx,function(x) (findInterval (inactiveT[[x]],rewT[[x]]+0000000.1))+1) if (length(which(noact==0))) (actlist=list()) if (length(which(noact==0))) (aidx=idx[-which(noact==0)]) if (length(which(noact==0))==0)(activeDF=lapply(idx,function(x) (data.frame (rtime=activeT[[x]],tnum=tidx[[x]],effort=effortReq[,x] [tidx[[x]]],rew=F,rtype="active",stringsAsFactors=F)))) else ({ activeDF=lapply(aidx,function(x) (data.frame (rtime=activeT[[x]],tnum=tidx[[x]],effort=effortReq[,x] [tidx[[x]]],rew=F,rtype="active",stringsAsFactors=F))) }) if (length(which(noinact==0))) (noactlist=list()) if (length(which(noinact==0))) (iidx=idx[-which(noinact==0)]) if (length(which(noinact==0))==0)(inactiveDF=lapply(idx,function(x) (data.frame (rtime=inactiveT[[x]],tnum=intidx[[x]],effort=effortReq[,x] [intidx[[x]]],rew=F,rtype="inactive",stringsAsFactors=F)))) else ({ inactiveDF=lapply(iidx,function(x) (data.frame (rtime=inactiveT[[x]],tnum=intidx[[x]],effort=effortReq[,x] [intidx[[x]]],rew=F,rtype="inactive",stringsAsFactors=F))) }) Uidx=lapply(activeDF,function(x) (unique(x$effort))) if (length(which(noact==0))==0) (eidx=lapply(idx,function(p)(sapply(Uidx[[p]],function(x) (length(which(activeDF[[p]]$effort==x))))))) else ({ newidx=as.list (seq(1,length(Uidx))) eidx=lapply(newidx,function(p)(sapply(Uidx[[p]],function(x) (length(which(activeDF[[p]]$effort==x)))))) }) rewPress=lapply(eidx,FUN=cumsum) for (d in (1:length(activeDF))) ({ activeDF[[d]]$rew[rewPress[[d]]]=T lastbout=rewPress[[d]][length (rewPress[[d]])]-rewPress[[d]][length (rewPress[[d]])-1] if (activeDF[[d]]$effort[rewPress[[d]][length (rewPress[[d]])]]!=lastbout) (activeDF[[d]]$rew[rewPress[[d]][length (rewPress[[d]])]]=F) }) if (length(activeDF)!=length(inactiveDF)) ({ if (length (acts)<length (inacts)) ({ actlist[acts]=activeDF actlist[[which(noact==0)]]=data.frame (rbind (rep(NA,ncol(activeDF[[1]])))) colnames (actlist[[which(noact==0)]])=colnames(activeDF[[1]]) actlist[[which(noact==0)]]$rtype="active" activeDF=actlist }) else ({ if (length (acts)>length (inacts)) ({ inactlist[inacts]=inactiveDF inactlist[[which(noinact==0)]]=data.frame (rbind (rep(NA,ncol(inactiveDF[[1]])))) colnames (inactlist[[which(noinact==0)]])=colnames(inactiveDF[[1]]) inactlist[[which(noinact==0)]]$rtype="active" inactiveDF=inactlist }) }) }) out=lapply(idx,function(x) (data.frame(rbind (activeDF[[x]],inactiveDF[[x]]),stringsAsFactors=F))) out=lapply(out,function(x) (x[order(x$rtime),])) rname=dat[grep("Subject",dat)+1] medname=rep(files[q],length(rname)) boxnum=unlist (lapply (strsplit (paste ("Box",dat[grep("Box:",dat)+1],sep=""),"Box"),function(x) (x[2]))) dates=gsub ("/","-",dat[grep("Subject",dat)-4]) gen=as.vector (sapply(rname,function(x) (substr(x,nchar(x),nchar(x))))) grp=dat[grep("Group",dat)+1] pout=data.frame(cbind (ID=rname,gen=gen,tx=grp,date=dates,box=boxnum,medfile=medname),stringsAsFactors=F) pointer=data.frame (rbind(pointer,pout,stringsAsFactors=F)) bigout=c(bigout,out) rm(dat) rm(events) }) pointer$lidx=seq(1,length(bigout)) pointer$etype=paste(pointer$gen,pointer$tx,sep="") save(pointer,file=paste(rdat,"pointer.rDAT",sep="")) write.csv(pointer,file=paste(rdat,"pointer.csv",sep="")) save(bigout,file=paste(rdat,"bigout.rDAT",sep="")) ####################################################################################################################### ####################################################################################################################### #pr summary step 2 ####################################################################################################################### ####################################################################################################################### #Created by Johann Du Hoffmann # Edited by James Callens pdfname="./save/output.pdf" #-----------------------------------------------------------------#PDF OUTPUT NAME. pdf(file=pdfname) load(paste(rdat,"pointer.rDAT",sep="")) load(paste(rdat,"bigout.rDAT",sep="")) bidx=seq(1,18,1) actpress=list() inactpress=list() rewards=list() apress=list() for (i in (1:nrow(pointer))) ({ out=bigout[[i]] actives=findInterval(out$rtime [which (out$rtype=="active")],bins) inactives=findInterval(out$rtime [which (out$rtype=="inactive")],bins) rew=findInterval(out$rtime [which (out$rew=="TRUE")],bins) actn=sapply(bidx,function(x) (length(which(actives==x)))) inactn=sapply(bidx,function(x) (length(which(inactives==x)))) rewn=sapply(bidx,function(x) (length(which(rew==x)))) actpress[[i]]=actn inactpress[[i]]=inactn rewards[[i]]=rewn apressidx=out$rtime [which(out$rtype=="active")] apress[[i]]=apressidx }) amax=max (unlist (lapply(apress,FUN=length))) utype=as.list (unique(pointer$etype)) uidx=lapply(utype,function(x) (which(pointer$etype==x))) splitdat=lapply(uidx,function(x) (apress[x])) slength=max (unlist (lapply(splitdat,function(x) (lapply(x,function(y) (max(y))))))) tidx=seq(1000,20000,1000) stime=tidx [which (min (abs (slength-tidx))==abs (slength-tidx))] plotnames=utype plot.rFunc=function (x,y,z,k) ({ plot.new() plot.window(xlim=c(0,k),ylim=c(0,z),xaxt="n", yaxt="n") lapply(x,function(p) (lines(p,seq(1,length(p)),lwd=2,col="black"))) axis(1,at=seq(0,k,k/4),seq(0,k,k/4),labels=,tcl=-0.75) axis(2,at=seq(0,amax,1000),labels=seq(0,amax,1000),las=2,tcl=-0.75) mtext("Time (s)",1,2) mtext("Cumulative lever presses",2,3) mtext(y,3.25,cex=1.5) #dev.new() }) cidx=seq(1,length(splitdat)) colidx=c("black","firebrick","gray","blue") lapply(cidx,function(x) (plot.rFunc(splitdat[[x]],plotnames[[x]],amax,stime))) actout=data.frame (do.call("rbind",actpress)) inactout=data.frame (do.call("rbind",inactpress)) rewards=data.frame (do.call("rbind",rewards)) nameidx=sapply(seq(1,length(bins)-1),function(x) (paste(bins[x],bins[x+1],sep="-"))) colnames(actout)=nameidx colnames(inactout)=nameidx colnames(rewards)=nameidx actout$etype=pointer$etype actout$ID=pointer$ID actout$date=pointer$date actout=do.call("rbind",split(actout,actout$etype)) row.names(actout)=seq(1,nrow(actout)) trimidx=seq((findInterval (slength,bins)+1),(ncol(actout)-3)) actout=actout[,-trimidx] forcrunch=lapply(uidx,function(x) (actout[x,1:(ncol(actout)-3)])) meanpress=lapply(seq(1,length(forcrunch)),function(x) (round (as.vector (apply(forcrunch [[x]],2,FUN=mean))))) meanpresssd=lapply(seq(1,length(forcrunch)),function(x) (round (as.vector (apply(forcrunch [[x]],2,FUN=sd))))) meanlength=unlist (lapply(forcrunch,function(x) (nrow(x)))) meanse=lapply(seq(1,length(meanpresssd)),function(x) (meanpresssd[[x]]/(sqrt(meanlength[[x]])))) mmax=seq(0,10000,100) meanm=mmax [which (min (abs (max (unlist(meanpress))-mmax))==abs (max (unlist(meanpress))-mmax))] plot.new() plot.window(xlim=c(0,length(meanpress[[1]])),ylim=c(0,meanm),xaxt="n", yaxt="n") midx=as.list(seq(1,length(meanpress))) colidx=c("black","red","gray","blue") lapply(midx,function(p) (lines(seq(1,length(meanpress[[p]])),meanpress[[p]],lwd=2,col=colidx[[p]]))) axis(1,at=seq(1,length(meanpress[[1]])),seq(0,stime,600),tcl=-0.75) axis(2,at=seq(0,meanm,100),labels=seq(0,meanm,100),las=2,tcl=-0.75) mtext("Time (minutes)",1,2) mtext("Cumulative lever presses",2,3) barcol="red" #error.bar <- function(x, y, upper, lower=upper, length=0,...){ error.bar <- function(x, y, upper,pcol, lower=upper, length=0,...){ if(length(x) != length(y) | length(y) !=length(lower) | length(lower) != length(upper)) stop("vectors must be same length") arrows(x,y+upper, x, y-lower, angle=90,col=pcol,lwd=1, code=3, length=length, ...) } #error.bar(seq(1,length(meanpress[[1]])),meanpress[[1]],meanse[[1]],pcol="black") #error.bar(seq(1,length(meanpress[[2]])),meanpress[[2]],meanse[[2]],pcol="red") #error.bar(seq(1,length(meanpress[[3]])),meanpress[[3]],meanse[[3]],pcol="gray") #error.bar(seq(1,length(meanpress[[4]])),meanpress[[4]],meanse[[4]],pcol="blue") inactout$etype=pointer$etype inactout$ID=pointer$ID inactout$date=pointer$date inactout=do.call("rbind",split(inactout,inactout$etype)) row.names(inactout)=seq(1,nrow(inactout)) rewards$etype=pointer$etype rewards$ID=pointer$ID rewards$date=pointer$date rewards=do.call("rbind",split(rewards,rewards$etype)) row.names(rewards)=seq(1,nrow(rewards)) write.csv(actout,file=paste(savepath,"activesummary.csv",sep=""),row.names=F) write.csv(inactout,file=paste(savepath,"inactivesummary.csv",sep=""),row.names=F) write.csv(rewards,file=paste(savepath,"rewards.csv",sep=""),row.names=F) graphics.off() rm(list=ls()) })
#----------------------------------------
#SOCIAL INTERACTION SCRIPT ----
#Created by James Callens
socialint.rFUNC=function(wd,csvname,funcpath) ({ setwd(wd) library(tidyr) library(dplyr) library(reshape2) library(purrr) ######################################################################################## time_converter.rFUNC <- function(x) { vapply(strsplit(x, ':'), function(y) sum(as.numeric(y) * c(60, 1)), numeric(1), USE.NAMES=FALSE) } ######################################################################################## files = list.files(path=wd, pattern="*.csv", full.names=TRUE, recursive=FALSE) lap.list = lapply(files, function(x) { dat2 = read.csv(x, header= TRUE) dat2 = dat2[, -c(1)] }) lap.list <- melt(lap.list) lap.list <- as.data.frame(lap.list) lap.list <- lap.list[, -c(3:4)] lap.list <- lap.list[complete.cases(lap.list), ] colnames(lap.list) <- c("lap_time", "tot_time", "subject") lap.list$lap_time <- time_converter.rFUNC(lap.list$lap_time) lap.list$tot_time <- time_converter.rFUNC(lap.list$tot_time) dat <- lap.list dat <- dat[, c(3,1,2)] dat$lap <- 1 for (row in 2:nrow(dat)) { if (dat[row, "tot_time"] > dat[row - 1, "tot_time"]) { dat[row, "lap"] = dat[row - 1, "lap"] + dat[row, "lap"] } else {dat[row, "lap"] = 1} } dat$behav_type <- 0 for (row in 1:nrow(dat)) { if (dat[row, "lap"] %%2==0) { dat[row, "behav_type"] = c("interacting") } else {dat[row, "behav_type"] = c("not_interacting")} } for (row in 1:nrow(dat)) { if (dat[row, "subject"] == c("1")) {dat[row, "subject"] = c("01")} if (dat[row, "subject"] == c("2")) {dat[row, "subject"] = c("02")} if (dat[row, "subject"] == c("3")) {dat[row, "subject"] = c("03")} if (dat[row, "subject"] == c("4")) {dat[row, "subject"] = c("04")} if (dat[row, "subject"] == c("5")) {dat[row, "subject"] = c("05")} if (dat[row, "subject"] == c("6")) {dat[row, "subject"] = c("06")} if (dat[row, "subject"] == c("7")) {dat[row, "subject"] = c("07")} if (dat[row, "subject"] == c("8")) {dat[row, "subject"] = c("08")} if (dat[row, "subject"] == c("9")) {dat[row, "subject"] = c("09")} } dat$group = case_when( dat$subject %in% c("01","04", "07", "10", "13", "16", "19", "22", "25", "28") ~ "veh", dat$subject %in% c("02","05", "08", "11", "14", "17", "20", "23", "26", "29") ~ "thc1", dat$subject %in% c("03","06", "09", "12", "15", "18", "21", "24", "27", "30") ~ "thc2") dat$Behav_START_sec <- 0 dat$Behav_END_sec <- 0 dat <- dat[, c(1,6,3,2,7,8,4,5)] dat$cue_type <- c("rat_in_box") colnames(dat) = c("SubjectID", "Group", "Lap_Time", "Behav_DURATION_sec", "Behav_START_sec", "Behav_END_sec", "Lap_Count", "Behavior_Type", "Stimulus") for (row in 2:nrow(dat)) { if (dat[row, "SubjectID"] == dat[row - 1, "SubjectID"]) { dat[row, "Behav_START_sec"] = dat[row - 1, "Lap_Time"] } else {dat[row, "Behav_START_sec"] = 0} } dat[1,6] <- dat[1,3] for (row in 2:nrow(dat)) { dat[row, "Behav_END_sec"] = dat[row, "Lap_Time"] } dat <- dat[, c(1,2,7,5,6,4,3,8,9)] ########################################### # End Time Smoothing ########################################### dat$diff <- 0 for (row in 2:nrow(dat)) { if (dat[row, "SubjectID"] != dat[row - 1, "SubjectID"]) { dat[row - 1, "diff"] = 600 - dat[row - 1, "Behav_END_sec"] } } for (row in 1:nrow(dat)) { dat[row, "Behav_END_sec"] = dat[row, "Behav_END_sec"] + dat[row, "diff"] dat[row, "Lap_Time"] = dat[row, "Lap_Time"] + dat[row, "diff"] dat[row, "Behav_DURATION_sec"] = dat[row, "Behav_DURATION_sec"] + dat[row, "diff"] } dat$diff <- 0 for (row in 1:nrow(dat)) { if (dat[row, "Behav_END_sec"] > 600) { dat[row, "diff"] = dat[row, "Behav_END_sec"] - 600 } } for (row in 1:nrow(dat)) { dat[row, "Behav_END_sec"] = dat[row, "Behav_END_sec"] - dat[row, "diff"] dat[row, "Lap_Time"] = dat[row, "Lap_Time"] - dat[row, "diff"] dat[row, "Behav_DURATION_sec"] = abs(dat[row, "Behav_DURATION_sec"] - dat[row, "diff"]) } for (row in 2:nrow(dat)) { if (dat[row - 1, "Behav_END_sec"] == 600 & dat[row, "Behav_END_sec"] == 600) { dat[row, "Behav_END_sec"] = NA } } dat <- subset(dat, Behav_END_sec != "NA") dat <- dat[, -c(10)] ########################################### dat$File_Count <- 0 for (row in 1:nrow(dat)) { if (dat[row, "File"] == 1) {dat[row, "File_Count"] = 1 } else if (dat[row, "File"] == 2) {dat[row, "File_Count"] = 2 } else if (dat[row, "File"] == 3) {dat[row, "File_Count"] = 3 } else if (dat[row, "File"] == 4) {dat[row, "File_Count"] = 1 } else if (dat[row, "File"] == 5) {dat[row, "File_Count"] = 2 } else if (dat[row, "File"] == 6) {dat[row, "File_Count"] = 3 } else if (dat[row, "File"] == 7) {dat[row, "File_Count"] = 1 } else if (dat[row, "File"] == 8) {dat[row, "File_Count"] = 2 } else if (dat[row, "File"] == 9) {dat[row, "File_Count"] = 3 } else if (dat[row, "File"] == 10) {dat[row, "File_Count"] = 1 } else if (dat[row, "File"] == 11) {dat[row, "File_Count"] = 2 } else if (dat[row, "File"] == 12) {dat[row, "File_Count"] = 3 } else if (dat[row, "File"] == 13) {dat[row, "File_Count"] = 1 } else if (dat[row, "File"] == 14) {dat[row, "File_Count"] = 2 } else if (dat[row, "File"] == 15) {dat[row, "File_Count"] = 3 } else if (dat[row, "File"] == 16) {dat[row, "File_Count"] = 1 } else if (dat[row, "File"] == 17) {dat[row, "File_Count"] = 2 } else if (dat[row, "File"] == 18) {dat[row, "File_Count"] = 3 } } tot_dat <- dat int <- subset(dat, Behavior_Type == "interacting") int$Lap_Count <- 1 for (row in 2:nrow(int)) { if (int[row, "SubjectID"] == int[row - 1, "SubjectID"]) { int[row, "Lap_Count"] = int[row, "Lap_Count"] + int[row - 1, "Lap_Count"] } else {int[row, "Lap_Count"] = 1} } noint <- subset(dat, Behavior_Type == "not_interacting") noint$Lap_Count <- 1 for (row in 2:nrow(noint)) { if (noint[row, "SubjectID"] == noint[row - 1, "SubjectID"]) { noint[row, "Lap_Count"] = noint[row, "Lap_Count"] + noint[row - 1, "Lap_Count"] } else {noint[row, "Lap_Count"] = 1} } write.csv(tot_dat, "dat.csv", row.names = FALSE) write.csv(int, "int.csv", row.names = FALSE) write.csv(noint, "noint.csv", row.names = FALSE)
}) #----------------------------------------
#OPEN FIELD SCRIPT ----
#Created by Johann Du Hoffmann
# Edited by James Callens open_field.rFunc=function(QC,wd,funcpath,saveHeatMap) ({ wrapper.rFUNC=function(QC,wd,funcpath,saveHeatMap)({ dir.create(paste(wd,"rdata",sep="/")) dir.create(paste(wd,"save",sep="/")) rdat="./rdata/" pdfname="output" #-----------------------------------------------------------------#PDF OUTPUT NAME. csvname="ouput.csv" #--------------------------------------------------------------#CSV OUTPUT NAME. #these lines create a list of zones of interest savepath="./save/" threshold=3 #----------------------------------------------------------------------#DON'T CHANGE. FOR OPEN FIELD. setwd(wd) wd = list.files(path=wd, pattern = "*.Export") source(paste(funcpath,"app.R",sep=""),local=TRUE) #pointerCreate.rFunc parses the data and makes an informative list of experiments pointer=pointerCreate.rFunc(wd) load(paste(rdat,"rdata.rDAT",sep="")) load(paste(rdat,"pointer.rDAT",sep="")) zlist=createzones.rFunc(zpath) getzones=as.vector (unique(pointer$etype)) currentzones=zoneselect.rFunc(x=getzones) zidx=lapply(currentzones,function(x) (zlist[x])) dev.off() pdfdate=paste(Sys.Date(),pdfname,sep=" ") if (QC=="yes") (pdf(paste(savepath,paste (pdfdate,".pdf",sep=""),sep=""))) masterdf=list() for (p in (1:length (unique(pointer$eidx)))) ({ currentexpt=which (pointer$eidx==p) exptname=pointer$etype[currentexpt] zoi=zidx[[p]] bigout1=list() for (q in (1:length (currentexpt))) ({ posts=dat[[currentexpt[q]]] posts$ts=as.double(posts$ts) posts=createposts.rFunc(posts) posts=addtoposts.rFunc(posts,threshold,binl) if (is.list(zoi)==T) (allzones=lapply(zoi,function(x) (apply(x,2,function(x) (inzone.rFunc(x)))))) if (is.list(zoi)==T) (residcheck=as.vector (unlist (lapply(zoi,function(x) (abs (x[1]-x[3]) * abs (x[2]-x[4])))))) allzones=residuals.rFunc(zoi,allzones,residcheck) postsR=lapply(vector("list", length(allzones)),function(x) (x=posts)) postsZ=lapply(seq(1:length(postsR)),function(x) (cbind(postsR[[x]],allzones[[x]]))) postsZ=addzonenames.rFunc(postsZ) bigout=onZoneBorder.rFunc(postsZ,zoi) inzoneidx=bigout[[1]] zonedefs=bigout[[2]] znamesRep=bigout[[3]] bindnames=bigout[[4]] for (b in (1:length(inzoneidx))) ({ nameit=unlist (lapply(seq(1:length(znamesRep[[b]])),function (x) (rep(znamesRep[[b]][[x]],length(inzoneidx[[b]][[x]]))))) nameitidx=as.vector (unlist (inzoneidx[[b]])) zonedefs[[b]][nameitidx]=nameit postsZ[[b]]$zoned=zonedefs[[b]] postsZ[[b]]=zonetoposts.rFunc(postsZ[[b]]) postsZ[[b]]=flicker.rFunc(postsZ[[b]]) postsZ[[b]]=addcums.rfunc(postsZ[[b]]) postsZ[[b]]$BoutCumT=as.double(postsZ[[b]]$BoutCumT) tochange=match(bindnames[[b]],colnames(postsZ[[b]])) colnames(postsZ[[b]])[tochange]=paste ("z",substr (colnames(postsZ[[b]])[tochange],5,5),sep="") nameit=bindnames[[b]] tobind=matrix (rep(0,length(nameit)*nrow(postsZ[[b]])),nrow=nrow(postsZ[[b]]),ncol=length(nameit)) colnames(tobind)=nameit postsZ[[b]]=cbind(postsZ[[b]],tobind) postsZ[[b]]=todo.rFunc(postsZ[[b]],bindnames[[b]]) }) #reality check! this prints out the zone analysis. this is QC if (QC=="yes") ({ plotname=paste(pointer$ID[currentexpt[q]],pointer$etype[currentexpt[q]],pointer$dates[currentexpt[q]],sep="_") plot.new() sapply(seq(1,length(zoi)),function(x) (zonecheck.rFunc(zoi[[x]],x,postsZ[[x]]))) mtext(plotname,1,line=-5,cex=2,las=1,outer=T) }) #this will save your raw data posts rawsave=pointer[currentexpt[q],] rawdate=gsub("/","",rawsave$dates) rawname=paste (paste(rawdate,rawsave$expt,rawsave$ID,rawsave$boxnum,sep="_"),".rDAT",sep="") save(postsZ,file=paste (paste(rdat,sep=""),rawname,sep="/")) miniout=lapply(as.list (seq(1,length(postsZ))),function(x) (getsummary.rFunc(postsZ[[x]],pointer$etype[currentexpt[q]],pointer$dates[currentexpt[q]]))) toadd=names(zoi) #this gets the latency to first enter each zone zonelats=lapply(as.list (seq(1,length(postsZ))),function(t) (getzonelats.rfunc(postsZ[[t]]))) #get the total number of entries and exits for each zone entexitnum=lapply(as.list (seq(1,length(postsZ))),function(t) (getentryexitnum.rfunc(postsZ[[t]]))) #this plots the heatmap if (saveHeatMap=="yes") ({ toplot=getvaluesforheatmap.rfunc (postsZ[[1]]) imageplot.rFunc(toplot,title=paste(rawdate,rawsave$expt,rawsave$ID,rawsave$boxnum,sep="_")) }) for (z in (1:length(miniout))) ({ miniout[[z]]$analysis=toadd[z] missingbins=ncol(zoi[[z]])*length (unique(posts$bins)) if (nrow(miniout[[z]])!=missingbins) ({ nameit=paste ("zone",seq(1,ncol(zoi[[z]])),sep="") allpossibleC=as.vector (unlist (sapply(nameit,function (x)(paste(x,unique(posts$bins),sep=" "))))) inMini=paste (as.vector (miniout[[z]]$zoneName),as.vector (miniout[[z]]$binN),sep=" ") missingI=allpossibleC[which (is.na (match (allpossibleC,inMini )))] template=miniout[[z]][nrow(miniout[[z]]),] splits=strsplit(missingI," ") addtomini=do.call ("rbind",lapply(as.list (seq(1:length (splits))),function(x) (addmissingZ.rFunc(splits[[x]],template)))) miniout[[z]]=data.frame ( rbind (miniout [[z]],addtomini),stringsAsFactors = FALSE) }) miniout[[z]]$firstentry="NA" latidx=match (zonelats[[z]][,1],miniout[[z]]$zoneName) miniout[[z]]$firstentry[latidx]=zonelats[[z]][,2] miniout[[z]]$entryN="NA" miniout[[z]]$exitN="NA" maxbin=max (as.numeric (unique(miniout[[z]]$binN))) entex=entexitnum[[z]] #if (entex != "NA") ({ if (length(entexitnum[[z]])>1) ({ onlyent=entexitnum[[z]][which(entex[,3]=="entry"),] onlyex=entexitnum[[z]][which(entex[,3]=="exit"),] ents=apply(onlyent,1,function(s) (paste(s[2],maxbin,sep=""))) exs=apply(onlyex,1,function(s) (paste(s[2],maxbin,sep=""))) indexEn=match (ents,paste (miniout[[z]]$zoneName,miniout[[z]]$binN,sep="")) indexEx=match (exs,paste (miniout[[z]]$zoneName,miniout[[z]]$binN,sep="")) miniout[[z]]$entryN[indexEn]=onlyent[,1] miniout[[z]]$exitN[indexEx]=onlyex[,1] }) }) orderedout=lapply (seq(1,length(miniout)),function(x) (miniout[[x]][order(miniout[[x]]$zoneName),])) bigout1[[q]]=do.call ("rbind",orderedout) }) masterdf[[p]]=bigout1 rm(bigout) rm(zoi) }) if (QC=="yes") (dev.off()) masterdf=do.call("rbind", lapply(masterdf,function(x) (do.call("rbind",x)))) masterdf$binl=binl #masterdf=lapply (lapply (split(masterdf,masterdf$analysis),function(x) (x[order (x$binN),])),function(x) (x[order (x$zoneName),])) dfsave=paste (Sys.Date(),csvname) write.csv(masterdf,file=paste(savepath,dfsave,sep=""),row.names=FALSE) pointersave=paste (Sys.Date(),"pointer") write.csv(pointer,file=paste(rdat,pointersave,".csv",sep=""),row.names=FALSE) return(masterdf) }) wrapper.rFUNC(QC,wd,funcpath,saveHeatMap) ############################################################################################################# ############################################################################################################# #open field split csv script #Created by Johann Du Hoffmann # Edited by James Callens ############################################################################################################# ############################################################################################################# OF_csv_split.rFUNC = function(wd,funcpath)({ savepath="./save/" setwd(wd) #datin = file.choose(list.files(path=savepath, pattern = "*.csv")) datin = list.files(path=savepath, pattern = "*.csv", full.names = TRUE, recursive = FALSE) datin=read.csv(datin) datin=datin[which(datin$analysis=="open field"),] eidx=rle (paste(datin$rat,datin$etype,datin$dates)) datin$enum=rep(seq(1,length (eidx$lengths)),eidx$lengths) tokeep=datin[,c(1,2,3,12,14,15)] idx=lapply(as.list (unique (datin$enum)),function(x) (which(datin$enum==x))) newout=seq(4,11,1) outnames=colnames(datin)[newout] bins=paste("bin",seq(1,eidx$lengths[1]),sep="") for (i in (1:length(newout))) ({ tobind=do.call ("rbind",lapply(idx,function(x) (datin[x,newout[i]]))) info=do.call("rbind",lapply(idx,function(x) (tokeep[x,]))) out=data.frame(cbind(info,tobind),stringsAsFactors=F) row.names(out)=seq(1,nrow(out)) colnames(out)[seq(ncol(out)-length(bins)+1,ncol(out),1)]=bins out$atype=colnames(datin)[newout[i]] write.csv(out,file=paste(savepath,colnames(datin)[newout[i]],".csv",sep="")) rm(out) rm(tobind) }) }) OF_csv_split.rFUNC(wd,funcpath)
})
#----------------------------------------
#OPEN FIELD FUNCTIONS ----
#Created by Johann Du Hoffmann
# Edited by James Callens pointerCreate.rFunc=function(x) ({ alldat=readLines(x) #read and clean up the file headers for each experiment expt=as.vector (unlist (lapply (sapply (alldat [grep("Experiment Title", alldat)],function(x) (strsplit(x,":"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) sessionlength=as.vector (unlist (lapply (sapply (alldat [grep("Session Time", alldat)],function(x) (strsplit(x,":"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) boxnum=as.vector (unlist (lapply (sapply (alldat [grep("Chamber Number", alldat)],function(x) (strsplit(x,":"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) sessiontype=as.vector (unlist (lapply (sapply (alldat [grep("Group ID", alldat)],function(x) (strsplit(x,":"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) dates=as.vector (unlist (lapply (sapply (alldat [grep("Start Date", alldat)],function(x) (strsplit(x,":"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) times=as.vector (unlist (lapply (sapply (alldat [grep("Start Time", alldat)],function(x) (strsplit(x,"e:"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) subject=as.vector (unlist (lapply (sapply (alldat [grep("Subject ID", alldat)],function(x) (strsplit(x,":"))),function(x) (gsub ("^\\s+|\\s+$","",x[2]))))) eidx=rep("f",length(sessiontype)) Uidx=unique(sessiontype) eidx=rep("f",length(sessiontype)) for (i in (1:length(Uidx))) ({ eidx [which(sessiontype==Uidx[i])]=i }) eidx=as.numeric (eidx) #this is a safe guard against situations where session comments were not added. if (length(which(nchar(sessiontype)>0))==length(sessiontype)) (sessiontype=sessiontype) else ({ sessiontype[which(nchar(sessiontype)==0)]="NK" }) #pull all the sessionlengths and convert to numeric foridx=as.numeric (sessionlength) datstart=grep("=====",alldat)+1 datend=(datstart+(foridx*60)*20)-1 cleanerdat=lapply (as.list (seq(1:length(datstart))),function(x) (sapply(alldat[datstart[x]:datend[x]], strsplit, "\\s+", USE.NAMES = FALSE))) cleandat=lapply(cleanerdat,function(x) (do.call("rbind",x)[,c(2,3,4)])) dat=cleandat names(dat)=paste(subject,dates,sessiontype,sep="_") for (p in (1:length(dat))) ({ dat[[p]]=data.frame (seq(0.05,foridx[p]*60,0.05),apply(dat[[p]],2,function(x) (as.numeric(x))),stringsAsFactors =F) colnames(dat[[p]])=c("ts","x","y","z") }) pointer=data.frame(cbind (expt=expt,elength=sessionlength,boxnum=boxnum,etype=sessiontype,dates=dates,times=times,ID=subject,datidx=seq(1,length(dat)),eidx=eidx), stringsAsFactors =F) save(pointer,file=paste(rdat,"pointer.rDAT",sep="")) save(dat,file=paste(rdat,"rdata.rDAT",sep="")) return(pointer)
})
createzones.rFunc=function(x) ({ zlist=list() zlist[[1]]=cbind (c(0,0,8.5,17),c(8.5,0,17,17)) zlist[[2]]=cbind (c(0,8.5,8.5,17),c(8.5,8.5,17,17),c(0,0,8.5,8.5),c(8.5,0,17,8.5)) zlist[[3]]=cbind (c(0,0,17,17),c(4.25,4.25,12.75,12.75)) zlist[[4]]=cbind (c(0,0,17,17),c(6.375,6.375,10.625,10.625)) zlist[[5]]=cbind (c(0,0,17,17),c(0,12.75,4.25,17),c(12.75,12.75,17,17),c(12.75,0,17,4.25),c(0,0,4.25,4.25)) zlist[[6]]=cbind (c(0,0,17,17)) names(zlist)=c("vertical split","quadrants","big center","small center","corners","open field") return(zlist) }) #this plots the zones that are in zone list
plotzones.rFunc=function(x,y,z) ({ screennum=y if (screennum==1) (split.screen(c(3,3))) #this could be expanded if more zones are required screen(screennum) par(mai=rep(0.1,4)) par(oma=rep(0.1,4)) par(pty="s") plot.new() plot.window(xlim=c(0,17),ylim=c(0,17)) rect(0,0,17,17,border="black",lwd=3,col="white") apply (x,2,function(x) (rect(x[1],x[2],x[3],x[4],border="gray88",lwd=3,col="white"))) zonenames=paste("zone",seq(1,ncol(x)),sep="") fortext=apply(x,2,function(x) (c(mean(c(x[1],x[3])),mean(c(x[2],x[4]))))) if (length (which (apply (x,2,function(x) ((abs (x[1]-x[3])*abs (x[2]-x[4]))==(17*17)))))>0) (fortext[2,which (apply (x,2,function(x) ((abs (x[1]-x[3])*abs (x[2]-x[4]))==(17*17))))]=2) points(8.5,8.5,pch=19,cex=4,col="lightblue2") text(fortext[1,],fortext[2,],zonenames) mtext(z,1,pch=19,cex=2,col="black")
}) #to add additional zones: use locator function to find centers of each new plot and then place these coordinates into the identify function.
#these are the values in xs and ys below
#if you want to add zones just plot everything and re-generate these vectors with any additional zones. #getzones=as.vector (unique(pointer$etype)) zoneselect.rFunc=function(x) ({ zonechoice=list() for (i in (1:length(x))) ({ lapply(seq(1,length(zlist)),function(x) (plotzones.rFunc(zlist[[x]],x,names(zlist)[x]))) xs=c(-29.5,-10,8.36,-29.33,-10.5,8.5) ys=c(28.3,28.02,27.8,8.6,8.6,8.23) mtext(getzones[i],1,line=-5,cex=5,las=1,outer=T) zonechoice[[i]]=identify(xs,ys,n=10,tolerance=0.5,plot=F) close.screen(all=T) }) names(zonechoice)=getzones return(zonechoice)
}) #this function is used below to calculate distance traveled between time steps
diffs.rFunc=function(x,y) ({ out=sqrt (((x[2]-x[1])^2)+((y[2]-y[1])^2))
}) # lets pre index our position xs and ys so that we can look at movement between t1 and t2, t2 and t3 etc.
createposts.rFunc=function(z) ({ smoothidx=matrix (cbind (seq(1:nrow(z)),seq(1:nrow(z))+1),byrow=F,ncol=2,nrow=nrow(z)) smoothx=matrix(z[smoothidx,2],ncol=2,nrow=nrow(z),byrow=F) smoothy=matrix(z[smoothidx,3],ncol=2,nrow=nrow(z),byrow=F) #here we calculate the distance traveled in each 50ms time step by calculating the distance traveled in each time step using the diffs.rFunc idx=seq(1,nrow(smoothx)) distsd=sapply(idx,function(t) (diffs.rFunc(smoothx[t,],smoothy[t,]))) z$sd=distsd #I noticed that a few sessions wer begun manually rather than on the first beam break. this next line gets rid of any missing points. if (length (which (is.na (z$x)))>0) (z=z [-which (is.na (z$x)),]) return(z)
}) # below we add to the posts data frame. isolating bouts of movement, stillness and vertical beam breaks
addtoposts.rFunc=function(x,y,t) ({ #x=posts #y=movbin #z=binsize x$mov="yes" x$mov [which(x$sd==0)]="no" x$mov [which(x$z>0)]="vert" runlengths=rle(x$mov) x$int=rep (seq(1,length(runlengths$lengths)),runlengths$lengths) # here we apply our thresholds to our data i.e. movbin which is userinput at the top of the analysis script. the same # criteria is used for all three types of bouts (movement,stillness and vertical epochs). Uints=unique(x$int) Ls=rle(x$int)$lengths thresh=Uints [which(Ls>=y)] subthresh=Uints [which(Ls<y)] newruns=thresh [sapply(subthresh,function(x) (which.min(abs(x-thresh))))] prevthresh=x$mov [match (newruns,x$int)] repidx=which (x$int%in% subthresh) toreplace=rep (prevthresh,Ls[subthresh]) x$mov[repidx]=toreplace #this is for instances where the first bout does not meet any criteria. we will assign this bout according to what occurs in the second bout if (length (which (is.na (x$mov)))>0) ({ NextBoutidx=match (max (x$int [which (is.na (x$mov))])+1,x$int) NAidx=which (is.na (x$mov)) x$mov[NAidx]=x$mov[NextBoutidx] }) Nrunlengths=rle(x$mov) x$int=rep (seq(1,length(Nrunlengths$lengths)),Nrunlengths$lengths) #now we have applied our criterion and we know when a rat is moving, not moving or is rearing #lets add binsize information to posts so we can easily access it later. x$bins=findInterval (x$ts,c(0,seq(t,(max(x$ts)-t),length.out=(max(x$ts)/t)-1),max(x$ts)+1)) #this is troubleshooting the binproblem! if (length(unique(x$bins))>1) ({ uint=unique(x$bins)[-1] for (i in (1:length(uint))) ({ tomatch=match(uint[i],x$bins) if (x$int[tomatch]==x$int[tomatch-1]) ({ x$int[tomatch:nrow(x)]=x$int[tomatch:nrow(x)]+1 }) }) }) #this is troubleshooting the binproblem! return(x)
}) #this function is the workhorse of the zone analysis. it asks whether points (x and y in the posts data frame) are within the x1,x2 and y1,y2 of the rectangles that define each zone (from zoi variable). if
#a point meets both criterion the point is by definition within that zone. inzone.rFunc=function(x) ({ testx=ifelse ((posts$x>x[1]) & (posts$x<x[3]),T,F) testy=ifelse ((posts$y>x[2]) & (posts$y<x[4]),T,F) gotcha=ifelse (testx & testy,T,F)
}) #289 equals the area of the box in inches. we are looking for zones that are defined as residuals of the other zones. the residual zones are defined
#as the total area of the box(minus) the area of the zone that is contained within the total area of the box.
residuals.rFunc=function(a,b,c) ({ #a=zoi #b=allzones #c=residcheck if ((length(a)!=1) &(length(which(names(a)=="open field"))!=1)) ({ # these brackets exclude the instance where only the open field anlaysis is selected ridx=which(residcheck==289) #if there are zones that are defined as residuals AND the open field analysis we want to exclude the open field analysis from ridx (we will deal with the "open field" situation below) if (length(ridx)>0 & length (which (as.vector(unlist(lapply (b[ridx],FUN=ncol)))==1))>0 ) ({ ridx=ridx [-which (as.vector(unlist(lapply (b[ridx],FUN=ncol)))==1)] }) # this is attempt to make this script "bug proof" if additional zones are added to the list of zones that I hard coded. the primary difficulty is establishing the different types of residual areas. If you #do add zones and the script the fails. look here first to debug. residF=sapply(ridx,function(x) (which (b[[x]][,2:ncol(b[[x]][,])]==T))) #residF=sapply(ridx,function(x) (which (b[[x]][,2:ncol(b[[x]][,])]==T))) ncolidx=unlist (lapply(b[ridx],FUN=ncol)) multicolidx=length(which(ncolidx>2)) if (multicolidx>0) (midx=ridx[which(ncolidx>2)]) multi.rFunc=function(x) ({ TorF=apply (b[[x]][,2:ncol(b[[x]][,])],1,function(x) (length(which(x==T)))) return (which((TorF)!=0)) }) if (multicolidx>0) (mtoreplace=as.vector (sapply(seq(1:length (midx)),function(x) (multi.rFunc(midx[x]))))) if (exists("midx")==T) (sidx=ridx [-match(midx,ridx)]) if (exists("midx")==F) (sidx=ridx) #this one finds the points in the residual area where there is only one zone. For example, with the "big center" zone definition if (length(sidx)>0) (storeplace=sapply(seq(1:length (sidx)),function(x) (which (b[[sidx[x]]][,2]==T)))) #ok now that everything is indexed, lets clean up thee zones and get the hell out of these conditional statements if (exists("midx")==T) (b[[midx]][mtoreplace,1]=F) if (exists("sidx")==T & (length(sidx)==1)) (b[[sidx]][storeplace,1]=F) if (exists("sidx")==T & (length(sidx)>1)) ({ for (e in (1:length(sidx))) ({ b[[sidx[e]]][storeplace[[e]],1]=F}) }) overlapremove.rFunc=function(p,s,r) ({ #allzones=p #s=midx or sidx #r=mtoreplace or storeplace for (z in (1:length(s))) ({ b[[s[z]]][r[[z]],1]=F }) return(b) }) if (exists("midx")==T) (allzones=overlapremove.rFunc(b,midx,mtoreplace)) if (exists("sidx")==T & (length(sidx)>0)) (allzones=overlapremove.rFunc(b,sidx,storeplace)) if (exists("midx")==T) (rm(midx)) if (exists("sidx")==T) (rm(sidx)) }) #this closes out the conditional statement that protects against analyses with no residuals return(allzones)
}) addzonenames.rFunc=function(x) ({ forZnames=lapply (as.list (unlist (lapply(x,function(p) (ncol(p))))-8),function(p)(seq(1,p))) znames=lapply(forZnames,function(x) (paste("zone",x,sep=""))) for (t in (1:length(znames))) ({ colnames(x[[t]])[9:ncol(x[[t]])]=znames[[t]] }) return(x)
}) #one more step to clean up the zones. I noticed that if the point is ON the line in either axis it would not be assigned to any of the zones. bummer.
# to solve this problem I will assign these values (there are not many) to the zone that the previous point was in
#first step to resolve this issue is to define the zone the rat is in when we can. we add to postsZ "zoned" which indicates when we are certain
#q in postsZ$zoned==where there is no zone assignment
onZoneBorder.rFunc=function(t,y) ({ #t=postsZ #y=zoi out=list() forZnames=lapply (as.list (unlist (lapply(t,function(p) (ncol(p))))-8),function(p)(seq(1,p))) znames=lapply(forZnames,function(x) (paste("zone",x,sep=""))) inzoneidx=lapply(t,function(x) ((apply(x[9:ncol(x)],2,function(x) (which(x==T)))))) znamesRep=lapply(znames,function(x) (as.list(x))) numberofZ=lapply(y,FUN=ncol) bindnames=lapply (lapply(numberofZ,function(x) (seq(1,x))),function(x) (paste("zone",x,sep=""))) zonedefs=lapply (vector("list", 6),function(x) (rep("q",nrow(t[[1]])))) out[[1]]=inzoneidx out[[2]]=zonedefs out[[3]]=znamesRep out[[4]]=bindnames return(out)
}) zonetoposts.rFunc=function(x) ({ qs=which(x$zoned=="q") notq=which(x$zoned!="q") if (length(qs==0)!=0) ({ if (length (which (x$int[qs]==1))>0) (x$zoned[qs[which (x$int[qs]==1)]]= x$zoned[notq[1]]) if (length (which (x$int[qs]==1))>0) (qs=qs[-which (x$int[qs]==1)]) if (length(qs)!=0) ({ lastzone=sapply(seq(1,length(qs)),function(x) (notq[which ((which(notq<qs[x])-qs[x])==max(which(notq<qs[x])-qs[x]))])) x$zoned[qs]=x$zoned[lastzone] }) }) if (length(qs)==0) (x$zoned=x$zoned) return(x)
}) #this gets rid of noise in the zone analysis i.e. where the rat may change zones for one bin flicker.rFunc=function(x) ({ VorS=sort (unique (x$int [c(which(x$mov=="no"),which(x$mov=="vert"))])) totest=sapply(VorS,function(z) (which(x$int==z))) lidx=unlist (lapply(totest,function(z) (length (unique (x$zoned[z]))))) if (length (which(lidx>1))>=1) ({ fevents=totest [which(lidx>1)] ztest=lapply(fevents,function(z) (x$zoned[z])) Azones=lapply(ztest,function(z) (rle(sort(z))$values[which.max (rle(sort(z))$lengths)])) x$zoned[unlist(fevents)]=unlist (rep(Azones,unlist (lapply(fevents,FUN=length)))) }) return(x)
})
#add cumulative time spent in each bout addcums.rfunc=function(z) ({ ubouts=unique(z$int) BoutCumT=unlist (sapply(ubouts,function(x)((seq(0.05,(max(z$ts [which(z$int==x)])-min(z$ts [which(z$int==x)]))+0.05,0.05))))) boutends=cumsum (rle(z$int)$lengths) BoutCumT=as.double (BoutCumT+rep(c(0,diff (z$ts[boutends]-cumsum(BoutCumT[boutends]))),rle(z$int)$lengths)) BoutCumDist=unlist (sapply(ubouts,function(x)(c(0,cumsum(z$sd [which(z$int==x)][-1]))))) BoutCumDist[which(z$mov=="no" | z$mov=="vert")]=NA z$BoutCumDist=BoutCumDist z$BoutCumT=as.double (BoutCumT) zonechange=rep("no",nrow(z)) zonechange[cumsum(rle(z$zoned)$lengths)+1]="yes" z$Zchange=zonechange [-length(zonechange)] return(z)
})
#this function is a beast. it seperates out the cumulative bout time into zones and adds this information into seperate columns
#of postsZ which are named appropriately todo.rFunc=function(z,s) ({ boutends=cumsum (rle(z$int)$lengths) #z$BoutCumT[boutends]=z$BoutCumT[boutends]+0.05 SorV=boutends [sort (c(which (z$mov[boutends]=="vert"),which (z$mov[boutends]=="no")))] todo=cbind ((SorV),(match (z$zoned[SorV],colnames(z)))) vals=apply(todo,1,function(p)(z$BoutCumT[p[1]])) rs=todo[,1] cs=todo[,2] test=t(as.matrix(z)) matrixidx=(rs*ncol(z))-(ncol(z)-cs) test[matrixidx]=vals single.rfunc=function(x) ({ if (length (unique (x$zoned))==1) ({ out=cbind (as.double (x$BoutCumT[length(x$BoutCumT)]), unique (x$zoned),row.names(x)[which.max(x$BoutCumT)]) return (out) }) else ({ runLs=rle(x$zoned) out=cbind (as.double (x$BoutCumT[cumsum (runLs$lengths)]),runLs$values,row.names (x) [(cumsum(runLs$lengths))]) return(out) }) }) idx=which(z$mov=="yes") Uidx=unique (z$int[idx]) sepdat=lapply(as.list (Uidx),function(x) (z[which(z$int==x),])) changeidx=which (unlist (lapply(sepdat,function(x) (length(unique(x$Zchange)))))>1) newcumT.rFunc=function(z) ({ newy=vector() flag=min (which (z$Zchange=="yes"))-1 for (s in (1:nrow(z))) ({ if (s==1) (newy[s]=0) else if (z$Zchange[s]=="no") (newy[s]=newy[s-1]+0.05) else if (z$Zchange[s]=="yes") (newy[s]=0.05) }) newy[flag]=newy[flag]+0.05 if (z$Zchange[1]=="yes") (newy[length(newy)]=newy[length(newy)]+0.05) z$BoutCumT=newy return(z) }) if (length(changeidx)>1) ({ movmod=lapply (as.list (changeidx),function(x) (newcumT.rFunc(sepdat[[x]]))) sepdat[changeidx]=movmod }) if (length(changeidx)==1) ({ movmod=newcumT.rFunc(sepdat[[changeidx]]) sepdat[[changeidx]]=movmod }) testM=lapply(sepdat,function(x) (single.rfunc(x))) Mvals=as.numeric (unlist (lapply(testM,function(x) (x[,1])))) Mcols=as.numeric (sapply (unlist (lapply(testM,function(x) (x[,2]))),function(x) (match(x,colnames(z))))) Mrows=as.numeric (unlist (lapply(testM,function(x) (x[,3])))) Midx=(Mrows*ncol(z))-(ncol(z)-Mcols) test[Midx]=Mvals test2=t(test) rpidx=match(s,colnames(z)) forbind=test2[,rpidx] forbind=as.data.frame (forbind) forbind=apply(forbind,2,function(x) (as.double(as.numeric (x)))) colnames(forbind)=s z[,match(colnames(forbind),colnames(z))]=forbind return(z)
}) #this plots a random sample (50% of points if there are over 5000) of position values for each zone
#this can help you quality check your data
zonecheck.rFunc=function(x,y,z) ({ #x=zoi[[i]] #y=i #z=postsZ[[i]] screennum=y if (screennum==1) (split.screen(c(3,3))) #this could be expanded if more zones are required screen(screennum) par(mai=rep(0.1,4)) par(oma=rep(0.1,4)) par(pty="s") plot.new() plot.window(xlim=c(0,17),ylim=c(0,17)) rect(0,0,17,17,border="black",lwd=3,col="light gray") apply (x,2,function(x) (rect(x[1],x[2],x[3],x[4],border="black",lwd=3,col="white"))) zonenames=paste("zone",seq(1,ncol(x)),sep="") fortext=apply(x,2,function(x) (c(mean(c(x[1],x[3])),mean(c(x[2],x[4]))))) colidx=c("red","blue","green","black","purple") Uidx=unique(z$zoned) tosample=sapply(seq(1:length (Uidx)),function(x) (which(z$zoned==Uidx[x]))) cull.rFunc=function(x) ({ if (length (which (unlist (lapply (lapply(x,FUN=length),function(a) (a>5000)))))>0) ({ sampleidx=which (unlist (lapply (lapply(x,FUN=length),function(a) (a>5000)))) randsamp=lapply (tosample[sampleidx],function(x) (sample(x, (length(x)*0.5), replace = F, prob = NULL))) tosample[sampleidx]=randsamp }) if (is.matrix(x)==T) ({ randsamp=sample(x, (length(x)*0.5), replace = F, prob = NULL) tosample=randsamp }) return(tosample) }) pointidx=cull.rFunc(tosample) if(is.list(pointidx)==T) ({ lapply(seq(1:length (pointidx)),function(x) (points (z$x[pointidx[[x]]],z$y[pointidx[[x]]],cex=0.75,pch=19,col=colidx[x]))) }) if(is.list(pointidx)==F) ({ points (z$x[pointidx],z$y[pointidx],cex=0.75,pch=19,col=colidx[1]) }) if (length (which (apply (x,2,function(x) ((abs (x[1]-x[3])*abs (x[2]-x[4]))==(17*17)))))>0) (fortext[2,which (apply (x,2,function(x) ((abs (x[1]-x[3])*abs (x[2]-x[4]))==(17*17))))]=2) text(fortext[1,],fortext[2,],zonenames,font=2)
}) #if the rat does not move in a bin in an area this fills in the information for the summary so the data format is consistent across all rats
addmissingZ.rFunc=function(s,t) ({ t$stillT=0 t$vertT=0 t$movTtotal=0 t$moveTavg=NA t$movDtotal=NA t$movDavg=NA t$Vavg=NA t$Vmax=NA t$binN=s[2] t$zoneName=s[1] return(t)
}) #this gets the latency to first entry of each zone
getzonelats.rfunc=function(x) ({ uzones=unique(x$zoned) firstentry=as.numeric (sapply(uzones,function(p) (match(p,x$zoned))))*0.05 out=cbind(uzones,firstentry)
})
#this gets total number of entry and exits into each zone getentryexitnum.rfunc=function(x) ({ changeidx=which (x$Zchange=="yes") zchange=x[changeidx,] uzones=unique(zchange$zoned) entries=sapply(uzones,function(s) (length (which (zchange$zoned %in% s)))) entrynum=rbind (cbind (as.vector(entries),uzones,rep("entry",length(entries)))) ezones=x[changeidx-1,] eunique=unique(ezones$zoned) exits=sapply(eunique,function(s) (length (which (ezones$zoned %in% s)))) exitnum=rbind (cbind (as.vector(exits),eunique,rep("exit",length(exits)))) out=rbind(entrynum,exitnum) if (length(uzones)!=0) (return(out)) if (length(uzones)==0) (return("NA")) }) # this function organgizes and parses the summary data
getsummary.rFunc=function(s,a,b) ({ zonematch=paste ("zone",seq(1,5),sep="") allzones=match(zonematch,colnames(s)) if (length (which (is.na(allzones)))>=1) (allzones=allzones[-which (is.na(allzones))]) allzonesidx=apply(s[,allzones],2,function(x) (unlist (as.vector( (which(x!=0)))))) boutends=lapply(allzonesidx,function(x) (s[x,])) if(length(allzones)==1) (boutends=do.call("rbind",boutends)) #zonesplit=lapply (as.list (unique(boutends$zoned)),function(p) (boutends[which(boutends$zoned==p),])) zonesplit=boutends funny.rFunc=function(z,a,b,e,d) ({ verts=z[which(z$mov=="vert"),] mov=z[which(z$mov=="yes"),] nomov=z[which(z$mov=="no"),] zoneOI=e Bidx=unique(z$bins) if (nrow(nomov)!=0) ({ noMovB=sapply(Bidx,function(x) (sum (nomov[which (nomov$bins==x),d],na.rm=T))) }) else ({ noMovB=0}) if (nrow(verts)!=0) ({ vertB=sapply(Bidx,function(x) (sum (verts[which (verts$bins==x),d],na.rm=T))) }) else ({ vertB=0}) movTimeSum=sapply(Bidx,function(x) (sum (mov[which (mov$bins==x),d],na.rm=T))) movTimeAverage=sapply(Bidx,function(x) (mean (mov[which (mov$bins==x),d],na.rm=T))) #movDistTotal=sapply(Bidx,function(x) (sum (mov[which (mov$bins==x),d]))) movDistTotal=sapply(Bidx,function(x) (sum (mov$BoutCumDist[which (mov$bins==x)],na.rm=T))) movDistAverage=sapply(Bidx,function(x) (mean (mov$BoutCumDist[which (mov$bins==x)],na.rm=T))) forVel=mov$BoutCumDist/mov$BoutCumT velAvg=sapply(Bidx,function(x) (mean (forVel[which (mov$bins==x)],na.rm=T))) if (length(which (movTimeSum==0))>=1) (nomovidx=which (movTimeSum==0)) #if (length(which (movTimeSum==0))>=1) (present=Bidx[-nomovidx]) if (length(which (movTimeSum==0))>=1) ({ maxVel=try (sapply(Bidx,function(x) (max (forVel[which (mov$bins==x)],na.rm=F,silent=T)))) maxVel[which (movTimeSum==0)]=NA #toorder=c(maxVel,rep(0,length(nomovidx))) #toorder[present]=maxVel #toorder[nomovidx]=0 #maxVel=toorder }) else ({ maxVel=sapply(Bidx,function(x) (max (forVel[which (mov$bins==x)],na.rm=T))) }) if (is.list (movTimeAverage)==F) ({ if (length (which (is.finite(movTimeAverage)==F))>=1)({ movTimeAverage[which (is.finite(movTimeAverage)==F)]=NA movDistTotal[which (is.finite(movTimeAverage)==F)]=NA movDistAverage[which (is.finite(movTimeAverage)==F)]=NA velAvg[which (is.finite(movTimeAverage)==F)]=NA }) }) if (is.list (movTimeAverage)==T) (binN=NA) else ({ binN=unique(z$bins)}) if (is.list (movTimeAverage)==T) ({ movTimeAverage=NA movDistTotal=NA movDistAverage=NA velAvg=NA maxVel=NA binN=NA noMovB=0 vertB=0 movTimeSum=0 }) out=data.frame(rat=pointer$ID[currentexpt[q]],etype=a,dates=b, stillT=as.double (noMovB),vertT=as.double(vertB),movTtotal=as.double(movTimeSum),moveTavg=movTimeAverage,movDtotal=movDistTotal,movDavg=movDistAverage,Vavg=velAvg, Vmax=maxVel,zoneName=zoneOI,binN=binN,stringsAsFactors =F) return(out) }) znameidx=names(zonesplit) if (length(zonesplit)>10) (znameidx="zone1") if (length(allzones)>1) ({ return (do.call ("rbind",lapply(as.list(seq (1:length (allzones))),function(x) (funny.rFunc(zonesplit[[x]],a,b,znameidx[x],allzones[x]))))) }) if (length(allzones)==1) ({ return (funny.rFunc(zonesplit,a,b,znameidx,allzones)) }) }) #get values for heat map plot getvaluesforheatmap.rfunc=function (x) ({ ytop=rep (seq(1.0001,17.0001),each=17) ybottom=rep (seq(0.0001,16.0001),each=17) xleft= rep (seq(0.0001,16.0001),17) xright= rep (seq(1.0001,17.0001),17) gridtest=as.matrix(cbind (xleft,ybottom,xright,ytop)) tocheck=list() for (i in (1:nrow(gridtest))) ({ testx=ifelse ((x$x>gridtest[i,1]) & (x$x<gridtest[i,3]),T,F) testy=ifelse ((x$y>gridtest[i,2]) & (x$y<gridtest[i,4]),T,F) gotcha=ifelse (testx & testy,T,F) tocheck[[i]]=gotcha }) percenttime=unlist (lapply(tocheck,function(p) (length(which(p==T))/nrow(x)))) toplot=matrix(percenttime,ncol=17,nrow=17,byrow=T) toplot=round(toplot,digits=5) rotate = function(x) t(apply(x, 2, rev)) toplot=rotate(toplot) toplot=toplot*100 return(toplot) }) #plots a grayscale heatmap of time spent in 1"x1" zones
imageplot.rFunc = function(x, ...){ min = min(x) max = max(50) yLabels= rownames(x) xLabels = colnames(x) title =c() # check for additional function arguments if( length(list(...)) ){ Lst =list(...) if( !is.null(Lst$zlim) ){ min = Lst$zlim[1] max = Lst$zlim[2] } if( !is.null(Lst$yLabels) ){ yLabels = c(Lst$yLabels) } if( !is.null(Lst$xLabels) ){ xLabels = c(Lst$xLabels) } if( !is.null(Lst$title) ){ title = Lst$title } } # check for null values if( is.null(xLabels) ){ xLabels = c(1:ncol(x)) } if( is.null(yLabels) ){ yLabels= c(1:nrow(x)) } layout(matrix(data=c(1,2), nrow=1, ncol=2), widths=c(4,1), heights=c(1,1)) ColorRamp=gray.colors(100000, start = 0, end = 1, gamma = 2.2, alpha = NULL) ColorLevels = seq(min, max, length=length(ColorRamp)) # Reverse Y axis reverse = nrow(x) : 1 yLabels = yLabels[reverse] x = x[reverse,] # Data Map #par(mar = c(3,5,2.5,2)) par(mar = c(3,5,2.5,1)) #par (xpd=T) par (pty="m") #par(pty="s") image(1:length(xLabels), 1:length(yLabels), t(x), col=ColorRamp, xlab="", ylab="", axes=FALSE, zlim=c(min,max)) if( !is.null(title) ){ title(main=title) } axis(BELOW<-1, at=1:length(xLabels), labels=xLabels, cex.axis=0.7) axis(LEFT <-2, at=1:length(yLabels), labels=yLabels, las= HORIZONTAL<-1, cex.axis=0.7) # Color Scale par(mar = c(3,1,2.5,2)) par(pty="m") #par(pty="s") image(1, ColorLevels, matrix(data=ColorLevels, ncol=length(ColorLevels),nrow=1), col=ColorRamp, xlab="",ylab="", xaxt="n",las=1) mtext("% of session",3,las=1) layout(1)
} #----------------------------------------
#SPLIT EXCEL SHEETS TO CSV SCRIPT ----
#Created by James Callens split_excel_sheets_to_csv.rFUNC=function(wd) ({
# list.of.packages = c("readxl")
# new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages) setwd(wd) files = list.files(path=wd, pattern="*.xlsx", full.names=TRUE, recursive=FALSE)
# library(readxl) #function to read the excel sheets read_excel_allsheets = function(files) { sheets = readxl::excel_sheets(files) x = lapply(sheets, function(X) readxl::read_excel(files, sheet = X)) names(x) = sheets x} sheets = read_excel_allsheets(files) fname = function(filename) ({ filenames = sub(wd, "", files) filenames = gsub("([0-9]+).*$", "\\1", filenames)}) for(i in names(sheets)){ write.csv(sheets[[i]], paste0(i, ".csv"), row.names=FALSE) }
})
#----------------------------------------
# FR SCRIPT ----
#Created by Johann Du Hoffmann
#Commented and Edited by James Callens and Annie Ly
fr_summary.rFUNC = function(wd,funcpath)({ # FR PART 1 ---- setwd(wd) files=list.files(wd) # csvname = "FR_data.csv" if (file.exists("./rdata")) {unlink("./rdata", recursive = TRUE)} dir.create(paste(wd,"rdata",sep="/")) savepath = funcpath rdat = "./rdata/" pointer=list() ## Beginning of For loop: Test by typing q=1 in R console for (q in (1:length(files))) ({ current=paste (wd,files[q],sep="") dat=scan (file=current,what="raw",skip=1) dat=c(dat,"Start") # ACTIVE PRESSES # Grabbing G: array, which contains absolute times of active(e.g. correct) lever presses active=apply (data.frame (grep("G:",dat)+1,grep("H:",dat)-1),1,function(x) (dat[x[1]:x[2]])) # Removing the 0:, 5:, 10:, ... active=lapply(active,function(x) (x[-grep(":",x)] )) # Determining the number of rats who didn't press the active lever at all noactive= unlist (lapply(active,function(x) (length(x)))) if (length (which(noactive==0)>0)) ({ noactidx=which(noactive==0)}) else ({ noactidx=NA }) # Creating columns labelled "abs.time" and "type" and filled with NA. "tofill" is for the purpose of the next section tofill=lapply(as.list(seq(1,length(active))),function(x) (as.data.frame (cbind (etime=NA,etype=NA)))) # Creating and filling "abs.time" column with data from "active" list and "type" column with "active" active=lapply(active,function(x) (data.frame (cbind(etime=as.numeric (x),etype="act"),stringsAsFactors=F))) # In the scenario that there are rats who DID NOT press the active lever at all, then this if-else statement fills that rat's abs.time and lever.type with NA from "tofill" which was created above. if (is.na (match(NA,noactidx))) ({ aidx=seq(1,length(active))[-noactidx] tofill[aidx]=active[aidx] active=tofill}) else({ active=active }) # Total count of correct responses for each rat -AL total.active= as.integer(apply(data.frame(grep("B:",dat)+3, grep("C:",dat)-7),1,function(x) (dat[x[1]:x[2]]))) # Latency to first active -AL firstA=sapply( X = active, FUN = function(X)( X$etime[1])) # INACTIVE PRESSES ## UNCOMMENT THE FOLLOWING WHEN MSN: "FR Schedule with Act Monitoring Absolute" # # # Creating index values in order to grab H: array # hidx=grep("H:",dat) #Index value of each "H:" # sidx=c(grep ("Start",dat),length(dat)) #Index value of "Start" # iend=unlist (lapply(as.list (hidx),function (x) (which ((x-sidx)<0))[1])) # # # Checking for rats who did not press inactive lever at all # noinact=which(dat[hidx+1]=="Start") # nacheck=which (is.na(dat[hidx+1])) # # if (length(nacheck)> 0) (noinact=c(noinact,nacheck)) # if (length(noinact>0)) ({ # hidx=hidx[-noinact] # iend=iend[-noinact] # }) # # # Grabbing H: array, which contains absolute times of inactive (e.g. incorrect) lever presses # inactive=apply (data.frame (hidx+1,sidx[iend]-1),1,function(x) (dat[x[1]:x[2]])) # # # Removing the 0:, 5:, 10:, ... # inactive=lapply(inactive,function(x) (x[-grep(":",x)] )) # # # Creating columns labelled "abs.time" and "type" and filled with NA. "tofill" is for the purpose of the next section # tofill=lapply(as.list(seq(1,length(inactive))),function(x) (as.data.frame (cbind (etime=NA,etype=NA)))) # # # Creating and filling "abs.time" column with data from "inactive" list and "type" column with "inactive" # inactive=lapply(inactive,function(x) (data.frame (cbind(etime=as.numeric (x),etype="inact"),stringsAsFactors=F))) # # In the scenario that there are rats who DID NOT press the inactive lever at all, then this if-else statement fills that rat's abs.time and lever.type with NA from "tofill" which was created above. # # if (length(noinact)>0 ) ({ # idx=seq(1,length(active))[-noinact] # tofill[idx]=inactive # inactive=tofill # }) else ({ # inactive=inactive # }) ## UNCOMMENT THE FOLLOWING WHEN MSN: "FR_SCRIPT" # # Grabbing H: array, which contains absolute times of inactive(e.g. incorrect) lever presses inactive=apply (data.frame (grep("H:",dat)+1,grep("Q:",dat)-1),1,function(x) (dat[x[1]:x[2]])) # Removing the 0:, 5:, 10:, ... inactive=lapply(inactive,function(x) (x[-grep(":",x)] )) # Determining the number of rats who didn't press the inactive lever at all noinact= unlist (lapply(inactive,function(x) (length(x)))) if (length (which(noinact==0)>0)) ({ noinactidx=which(noinact==0)}) else ({ noinactidx=NA }) # Creating columns labelled "abs.time" and "type" and filled with NA. "tofill" is for the purpose of the next section tofill=lapply(as.list(seq(1,length(inactive))),function(x) (as.data.frame (cbind (etime=NA,etype=NA)))) # Creating and filling "abs.time" column with data from "inactive" list and "type" column with "inactive" inactive=lapply(inactive,function(x) (data.frame (cbind(etime=as.numeric (x),etype="inact"),stringsAsFactors=F))) # In the scenario that there are rats who DID NOT press the inactive lever at all, then this if-else statement fills that rat's abs.time and lever.type with NA from "tofill" which was created above. if (is.na (match(NA,noinactidx))) ({ inaidx=seq(1,length(inactive))[-noinactidx] tofill[inaidx]=inactive[inaidx] inactive=tofill}) else({ inactive=inactive }) # Total count of incorrect responses for each rat -AL total.inactive= as.integer(apply(data.frame(grep("B:",dat)+4, grep("C:",dat)-6),1,function(x) (dat[x[1]:x[2]]))) # Latency to first inactive -AL firstI=sapply( X = inactive, FUN = function(X)( X$etime[1])) # REWARD DELIVERY # the pip array is incomplete in this schedule so we will assume reward is delivered at the correct press time rewT=apply (data.frame (grep("G:",dat)+1,grep("H:",dat)-1),1,function(x) (dat[x[1]:x[2]])) rewT=lapply(rewT,function(x) (x[-grep(":",x)] )) rewT=lapply(rewT,function(x) (data.frame (cbind(etime=as.numeric (x),etype="rew"),stringsAsFactors=F))) reward=rewT tofill=lapply(as.list(seq(1,length(active))),function(x) (as.data.frame (cbind (etime=NA,etype=NA)))) if (is.na (match(NA,noactidx))) ({ aidx=seq(1,length(active))[-noactidx] tofill[aidx]=reward[aidx] reward=tofill}) else({ reward=reward }) timeout=as.numeric (dat[(grep("A:",dat)+5)])*0.01 fr=as.numeric(dat[(grep("A:",dat)+8)]) bindidx=as.list(seq(1,length(active))) datbind=lapply(bindidx,function(x) (data.frame (rbind(active[[x]],inactive[[x]],reward[[x]]),check.names=T,stringsAsFactors=F))) #we use bindidx to index and bind together all the data from a missingvals=lapply(datbind,function(x) (which(is.na (x$etime==T)))) datbind=lapply(datbind,function(x) (x[order(as.numeric (x$etime)),])) #here we order the combined data by time. #newdat=lapply(datbind,function(x) (x[-which(x$etime=="0"),])) #here we get rid of the zero time stamps to make the data tidy icidx=lapply(datbind,function(x) (which (complete.cases(x)==F))) mv=which (unlist (lapply (icidx,FUN=length))>0) nodatacheck=unlist (lapply(as.list (mv),function(x) (nrow(datbind[[x]])))) lengthidx=unlist (lapply(icidx[mv],function(x) (length(x) ))) nodatacheck=which (lengthidx==nodatacheck) if (length(nodatacheck)>0) ({ mv=mv[-nodatacheck] }) naidx=icidx[mv] if (length(naidx)>0) ({ repidx=datbind[mv] iidx=as.list (seq(1,length(repidx))) trimmed=lapply(iidx,function(x) (repidx[[x]][-naidx[[x]],])) datbind[mv]=trimmed }) # BEAM BREAKS # beam=apply (data.frame (grep("B:",dat)+1,grep("C:",dat)-1),1,function(x) (dat[x[1]:x[2]])) # beam=beam[c(5,6,8,9),] ## UNCOMMENT THE FOLLOWING IF THE MACRO "FR_SCRIPT" WAS USED # Creating index values in order to grab Q: array # qidx=grep("Q:",dat) #Index value of each "Q:" # sidx=c(grep ("Start",dat),length(dat)) #Index value of "Start" # iend=unlist (lapply(as.list (qidx),function (x) (which ((x-sidx)<0))[1])) # Grabbing Q: array, which contains beam breaks beam = apply (data.frame(grep("Q:", dat)+1,grep("Q:", dat)+10),1,function(x) (dat[x[1]:x[2]])) beam = beam[- grep(":", beam),] # beam=apply (data.frame (qidx+1,sidx[iend]-1),1,function(x) (dat[x[1]:x[2]])) beam=beam[c(2,3,4,5),] # TOTAL REWARDS #Added by AL total.reward=apply (data.frame(grep("F:", dat)+1,grep("I:", dat)-1),1,function(x) (dat[x[1]:x[2]])) total.reward=as.integer(total.reward) #COMMENTS # Creating index values in order to grab Comments comidx=grep("Comments:",dat) #Index value of each "Comments:" sidx=c(grep ("Start",dat),length(dat)) #Index value of "Start" comend=unlist (lapply(as.list (comidx),function (x) (which ((x-sidx)<0))[1])) comments=apply(data.frame (comidx+1,sidx[comend]-1),1,function(x) (dat[x[2]])) # CREATING FILES AND CONSOLIDATING INTO 1 POINTER FILE dates=gsub ("/","-",dat[grep("Subject",dat)-4]) # here we get the subject information from the headers subject=paste(dat[grep("Subject:", dat)+1], sep="") #subject number - AL group=paste (dat[grep("Group:",dat)+1],sep="_") #group - AL boxnum=paste ("Box",dat[grep("Box:",dat)+1],sep="") #boxnumber weight=paste (dat[grep("A:",dat)+14],sep="") #weight #boxnum=unlist (lapply (strsplit (paste ("Box",dat[grep("Box:",dat)+1],sep=""),"Box"),function(x) (x[2]))) etype=apply (data.frame (cbind(grep("Experiment:",dat)+1,grep("Group:",dat)-1)),1,function(x) (paste (dat[seq (x[1],x[2])],collapse="_"))) #experiment type msn=apply (data.frame (cbind(grep("MSN:",dat)+1,grep("A:",dat)-1)),1,function(x) (paste (dat[seq (x[1],x[2])],collapse="_"))) #schedule name outnames=seq(1,length(datbind)) #this is for the situation I described where there may be files that do not contain "bad" names # pointer[[q]]=data.frame(id=outnames, subject=subject, etype=etype, group=group,edate=dates, # boxnum=boxnum,weight=weight,iti=timeout,fr=fr, msn=msn,fn=files[q]) if (length(comments) < 1) { pointer[[q]]=data.frame(id=outnames, subject=subject, etype=etype, group=group,edate=dates, boxnum=boxnum,weight=weight,iti=timeout,fr=fr, msn=msn,fn=files[q]) } else {pointer[[q]]=data.frame(id=outnames, subject=subject, etype=etype, group=group,edate=dates, boxnum=boxnum,weight=weight,iti=timeout,fr=fr, msn=msn, comments=comments,fn=files[q])} # use if comments exist # pointer[[q]]=data.frame(id=outnames, subject=subject, etype=etype, group=group,edate=dates, # boxnum=boxnum,weight=weight,iti=timeout,fr=fr, msn=msn, # comments=comments,fn=files[q]) #pointer[[q]]=data.frame(id=outnames, subject=subject, etype=etype, group=group,edate=dates,boxnum=boxnum,weight=weight,iti=timeout,fr=fr, msn=msn,fn=files[q]) filenames=paste (paste(pointer[[q]]$fn,pointer[[q]]$id,sep="_"),".rDat",sep="") pointer[[q]]$sname=filenames #add these file names to pointer so we can readily associate a file name with a specific rat, day and experiment type. pointer[[q]]$active=total.active #added by AL pointer[[q]]$inactive=total.inactive #added by AL pointer[[q]]$reward=total.reward #added by AL pointer[[q]]$weight=weight #added by AL pointer[[q]]$beam1=beam[1,] pointer[[q]]$beam2=beam[2,] pointer[[q]]$beam3=beam[3,] pointer[[q]]$beam4=beam[4,] pointer[[q]]$latency.active=firstA pointer[[q]]$latency.inactive=firstI if (length(comments) > 0) {pointer[[q]]$comments=comments} #this is a custom function to save the data which I apply below. The input is x=newdat[[p]],y=savedir,z=filenames[[p]] save.rFunc=function(x,y,z) ({ save(x,file=paste(y,z,sep="")) return() }) applysave=sapply(seq(1,length(datbind)),function(p) (save.rFunc(datbind[[p]],rdat,filenames[[p]]))) #here I save all the files to your savedir that #you name at the top of the script. #here we save the pointer }) pointer=do.call("rbind",pointer) save(pointer,file=paste(rdat,"pointer.rDAT",sep="")) write.csv(pointer,file=paste(rdat,"pointer_csv.csv",sep="")) # FR PART 2 ---- files=list.files(rdat) load (paste(rdat,"pointer.rDAT",sep="")) #uploading the pointer file full_data_csvname = full_data_csvname datout=data.frame() # Beginning of for loop: x is the rat's data containing abs.time of inactive, active, and reward for (q in (1:nrow(pointer))) ({ current=match(pointer$sname[q],files) load(paste(rdat,files[current],sep="")) ints=findInterval(x$etime,bins) x$int=ints uidx=seq(1,length (unique(bins))-1) # ap= binned active presses, ip=binned inactive presses ap=sapply(uidx,function(p) (length(which(x$int==p & x$etype=="act")))) ip=sapply(uidx,function(p) (length(which(x$int==p & x$etype=="inact")))) rewidx=which(x$etype=="rew") itiend=c(0,as.numeric (x$etime[rewidx]) + pointer$iti[q]) #finding when timeout period ends itiend=itiend[-length(itiend)] atimes=as.numeric (x$etime[which(x$etype=="act")]) #the times at which the active lever was pressed rew=ap fr=pointer$fr[q] firstA=x$etime[which(x$etype=="act")][1] firstI=x$etime[which(x$etype=="inact")][1] nidx=seq (1,length(bins)) binn=sapply(nidx,function(p) (paste(bins[nidx[p]],bins[nidx[p+1]],sep="-"))) #bin size binn=binn[-length(binn)] #Creating bins for each variable of interest (e.g. active, inactive, reward, etc.) an=paste("act",binn,sep="") iAn=paste("inact",binn,sep="") rn=paste("rew",binn,sep="") fla="latency to first active" fli="latency to first inactive" #This is where certain columns from pointer are preserved and filled into a new object called "tofill.final" Add identifiers here -AL tofill.final=c(as.character(pointer$subject[q]), as.character(pointer$etype[q]), as.character(pointer$group[q]), as.character(pointer$boxnum[q]), as.vector(pointer$edate[q]), as.numeric(pointer$weight[q]), pointer$fn[q], pointer$fr[q], as.numeric(pointer$active[q]), as.numeric(pointer$inactive[q]), as.numeric(pointer$reward[q]), as.numeric(pointer$beam1[q]), as.numeric(pointer$beam2[q]), as.numeric(pointer$beam3[q]), as.numeric(pointer$beam4[q]), round (as.numeric (firstA),digits=2), round (as.numeric (firstI),digits=2), ap, ip, rew, as.character(pointer$comments[q])) tofill.final=data.frame (rbind(tofill.final)) if (length(comments) < 1) { outnames=c("subject","e.type","group","boxnum","edate","weight","file name", "fr", "active", "inactive", "reward","beam1", "beam2", "beam3", "beam4", fla,fli,an,iAn,rn) } else {outnames=c("subject","e.type","group","boxnum","edate","weight","file name", "fr", "active", "inactive", "reward","beam1", "beam2", "beam3", "beam4", fla,fli,an,iAn,rn, "comments")} colnames(tofill.final)=outnames datout=rbind(datout,tofill.final) }) #row.names(datout)=seq(1,nrow(datout)) write.csv(datout,file=paste(funcpath,full_data_csvname,sep=""), row.names=F)
})
###########################################################################
# This reads the FR_data output file and rearranges it to a new output
###########################################################################
# rearrange.rFUNC <- function(funcpath) ({ # setwd(funcpath)
# file <- read.csv(full_data_csvname)
# # Installs packages if not already installed
# list.of.packages <- c("tidyverse", "data.table")
# new.packages <-
# list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])]
# # if (length(new.packages)) {
# install.packages(new.packages)}
# # Read Shiny csv
# df <- file
# # Remove binned and unneeded columns
# if("comments" %in% colnames(df)) {
# df <- df[, c("subject", "e.type", "group", "boxnum", "edate", "weight", "fr", # "active", "inactive", "reward", "beam1", "beam2", "beam3", "beam4", # "latency.to.first.active", "latency.to.first.inactive", "comments")]
# } else {
# df <- df[, c("subject", "e.type", "group", "boxnum", "edate", "weight", "fr", # "active", "inactive", "reward", "beam1", "beam2", "beam3", "beam4", # "latency.to.first.active", "latency.to.first.inactive")]}
# # Reorder data and remove unneeded column
# df <- df[order(df$edate, df$subject),]
# # Fix row names
# rownames(df) <- NULL
# # Adjust box comments phrasing
# if("comments" %in% colnames(df)) {
# df$comments <- gsub(".*:", "", df$comments)}
# # Get sum of beam breaks and rearrange/delete columns
# df$beam_breaks <- 0
# for (c in 1:nrow(df)) {
# df[c, "beam_breaks"] <- df[c, "beam1"] + df[c, "beam2"] + df[c, "beam3"] + df[c, "beam4"]}
# # Remove individual beam break columns
# if("comments" %in% colnames(df)) {
# df <- df[, c("subject", "e.type", "group", "boxnum", "edate", "weight", "fr", # "active", "inactive", "reward", "latency.to.first.active", "latency.to.first.inactive",
# "comments", "beam_breaks")]
# } else {df <- df[, c("subject", "e.type", "group", "boxnum", "edate", "weight", "fr", # "active", "inactive", "reward", "latency.to.first.active", # "latency.to.first.inactive", "beam_breaks")]}
# # Get session numbers from the date column
# df <- transform(df,session = as.numeric(factor(edate)))
# # Remove edate and e.type columns
# if("comments" %in% colnames(df)) {
# df <- df[, c("subject", "group", "boxnum", "weight", "fr", "active", "inactive", "reward", # "latency.to.first.active", "latency.to.first.inactive", "comments", "beam_breaks",
# "session")]
# } else {df <- df[, c("subject", "group", "boxnum", "weight", "fr", "active", "inactive", "reward", # "latency.to.first.active", "latency.to.first.inactive", "beam_breaks",
# "session")]}
# # Translate comment numbers to words # library(data.table)
# if("comments" %in% colnames(df)) {
# for (c in 1:nrow(df)) {
# if (df[c, "comments"] %like% 00) {df[c, "comments"] = gsub("00", "misc", df[c, "comments"])}
# if (df[c, "comments"] %like% 01) {df[c, "comments"] = gsub("01", "exclude", df[c, "comments"])}
# if (df[c, "comments"] %like% 02) {df[c, "comments"] = gsub("02", "leak", df[c, "comments"])}
# if (df[c, "comments"] %like% 03) {df[c, "comments"] = gsub("03", "syringe", df[c, "comments"])}
# if (df[c, "comments"] %like% 04) {df[c, "comments"] = gsub("04", "wounded", df[c, "comments"])}
# if (df[c, "comments"] %like% 05) {df[c, "comments"] = gsub("05", "sick", df[c, "comments"])}
# if (df[c, "comments"] %like% 06) {df[c, "comments"] = gsub("06", "chewed", df[c, "comments"])}
# if (df[c, "comments"] %like% 07) {df[c, "comments"] = gsub("07", "cath issue", df[c, "comments"])}
# if (df[c, "comments"] %like% 08) {df[c, "comments"] = gsub("08", "hardware issue", df[c, "comments"])}
# if (df[c, "comments"] %like% 09) {df[c, "comments"] = gsub("09", "fire alarm", df[c, "comments"])}
# if (df[c, "comments"] %like% 10) {df[c, "comments"] = gsub("10", "escaped", df[c, "comments"])}
# if (df[c, "comments"] %like% 11) {df[c, "comments"] = gsub("11", "death", df[c, "comments"])}
# if (df[c, "comments"] %like% 12) {df[c, "comments"] = gsub("12", "software issue", df[c, "comments"])}
# if (df[c, "comments"] %like% 13) {df[c, "comments"] = gsub("13", "shielded", df[c, "comments"])}
# if (df[c, "comments"] %like% 14) {df[c, "comments"] = gsub("14", "autoshaped", df[c, "comments"])}
# if (df[c, "comments"] %like% 15) {df[c, "comments"] = gsub("15", "off tubing", df[c, "comments"])}
# }
# }
# head(df)
# # Make Beam Break rows to NA if the number is below 100
# # This is a fail safe in case the nose poke holes register as beam breaks
# for (c in 1:nrow(df)) {
# if (df[c, "beam_breaks"] < 100) {df[c, "beam_breaks"] = NA}
# }
# # # Tranform data set from long to wide format by session number
# library(tidyverse)
# if("comments" %in% colnames(df)) {
# df$weight <- as.numeric(df$weight)
# df <- df %>% # pivot_wider(names_from = session,
# values_from=c(weight, active, inactive, reward, beam_breaks, # latency.to.first.active, latency.to.first.inactive, comments))
# } else {df <- df %>% # pivot_wider(names_from = session,
# values_from=c(weight, active, inactive, reward, beam_breaks, # latency.to.first.active, latency.to.first.inactive))}
# # Change class of columns and remove NA values
# df <- as.data.frame(df)
# df <- sapply(df, as.character)
# df[df == "#N/A"] <- NA
# df[is.na(df)] <- " "
# # df <- df[, colSums(df != 0) > 0]
# # # # Write csv file to the working directory
# write.csv(df,file=paste(funcpath,SA_rearrangement_csvname,sep=""), row.names=FALSE)
# # write.csv(df, "SA_rearrangement_output.csv", row.names = FALSE)
# }) # fr_summary.rFUNC(wd, funcpath)
#----------------------------------------
# SHINY PRELIMINARY SCRIPT ----
#Created by Annie Ly and James Callens
# shiny.rFUNC <- function(funcpath) {
# rsconnect::setAccountInfo(name='hurd-laboratory',
# credential placeholder redacted,
# secret='j0ilSenal+/AgEXhXDN9VQAFrqVnwcO4fKpRECpY') # # LOADING LIBRARIES ----
# library(plyr)
# library(lubridate)
# library(DT)
# library(lme4)
# library(car)
# library(stringr)
# library(readr)
# # library(xlsx)
# library(data.table)
# library(ggplot2)
# library(shiny)
# library(forcats)
# library(purrr)
# library(tidyr)
# library(emmeans)
# library(shinydashboard)
# library(shinydashboardPlus)
# library(shinycssloaders)
# library(shinyjs)
# library(openxlsx)
# library(dplyr) #ALWAYS LOAD DPLYR LAST; OTHERWISE IT WILL MASK FUNCTIONS FROM OTHER PACKAGES
# # # # FUNCTIONS ----
# #This is a function I created to generate mean, SD, and SE from a "data" for a "varname" based on "groupnames"
# data_summary <- function(data, varname, groupnames){
# summary_func <- function(x, col){
# c(mean = mean(x[[col]], na.rm=TRUE),
# sd = sd(x[[col]], na.rm=TRUE),
# se = sd(x[[col]], na.rm=TRUE)/sqrt(length(x[[col]])))
# }
# data_sum<-ddply(data, groupnames, .fun=summary_func,
# varname)
# data_sum <- plyr::rename(data_sum, c(varname="mean"))
# return(data_sum)
# }
# # #This is a function I created to generate sessions for each rat
# session_count<-function(df) {
# seq(1, nrow(df), by=1)
# }
# # # ALL PRELIMINARY DATA CLEANING ----
# FR_data <- read.csv(file="FR_data.csv") # FR_data_raw <- read.csv(file="FR_data.csv") # FR_data$fr<- as.character(FR_data$fr)
# FR_data$comments<- as.character(FR_data$comments)
# # #UNCOMMENT THE FOLLOWING WHEN COMBINING FR AND PR DATA
# #PR_data <- read.csv(file="PR_data.csv")
# #PR_data$fr<- as.character(PR_data$fr)
# #FR_data<- rbind.fill(FR_data,PR_data)
# # FR_data$fr<- factor(FR_data$fr, levels=c("1","5"))
# # FR_data <- plyr::mutate(FR_data, activity=beam1+beam2+beam3+beam4) # FR_data <- mutate(FR_data, percent.active=active/(active+inactive)) # FR_data <- mutate(FR_data, percent.inactive=inactive/(active+inactive)) # # FR_data$edate<-mdy(FR_data$edate) # # FR_data$subject<- as.factor(FR_data$subject)
# FR_data$subject<-fct_inorder(FR_data$subject) # FR_data<- as.data.table(FR_data) # FR_data<- FR_data[order(FR_data$edate),] # FR_data<-FR_data %>% group_by(subject)%>% nest() # FR_data<-FR_data %>% mutate(session=map(data,session_count))
# FR_data<-FR_data %>% unnest()
# FR_data<-with(FR_data, FR_data[order(session),]) # # # TRIAL AND TIMEOUT ACTIVES
# # for (q in (1:nrow(FR_data))) ({
# if (FR_data$fr[q]==1) ({
# FR_data$trial.active[q]=FR_data$reward[q]
# FR_data$timeout.active[q]=FR_data$active[q]-FR_data$trial.active[q]
# }) # if (FR_data$fr[q]==5) ({
# FR_data$trial.active[q]=FR_data$reward[q]*5
# FR_data$timeout.active[q]=FR_data$active[q]-FR_data$trial.active[q]
# })
# if (FR_data$fr[q]=="pr") ({
# FR_data$trial.active[q]=FR_data$active[q]-FR_data$timeout.active[q]
# FR_data$timeout.active[q]=FR_data$timeout.active[q]
# })
# # })
# # FR_data<- FR_data %>% filter(str_detect(comments, "01")==FALSE)
# FR_data <- FR_data %>% filter(str_detect(comments, "reinstatement")==FALSE)
# # # # SHINY UI HTML ----
# options(contrasts=c("contr.sum", "contr.poly"))
# appCSS <- "#loading-content {position: absolute; background: #000000; opacity: 0.8; z-index: 100; left: 0; right: 0; height: 100%; text-align: center; color: #FFFFFF;}"
# # #----------------------------------------
# # SHINY UI script ----
# #Created by Annie Ly James Callens
# # ui = shinyUI({fluidPage(
# # dashboardPage(
# # Dashboard Header Beginning ----
# dashboardHeader(title = 'Hurd Laboratory', # tags$li(class = 'dropdown', # style = 'width: 1550px; height: 0px; padding: 0px')
# ), # # Dashboard Sidebar Beginning ----
# dashboardSidebar(
# # width = 273.5,
# # sidebarMenuOutput("Semi_collapsible_sidebar"),
# #fluidRow Beginning (sidebar widgets are here) ----
# fluidRow(
# align = "center",
# br(),
# tags$a(href = 'https://www.mountsinai.org', style = 'height: 0px; padding: 0px'), # tags$img(src = 'mountsinai.png', style = 'height: 100px; width: 200px'), # br(),
# br(),
# br(),
# "The following dropdown menu for",
# br(),
# "'Y Variable' toggles the plots on", # br(),
# "the 'Main Plot', 'Subjects', and",
# br(),
# "'Univariate Plots' tabs.",
# br(),
# selectInput("y", "Y Variable", # choices = c("active", "inactive","percent.active", "percent.inactive", "reward", "activity"),
# multiple = FALSE,
# selected = "active"),
# #downloadButton("downloadplot","Download Plot"), # br(),
# radioButtons(inputId = "filetype",
# label = "Select filetype:",
# choices = c("csv", "tsv", "xlsx"),
# selected = "csv"),
# HTML("Select filetype, then 'Download Data'"),
# br(),
# downloadButton("downloaddata", "Download Data"))),
# # # Dashboard Body Beginning ----
# dashboardBody(
# style = "overflow-x: scroll",
# fluidRow(
# align = "center",
# div(id = "loading-content", h2("Loading...")),
# # mainPanel Beginning ----
# mainPanel(
# style = "width: 100%",
# # tabsetPanel Beginning ----
# tabsetPanel(type = "tabs",
# # "Master Data" tab (@masterdata) ----
# tabPanel(tags$b("Master Data"),
# br(),
# DT::dataTableOutput("master.data"), style = "height: auto !important; overflow-y: scroll; overflow-x: scroll;"),
# # "Main Plot" tab (@mainplot) ----
# tabPanel(tags$b("Main Plot"),
# br(),
# box(width=12,
# title= "Y Variable by Sessions", solidHeader = TRUE, # plotOutput("plot") %>% withSpinner(color="#0dc5c1")),
# box(width=12,
# title="Session Input", solidHeader=TRUE,
# sliderInput("session", "Sessions", # min(FR_data$session), max(FR_data$session),
# value = c(1, 40),
# step=1)),
# box(width=12,
# title= "Y Variable Data Summary by Sessions", solidHeader=TRUE,
# DT::dataTableOutput("table"), style = "height: auto !important; overflow-y: scroll; overflow-x: scroll;")),
# # "Subjects" tab (@subjects) ----
# tabPanel(tags$b("Subjects"), # br(),
# box(width=12,
# title="Individual subjects from saline group",
# plotOutput("plot2", height="1000px") %>% withSpinner(color="#0dc5c1")),
# box(width=12,
# title="Individual subjects from heroin group",
# plotOutput("plot3", height="1000px") %>% withSpinner(color="#0dc5c1"))),
# # "Univariate Plots" tab (@univariate) ----
# tabPanel(tags$b("Univariate Plots"),
# br(),
# fluidRow(box(width=12,
# title="Observation and Exclusion", # "*Hover on a data point to see a subject's self-administration performance.",
# br(),
# "*Click on a data point to exclude a subject from the boxplot.",
# br(),
# "*Brush (i.e. click and drag) over multiple data points and click the 'Exclude Brush Points' button to exclude multiple data points.",
# br(),
# "Exclusions are reflected in the analysis tabs.",
# br(),
# "When a subject's inactive/active lever press is excluded, the entire session data are excluded.",
# br(),
# "As a result, a subject's 'last 3 sessions' are always re-calibrated.",
# br(),
# br(),
# actionButton("exclude_toggle", "Exclude Brushed Points"),
# actionButton("exclude_reset", "Reset Graphs"))),
# box(width=12,
# title="Box plots by session for saline group",
# plotOutput("plot4", click = "plot_click1", brush = brushOpts(id = "plot_brush1"), hover = hoverOpts("plot_hover1"))),
# box(width=12,
# title="HoverPoint Info for saline group",
# verbatimTextOutput("hover_info1")),
# box(width=12,
# title="Box plots by session for heroin group",
# plotOutput("plot5", click = "plot_click2", brush = brushOpts(id = "plot_brush2"), hover = hoverOpts("plot_hover2"))),
# box(width=12,
# title="HoverPoint Info for heroin group",
# verbatimTextOutput("hover_info2"))),
# # "Analysis of Variance" (@anova) tab ----
# tabPanel(tags$b("Analysis of Variance"),
# br(),
# box(width=12,
# title="Information",
# "*These are repeated measures of variance analysis using a linear mixed-effects model (LMM) across all sessions.",
# br(),
# "Individual subjects variability is annotated as a random effect.",
# br(),
# "An ANOVA using LMM can be conducted when the data have met two primary assumptions:",
# br(),
# "1)The assumption of normality - in which you can check with the univariate plots.",
# br(),
# "2)The assumption of homoscedasticity - in which you can check with the residual plots."),
# box(width=6,
# title="Q-Q Plot",
# plotOutput("residualplot1") %>% withSpinner(color="#0dc5c1")),
# box(width=6,
# title="Residuals by Group",
# plotOutput("residualplot2") %>% withSpinner(color="#0dc5c1")),
# box(width=6,
# title="Analysis of Deviance Table (Type II Wald chisquare tests)",
# verbatimTextOutput("stats_wald2")),
# box(width=6,
# title="Analysis of Deviance Table (Type III Wald chisquare tests)",
# verbatimTextOutput("stats_wald3")),
# box(width=12,
# title="Plot of Estimated Means",
# plotOutput("int_plot") %>% withSpinner(color="#0dc5c1")),
# box(width=6,
# title="TukeyHSD PostHoc Analysis",
# verbatimTextOutput("stats_tukey")),
# box(width=6,
# title="Interaction Analysis",
# verbatimTextOutput("contrasts1"))),
# # "Last 3 sessions Analysis" tab (@last3) ----
# tabPanel(tags$b("Last 3 sessions Analysis"), # br(),
# box(width=12,
# title="Information",
# "*These are repeated measures of variance analysis using a linear mixed-effects model (LMM) across the last 3 sessions.",
# br(),
# "Individual subjects nested within session is annotated as a random effect.",
# br(),
# "An ANOVA using LMM can be conducted when the data have met two primary assumptions:",
# br(),
# "1)The assumption of normality - in which you can check with the univariate plots.",
# br(),
# "2)The assumption of homoscedasticity - in which you can check with the residual plots."),
# box(width=6,
# title="Q-Q Plot",
# plotOutput("residualplot3") %>% withSpinner(color="#0dc5c1")),
# box(width=6,
# title="Residuals by Group",
# plotOutput("residualplot4") %>% withSpinner(color="#0dc5c1")),
# box(width=6,
# title="Analysis of Deviance Table (Type II Wald chisquare tests)",
# verbatimTextOutput("last3sessions_anova2")),
# box(width=6,
# title="Analysis of Deviance Table (Type III Wald chisquare tests)",
# verbatimTextOutput("last3sessions_anova3")),
# box(width=12,
# title="Plot of Estimated Means",
# plotOutput("int_plot2") %>% withSpinner(color="#0dc5c1")),
# box(width=6,
# title="TukeyHSD PostHoc Analysis",
# verbatimTextOutput("stats_tukey2")),
# box(width=6,
# title="Interaction Analysis",
# verbatimTextOutput("contrasts2")))
# # ) #tabsetPanel Ending ----
# ) #mainPanel Ending ----
# # ), #fluidRow Ending ----
# # # HTML CODE ---- # tags$head(tags$style(HTML('.wrapper {height: auto !important; position: relative;}'))),
# tags$style(HTML(".skin-blue .main-header .navbar {border-width: thin; border-bottom-style: solid; border-right-style: solid; # border-color: #00002D; background-color: #06ABEB; color: white; border-left-style: solid;}")),
# tags$style(HTML(".skin-blue .main-header .navbar .sidebar-toggle {background-color: #06ABEB; color:black; border-right-style: solid; border-width: thin;}")),
# tags$style(HTML(".skin-blue .main-header .navbar .sidebar-toggle:hover {background-color: white; color:black;}")),
# tags$style(HTML(".skin-blue .main-header .logo {background-color: #06ABEB; color:black;}")),
# tags$style(HTML(".skin-blue > .main-header > logo:hover {background-color: #06ABEB; color:black;}")),
# tags$style(HTML(".irs-bar {background-color: #06ABEB;}")),
# tags$style(HTML(".skin-blue .main-sidebar {background-color: #00002D; border-color: #00002D; border-style: solid; border-width: thin;}")),
# tags$style(HTML(".tabbable > .nav > li > a {background-color: #DC298D; color:white; border-color: #212070; border-style: solid; border-width: thin;}")),
# tags$style(HTML(".tabbable > .nav > li > a:hover {background-color: white; color:black; border-color: #212070; border-style: solid; border-width: thin;}"))
# # ) # Dashboard Body Ending ----
# ), # Dashboard Page Ending ----
# # #use java script for loading page icon
# useShinyjs(),
# #reference loading page icon # inlineCSS(appCSS)
# # ) #fluid page Ending ----
# }) #shiny UI Ending ----
# # #----------------------------------------
# # SHINY SERVER SCRIPT ----
# #Created by Annie Ly and James Callens
# # server = function(input, output)({
# group_1 = c("saline")
# group_2 = c("heroin")
# # #----------------------------------------
# # Reactive data sets ---- # reactive.data1 <- reactive({
# data<- data_summary(FR_data, varname=input$y, groupnames=c("session", "group", "fr"))
# subset(data,
# session >= input$session[1] & session <=input$session[2])
# }) #@mainplot
# # reactive.data3<- reactive({
# subset(FR_data, group==group_1)
# }) #@subjects
# # reactive.data4<- reactive({
# subset(FR_data, group==group_2)
# }) #@subjects
# # reactive.data6<- reactive({
# select(FR_data, subject, session, group, boxnum, fr, active, inactive, reward) %>% subset(group==group_1)
# }) #@univariate
# # reactive.data7<- reactive({
# select(FR_data, subject, session, group, boxnum, fr, active, inactive, reward) %>% subset(group==group_2)
# }) #@univariate
# # reactive.data9<- reactive({
# keep4 <- subset(FR_data, group==group_1)[ vals4$keeprows4, , drop = FALSE]
# keep5 <- subset(FR_data, group==group_2)[ vals5$keeprows5, , drop = FALSE]
# exclude_final<-rbind(keep4,keep5)
# level1_9<-tidyr::gather(exclude_final, lever, presses, c(active, inactive)) # level1_9<-with(level1_9, level1_9[order(session, subject),])
# }) #@anova
# # reactive.data10<- reactive({
# lmer(presses ~ session*lever*group + (1|subject), data=reactive.data9())
# }) #@anova
# # reactive.data13<- reactive({
# keep4 <- subset(FR_data, group==group_1)[ vals4$keeprows4, , drop = FALSE]
# keep5 <- subset(FR_data, group==group_2)[ vals5$keeprows5, , drop = FALSE]
# exclude_final<-rbind(keep4,keep5)
# level1_9<-tidyr::gather(exclude_final, lever, presses, c(active, inactive)) # level1_9<-with(level1_9, level1_9[order(session, subject),])
# level1_9$session<- factor(level1_9$session)
# return(level1_9)
# }) #@anova
# # reactive.data14<- reactive({
# lmer(presses ~ session*lever*group + (1|subject), data=reactive.data13())
# }) #@anova
# # reactive.data16<- reactive({
# keep4 <- subset(FR_data, group==group_1)[ vals4$keeprows4, , drop = FALSE]
# keep5 <- subset(FR_data, group==group_2)[ vals5$keeprows5, , drop = FALSE]
# exclude_final<-rbind(keep4,keep5)
# level1_9<-tidyr::gather(exclude_final, lever, presses, c(active, inactive)) # level1_9<-with(level1_9, level1_9[order(session, subject),])
# data15_1<-unite(level1_9, session, lever, col="session_lever", sep="_")
# data15_1<-dplyr::select(data15_1, subject, group, session_lever, presses)
# data15_1$session_lever<-data15_1$session_lever %>% factor() %>% fct_inorder()
# data16_1<-spread(data15_1, session_lever, presses)
# group<- data16_1$group
# subject<- data16_1$subject
# data16_1$group<-NULL
# data16_1$subject<-NULL
# data16_1<-t(apply(data16_1, 1, function(x) c(x[is.na(x)], x[!is.na(x)])))
# data16_1<-data16_1[,apply(data16_1, 2, function(x) !any(is.na(x)))]
# data16_1<-data16_1[,(ncol(data16_1)-5):ncol(data16_1)]
# colnames(data16_1)<-c("x_active", "x_inactive", "y_active", "y_inactive", "z_active", "z_inactive")
# data16_1<-as.data.frame(data16_1)
# data16_1<- cbind(subject, group, data16_1)
# data16_1<- gather(data16_1, "session_lever", "presses", x_active:z_inactive)
# data16_1<- separate(data16_1, session_lever, c("session", "lever"), sep="_")
# data16_1$presses<- as.numeric(data16_1$presses)
# return(data16_1)
# }) #@last3
# # reactive.data12<- reactive({
# lmer(presses ~ session*lever*group + (session|subject), data=reactive.data16())
# }) #@last3
# # vals4 <- reactiveValues(
# keeprows4 = rep(TRUE, nrow(subset(FR_data, group==group_1)))
# ) #@univariate
# # vals5 <- reactiveValues(
# keeprows5 = rep(TRUE, nrow(subset(FR_data, group==group_2)))
# ) #@univariate
# # download.plot<- reactive({
# ggplot(reactive.data1(), aes(x=session, y= mean, group = interaction(group), color=interaction(group))) + # geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.1, position=position_dodge(0.05)) +
# geom_point(aes(shape=fr), size = 5) +
# geom_line(aes(linetype=interaction(group)), size=1) + # ggtitle(input$title) +
# ylab(input$y) +
# theme_classic()
# })
# # #---------------------------------------- # # Plots ----
# # output$plot<- renderPlot({
# ggplot(reactive.data1(), aes(x=session, y= mean, group = interaction(group), color=interaction(group))) + # geom_errorbar(aes(ymin=mean-se, ymax=mean+se), width=.05, size=1) +
# geom_point(aes(shape=fr), size = 5) +
# geom_line(aes(linetype=interaction(group)), size=2) +
# ggtitle(input$title) +
# ylab(input$y) +
# scale_shape_discrete(name="FR Ratio Schedule") +
# theme_classic() +
# theme(axis.title.x = element_text(size=20, face="bold"),
# axis.title.y = element_text(size=20, face="bold"), # axis.text = element_text(size = 20, face="bold"),
# axis.line = element_line(size = 1)) # }) #@mainplot
# # output$plot2<- renderPlot({
# ggplot(reactive.data3(), aes_string(y=input$y, x="session", group = "group", color="group")) +
# geom_line() +
# geom_point(aes(shape=fr), size=3) + # facet_wrap(~ subject) +
# scale_shape_discrete(name="FR Ratio Schedule") +
# theme_bw() +
# theme(axis.title.x = element_text(size=20, face="bold"),
# axis.title.y = element_text(size=20, face="bold"), # axis.text = element_text(size = 20, face="bold"),
# axis.line = element_line(size = 1)) # }, height=1000) #@subjects
# # output$plot3<- renderPlot({
# ggplot(reactive.data4(), aes_string(y=input$y, x="session", group = "group", color="group")) +
# geom_line() +
# geom_point(aes(shape=fr), size=3) + # facet_wrap(~ subject) +
# scale_shape_discrete(name="FR Ratio Schedule") +
# theme_bw() +
# theme(axis.title.x = element_text(size=20, face="bold"),
# axis.title.y = element_text(size=20, face="bold"), # axis.text = element_text(size = 20, face="bold"),
# axis.line = element_line(size = 1)) # }, height=1000) #@subjects
# # output$plot4<- renderPlot({
# keep4 <- subset(FR_data, group==group_1)[ vals4$keeprows4, , drop = FALSE]
# exclude4 <- subset(FR_data, group==group_1)[!vals4$keeprows4, , drop = FALSE]
# ggplot(keep4, aes_string(y=input$y, x="session")) +
# geom_boxplot(aes(fill=factor(session))) +
# geom_point() +
# labs(y=input$y, x="session") +
# theme_bw() +
# theme(axis.title.x = element_text(size=20, face="bold"),
# axis.title.y = element_text(size=20, face="bold"), # axis.text = element_text(size = 20, face="bold"),
# axis.line = element_line(size = 1)) # }) #@univariate
# # output$plot5<- renderPlot({
# keep5 <- subset(FR_data, group==group_2)[ vals5$keeprows5, , drop = FALSE]
# exclude5 <- subset(FR_data, group==group_2)[!vals5$keeprows5, , drop = FALSE]
# ggplot(keep5, aes_string(y=input$y, x="session")) + # geom_boxplot(aes(fill=factor(session))) +
# geom_point() +
# labs(y=input$y, x="session") +
# theme_bw() +
# theme(axis.title.x = element_text(size=20, face="bold"),
# axis.title.y = element_text(size=20, face="bold"), # axis.text = element_text(size = 20, face="bold"),
# axis.line = element_line(size = 1)) # }) #@univariate
# # output$int_plot<- renderPlot({
# emmip(reactive.data14(), group ~ session | lever)
# }) #@anova
# # output$residualplot1<- renderPlot({
# qqnorm(residuals(reactive.data10()))
# qqline(residuals(reactive.data10()))
# }) #@anova
# # output$residualplot2<- renderPlot({
# plot(reactive.data10(), resid(., scaled=TRUE) ~ presses | group)
# }) #@anova
# # output$int_plot2<- renderPlot({
# emmip(reactive.data12(), group ~ session | lever)
# }) #@last3
# # output$residualplot3<- renderPlot({
# qqnorm(residuals(reactive.data12()))
# qqline(residuals(reactive.data12()))
# }) #@last3
# # output$residualplot4<- renderPlot({
# plot(reactive.data12(), resid(., scaled=TRUE) ~ presses | group)
# }) #@last3
# # #---------------------------------------- # # Render Prints ----
# # output$hover_info1<- renderPrint({
# nearPoints(reactive.data6(), input$plot_hover1, xvar = "session", yvar = input$y)
# }) #@univariate
# # output$hover_info2<- renderPrint({
# nearPoints(reactive.data7(), input$plot_hover2, xvar = "session", yvar = input$y)
# }) #@univariate
# # output$stats_wald2<-renderPrint({
# Anova(lmer(presses ~ session*lever*group + (1|subject), data=reactive.data9()), type=2)
# }) #@anova
# # output$stats_wald3<-renderPrint({
# Anova(lmer(presses ~ session*lever*group + (1|subject), data=reactive.data9()), type=3)
# }) #@anova
# # output$stats_tukey<-renderPrint({
# TukeyHSD(x=aov(presses ~ group + lever, data=reactive.data9()), conf.level=0.95)
# }) #@anova
# # output$contrasts1<- renderPrint({
# emmeans(reactive.data10(), pairwise ~ lever + group)
# }) #@anova # # output$last3sessions_anova3<-renderPrint({
# Anova(lmer(presses ~ session*lever*group + (session|subject), data=reactive.data16()), type=3)
# }) #@last3
# # output$last3sessions_anova2<-renderPrint({
# Anova(lmer(presses ~ session*lever*group + (session|subject), data=reactive.data16()), type=2)
# }) #@last3
# # output$stats_tukey2<-renderPrint({
# TukeyHSD(x=aov(presses ~ group + lever, data=reactive.data16()), conf.level=0.95)
# }) #@last3
# # output$contrasts2<- renderPrint({
# emmeans(reactive.data12(), pairwise ~ lever + group)
# }) #@last3
# # #---------------------------------------- # # Render Tables ----
# # output$master.data<- DT::renderDataTable({
# datatable(FR_data, filter='top', options=list(pagelength=25), class = 'cell-border stripe')
# }) #@masterdata
# # output$table<- DT::renderDataTable({
# datatable(reactive.data1(), filter='top', options=list(pagelength=25), class = 'cell-border stripe')
# }) #@mainplot # # #---------------------------------------- # # Download Handlers ----
# output$downloadplot<- downloadHandler(
# filename = function() { paste(input$y, '.png', sep = '')},
# content = function(file) {
# ggsave(file, plot=download.plot(), device="png")
# })
# # output$downloaddata<- downloadHandler(
# filename = function(){ paste0("data.", input$filetype, sep = '')},
# content = function(file){
# if(input$filetype == "csv"){ # write_csv(FR_data_raw, file) # }
# if(input$filetype == "tsv"){ # write_tsv(FR_data_raw, file) # }
# if(input$filetype =="xlsx"){
# write.xlsx(FR_data_raw, file)
# }
# })
# # output$downloaddata2<- downloadHandler(
# filename = function(){ paste0("data.", input$filetype, sep = '')},
# content = function(file){
# if(input$filetype == "csv"){ # write_csv(FR_data, file) # }
# if(input$filetype == "tsv"){ # write_tsv(FR_data, file) # }
# if(input$filetype =="xlsx"){
# write.xlsx(FR_data, file)
# }
# })
# # # # #---------------------------------------- # # Toggle points that are clicked ----
# # observeEvent(input$plot_click1, {
# res4 <- nearPoints(subset(FR_data, group==group_1), input$plot_click1, allRows = TRUE)
# vals4$keeprows4 <- xor(vals4$keeprows4, res4$selected_)
# }) #@univariate
# # observeEvent(input$plot_click2, {
# res5 <- nearPoints(subset(FR_data, group==group_2), input$plot_click2, allRows = TRUE)
# vals5$keeprows5 <- xor(vals5$keeprows5, res5$selected_)
# }) #@univariate
# # # #---------------------------------------- # # Toggle points that are brushed, when button is clicked ----
# observeEvent(input$exclude_toggle, {
# res4 <- brushedPoints(subset(FR_data, group==group_1), input$plot_brush1, allRows = TRUE)
# vals4$keeprows4 <- xor(vals4$keeprows4, res4$selected_)
# # res5 <- brushedPoints(subset(FR_data, group==group_2), input$plot_brush2, allRows = TRUE)
# vals5$keeprows5 <- xor(vals5$keeprows5, res5$selected_)
# }) #@univariate
# # #---------------------------------------- # # Reset all toggle points ----
# observeEvent(input$exclude_reset, {
# vals4$keeprows4 <- rep(TRUE, nrow(subset(FR_data, group==group_1)))
# vals5$keeprows5 <- rep(TRUE, nrow(subset(FR_data, group==group_2)))
# }) #@univariate
# # hide(id = "loading-content", anim = TRUE, animType = "fade")
# # })
# # shinyApp(ui = ui,server = server)
# }
#---- 