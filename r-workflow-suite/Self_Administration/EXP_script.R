
#CHANGING PARAMETERS ----
wd = "C:/Users/PC/Desktop/SA_files/rawdata/" #RAW FILE FOLDER. MUST ONLY CONTAIN YOUR RAW FILES. NEED "/" AT LOCATION END.
funcpath ="C:/Users/PC/Desktop/SA_files/" #"app.R" FOLDER. NEED "/" AT LOCATION END.
deploy ="C:/Users/PC/Desktop/SA_files" #"app.R" FOLDER. FOR SHINY DEPLOYMENT. NO "/" AT LOCATION END.
experiment = "fr" #CHOOSE ONE OF THE FOLLOWING: "fr", "pr", "of", "split_xl_to_csv", "clear_workspace"
full_data_csvname = "FR_data.csv"
SA_rearrangement_csvname_asterisk_exclude = "SA_rearrangement_asterisk_exclude.csv"
SA_rearrangement_csvname_blank_exclude = "SA_rearrangement_blank_exclude.csv"
SA_rearrangement_csvname = "rearranged_data.csv"
#-------------------------------------------------------------------------------------
#SELECTIVE PARAMETERS ----
binl=600 #CHANGE FOR FR & PR TO BIN SESSION IN SECONDS.
bins=seq(0,10800,binl) #CHANGE FOR FR & PR FOR TOTAL SESSION LENTGH IN SECONDS.
savePDF="no" #FOR OPEN FIELD. WRITE "yes" OR "no". "yes" TAKES MUCH LONGER TO PROCESS.
saveHeatMap="no" #FOR OPEN FIELD. WRITE "yes" OR "no". "yes" TAKES MUCH LONGER TO PROCESS.
#----------------------------------------
#DON'T CHANGE THIS SECTION ----
setwd(wd) # set working directory to raw data
if (file.exists("./rdata")) {unlink("./rdata", recursive = TRUE)} # removes the rdata folder
source(paste(funcpath,"master_script.R",sep=""),local=TRUE) #sCRIPT sOURCE. IGNORE "ERROR" WHEN RUN.
experiment_selection(wd) #REFERS TO EXPERIMENT ABOVE AND SELECTS WHICH SCRIPT FUNCTION TO RUN.
#----------------------------------------
#DEPLOYMENT OF SHINY APPLICATION TO SHINYAPPS.IO WEBSITE (REMOVE "#" TO RUN) ----
setwd(funcpath) # set working directory to shiny script
source(paste(funcpath,"app.R",sep=""),local=TRUE) # the script for the shiny
options(rsconnect.check.certificate = FALSE) # this bypasses a certificate check to reupload to the website
library(rsconnect)
rsconnect::deployApp(appDir = deploy, account = 'hurd-laboratory', appTitle = "jerfeb14") # deploy the shiny app
y 