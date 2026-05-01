# These samples differ based on region and gene, so those variables are stored in vars
# Use the vars variable to define your different conditions
# Note that they are input in the order they appear in the plate layout.
# CHANGE VARIABLE NAMES!
working_directory <- "C:/Users/PC/Desktop/jeremy/"
vars <- c("region", "lab")
vars2_grouping <- c(2) #this is for the summary and groups by region. If more columns are needed, go to lines # 157, 161, and 165 and change the "vars2" to the columns you would like.
GOI_file <- "211028_JDS_Belin2Cohort_Fyn_FAM.txt" #Import txt file from lightcycler for gene of interest
HKG_file <- "211028_JDS_Belin2Cohort_B2M_VIC.txt" #Import txt file from lightcycler for housekeeping gene
plate_layout_file <- "211028_Fyn_bothcohorts_allDS_qPCR_plate_layout.xlsx" #import plate layout
csv_save_name <- "Fyn_2Cohorts_DS_qpcr_data_exclude1aDS.csv"
exclude_threshold <- 35
replicate_difference_threshold <- 1.5
vehicle_group <- "suc"
experimental_group1 <- "FR1"
experimental_group2 <- "LC"
experimental_group3 <- "HC"
experimental_group4 <- NA
experimental_group5 <- NA
condition1 <- c("aDLS_Hrh2")
condition2 <- c("aDMS_Hrh2")
condition3 <- c("pDLS_Hrh2")
condition4 <- c("pDMS_Hrh2")
condition5 <- c("NA")
experiment_level_analysis <- c(vehicle_group, experimental_group1,experimental_group2, experimental_group3) # ------------------------------------
# options(warn = -1) #turn off warnings
# update.packages(ask = FALSE) # Remove firstthe pound sign if you would like to update your packages
# list.of.packages = c("readxl", "dplyr", "tidyr", "ggplot2", "ggpubr", "reshape2", "purrr")
# new.packages = list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
# if(length(new.packages)) install.packages(new.packages) library(readxl)
library(tidyr)
library(ggplot2)
library(ggpubr)
library(reshape2)
library(dplyr)
library(purrr) setwd(working_directory)
# options(warn = -1) # These commands read in the data directly from the lightcycler table .txt file format.
# For Taqman you will get a separate file for your genes of interests (GOI) (FAM channel)
# and the house keeping gene (HKG)(VIC channel)
# CHANGE FILE NAMES!
rawGOI <- read.table(GOI_file, sep = "\t", skip = 1, header = TRUE)
rawHKG <- read.table(HKG_file, sep = "\t", skip = 1, header = TRUE) # Load the ids based on plate position from the plate layout document
# cHANGE FILE NAME!
Posid <- read_excel(plate_layout_file, sheet = "Posid") # Make a table with ID, GOI cp, HKG cp
# Remove all other columns from raw lightcycler data
GOIcps <- select(rawGOI, c("Pos", "Cp"))
GOIcps <- GOIcps %>% rename(GOIcp = Cp)
HKGcps <- select(rawHKG, c("Pos", "Cp"))
HKGcps <- HKGcps %>% rename(HKGcp = Cp)
CPs <- left_join(GOIcps, HKGcps)
CPs <- left_join(CPs, Posid)
CPs <- CPs[order(CPs$ID),] # Remove NAs
CPs <- na.omit(CPs) # only select values that are below 35
CPs <- subset(CPs, GOIcp < exclude_threshold & HKGcp < exclude_threshold) # ------------------------------------
df1 <- as.data.frame(CPs %>% mutate(row = row_number()) %>% #mutate and make a row number column split(., f = .$ID) %>% #split columns by ID map_df(~ { #reorder rows df <- . #make split dataframes into one dataframe df %>% #call on dataframe add_count() %>% #add a row count column rowwise() %>% #sort by row #calculate the difference to every other GOIcp, #taking the minimum of all distances. #If this difference is less than 1.5 the row is kept. #If all differences in a data.frame are greater than 1.5, they are all kept. mutate(diff = min(abs(HKGcp - df[df[, "HKGcp"] != HKGcp, "HKGcp"]))) %>% ungroup() %>% filter( (diff <= replicate_difference_threshold & sum(diff > replicate_difference_threshold) != n)) %>% # filter( (diff <= 1.5 & sum(diff > 1.5) != n) | sum(diff > 1.5) == n ) %>% select(-n, -diff) } ) %>% arrange(row) %>% select(-row)) df2 <- as.data.frame(CPs %>% mutate(row = row_number()) %>% #mutate and make a row number column split(., f = .$ID) %>% #split columns by ID map_df(~ { #reorder rows df <- . #make split dataframes into one dataframe df %>% #call on dataframe add_count() %>% #add a row count column rowwise() %>% #sort by row #calculate the difference to every other GOIcp, #taking the minimum of all distances. #If this difference is less than 1.5 the row is kept. #If all differences in a data.frame are greater than 1.5, they are all kept. mutate(diff = min(abs(GOIcp - df[df[, "GOIcp"] != GOIcp, "GOIcp"]))) %>% ungroup() %>% filter( (diff <= replicate_difference_threshold & sum(diff > replicate_difference_threshold) != n)) %>% # filter( (diff <= 1.5 & sum(diff > 1.5) != n) | sum(diff > 1.5) == n ) %>% select(-n, -diff) } ) %>% arrange(row) %>% select(-row)) df1 <- df1[,-c(2)] #remove GOIcp column
df2 <- df2[,-c(3)] #remove HKGcp column
CPs <- merge(df1, df2, by = c("Pos", "ID")) #merge data by similar Pos and ID # ------------------------------------
# Now you have all the raw CP values in one place, with ID
# Average for each animal ID
CPs <- CPs %>% group_by(ID) %>% summarise(GOIcp = mean(GOIcp, na.rm = TRUE), HKGcp = mean(HKGcp, na.rm = TRUE)) # For this experiment my IDs have region in them, so that needs to be its own column
CPs <- CPs %>% separate(ID, c("ID", vars), sep = "_") # ------------------------------------
# Put groups into the table
# CHANGE FILE NAME
group <- read_excel(plate_layout_file, sheet = "Groups") # CPs$ID <- as.character(CPs$ID)
group$ID <- as.character(group$ID)
CPs <- left_join(CPs, group) # Subtract GOI from HKG and add to table
# HKGmGOI <- CPs$HKGcp - CPs$GOIcp
CPs$HKGmGOI <- CPs$HKGcp - CPs$GOIcp # summarize table for group by gene by region for control
# This is because we use the delta delta ct method for qPCR analysis
# which normalizes expression to the control group
# CPs$Group <- as.character(CPs$Group) # CHANGE NAME OF CONTROL GROUP
vehicle <- filter(CPs, Group == vehicle_group)
vehicle <- select(vehicle, !"Group") # change or add variables if not just region!!!!!!!!!!!!!!!!!!!!!!!!!!!
summary <- vehicle %>% group_by_at(vars2_grouping) %>% summarise(ref = mean(HKGmGOI, na.rm = TRUE)) # get ref value for each combo
# change or add variables if not just region!!!!!!!!!!!!!!!!!!!!!!!!!!!
summary <- unite(summary, condition, vars2_grouping, sep = "_") # put main data table in the same format
# change or add variables if not just region!!!!!!!!!!!!!!!!!!!!!!!!!!!
CPs <- unite(CPs, condition, vars2_grouping, sep = "_") # put ref value in main table
data <- left_join(CPs, summary, by = "condition") # find delta delta CT
Rel.Exp <- 2^(data$HKGmGOI - data$ref) # add it to table
data <- cbind(data, Rel.Exp)
#changes number of groups if needed!!!!!!!!!!!!!!!!!!!!!!!!!!!
data$Group <- factor(data$Group, levels = experiment_level_analysis) # Graph it
boxplot <- ggboxplot(data, x = "condition", y = "Rel.Exp", ylim = c(0, 2), add = "jitter", fill = "White", xlab = FALSE, ylab = "Relative mRNA Expression", color = "Group")
boxplot # Perform t-tests. Change condition to the name of whatever you are interested in.
# Condition must be a value for the column condition in data
condition1 <- t.test(Rel.Exp ~ Group, data, subset = condition == condition1)
condition2 <- t.test(Rel.Exp ~ Group, data, subset = condition == condition2)
condition3 <- t.test(Rel.Exp ~ Group, data, subset = condition == condition3)
condition4 <- t.test(Rel.Exp ~ Group, data, subset = condition == condition4)
condition5 <- t.test(Rel.Exp ~ Group, data, subset = condition == condition5) # Rearrange data for correlation analysis
corrdata <- select(data, c("ID", "condition", "Rel.Exp"))
corrdata <- dcast(corrdata, ID ~ condition, value.var = "Rel.Exp")
corrdata <- filter(corrdata, ID != 0)
corrdata <- corrdata[, 1:5]
write.csv(data,file=paste(working_directory,csv_save_name,sep=""), row.names=FALSE) 