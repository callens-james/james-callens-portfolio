# Preliminary setup before running the script should be to go to the open field computer. Run the analysis on the file(s) of choice.
# (e.g. File > Data Analysis - then setup arenas, zones, and file selection)
# Then go to the following file path --- C:\Users\hurdlab\AppData\Local\VirtualStore\Program Files\Activity Monitor
# Find your analysis file (should have file extension of ".Zone") and copy it to a convenient location to access with this R script # Make sure there are 2 empty lines at the bottom of the notepad "zone" file
wd <- "C:/Users/PC/Dropbox/tanni=joe=james/open_field/Icer_vector_pilot_Heroin_SA/Cohort 2/tr_openfield_2021august17/raw_and_script/"
Export_File_Name <- "bigcenter.Zone"
number_of_zones <- "2" # options are "1", "2", or "3"
number_of_animals <- 14
number_of_bins <- 30
##############################################
# This installs & calls packages & reads file ##############################################
setwd(wd)
list.of.packages <- c("plyr", "dplyr", "stringr", "openxlsx")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[, "Package"])] if (length(new.packages)) { install.packages(new.packages)
} library(plyr)
library(dplyr)
library(stringr)
library(openxlsx) if (number_of_zones == "1") { dat <- readLines(Export_File_Name)
} else if (number_of_zones == "2") { dat <- readLines(Export_File_Name)
} else if (number_of_zones == "3") { dat <- readLines(Export_File_Name)
} else if (number_of_zones == "4") { dat <- readLines(Export_File_Name)
} else if (number_of_zones == "5") { dat <- readLines(Export_File_Name)
} df_delim = read.delim(Export_File_Name)
df_lines = readLines(Export_File_Name)
#######################################
# This function fixes the time display
#######################################
time_converter.rFUNC <- function(x) { for (column_name in colnames(x)[c(2, 4, 6, 8, 10)]) { for (row in 1:nrow(x)) { left_char <- as.data.frame(substr(x[row, column_name], nchar(x[row, column_name]) - (7), nchar(x[row, column_name]) - (6))) mid_char <- as.data.frame(substr(x[row, column_name], nchar(x[row, column_name]) - (4), nchar(x[row, column_name]) - (3))) right_char <- as.data.frame(substr(x[row, column_name], nchar(x[row, column_name]) - (2-1), nchar(x[row, column_name]))) int.time <- cbind(left_char, mid_char, right_char) colnames(int.time) = c("min", "sec", "ms") int.time$min <- as.numeric(as.character(int.time$min)) int.time$sec <- as.numeric(as.character(int.time$sec)) int.time$ms <- as.numeric(as.character(int.time$ms)) int.time$min <- ifelse(int.time$min > 0, int.time$min*60,0) int.time$ms <- int.time$ms/100 x[row, column_name] <- as.data.frame(rowSums(int.time)) } } return(x)
}
####################################################################
# This function grabs and binds the groups and subjects to the data
####################################################################
group_subject_data_bind.rFUNC <- function(dat) { subjects <- apply(data.frame(grep("Subject ID:",dat), grep("Experiment ID:",dat)-1),1,function(x) (dat[x[1]:x[2]])) subjects <- as.data.frame(gsub("Subject ID:", "", subjects)) subjects <- as.data.frame(apply(subjects,2,function(x)gsub('\\s+', '',x))) groups <- apply(data.frame(grep("Group ID:",dat), grep("Session No:",dat)-1),1,function(x) (dat[x[1]:x[2]])) groups <- as.data.frame(gsub("Group ID:", "", groups)) groups <- as.data.frame(apply(groups,2,function(x)gsub('\\s+', '',x))) out_data <- cbind(subjects, groups, data)
}
#######################################################
# This finds the avg, sd, n, sd for the one zone files
#######################################################
column.rFUNC <- function(x, column_label) { x %>% summarize(avg = mean(x[,column_label]), n = n(), sd = sd(x[,column_label]), se = sd / sqrt(n))
}
#######################################################
# This separates the avg, n, sd, and se for each group
#######################################################
EXCEL_grouping.rFUNC <- function(x) { for (group in unique(df$Treatment)) { for (i in colnames(df)[3:ncol(df)]) { group_df <- subset(df, Treatment == group) output <- column.rFUNC(group_df, i) output$Behav_Type <- i output$Treatment <- group df_list = rbind(df_list , output) } } df_list <- df_list[order(df_list$Behav_Type),] df_list <- split(df_list, df_list$Behav_Type) wb <- createWorkbook() for (i in 1:length(df_list)) { addWorksheet(wb, sheetName = names(df_list[i])) writeData(wb, sheet = names(df_list[i]), x = df_list[[i]]) } if (number_of_zones == "1") { saveWorkbook(wb, file = "One_Zone_Averages.xlsx", overwrite = TRUE) } else if (number_of_zones == "2") { saveWorkbook(wb, file = "Two_Zone_Averages.xlsx", overwrite = TRUE) } else if (number_of_zones == "3") { saveWorkbook(wb, file = "Three_Zone_Averages.xlsx", overwrite = TRUE) } else if (number_of_zones == "4") { saveWorkbook(wb, file = "Four_Zone_Averages.xlsx", overwrite = TRUE) } else if (number_of_zones == "5") { saveWorkbook(wb, file = "Five_Zone_Averages.xlsx", overwrite = TRUE) }
}
#############################################################
# Function loop to fix cumulative rows
#############################################################
Cumulative_Row_Fix.rFUNC <- function(x) { for (row in 2:nrow(df)) { if (df[row, "Subject_ID"] == df[row - 1, "Subject_ID"]) { df[row, c(1:10)] = (df[row, c(1:10)] - df[row - 1, c(1:10)]) } } df <- df[order(df$Subject_ID),]
}
detach("package:plyr", unload=TRUE)
###################################
# This grabs the data for one zone
###################################
if (number_of_zones == "1") { data_z1 <- as.data.frame(read.table(text = dat[grep("Zone Totals", dat) + 5])[,1:10]) data_z1 <- time_converter.rFUNC(data_z1) data <- data_z1 out_data <- group_subject_data_bind.rFUNC(dat) colnames(out_data) <- c("Subject ID", "Treatment", "Dist.Trav.(cm)", "Amb.T.(s.ms)", "Amb.Cnts.", "Ster.T.(s.ms)", "Ster.Cnts.", "Rest.T.(s.ms)", "Vert.Cnts.", "Vert.T.(s.ms)", "Zone.Ent.", "Zone.T.(s.ms)") out_data <- as.data.frame(apply(out_data,2,function(x)gsub('\\s+', '',x))) write.csv(out_data, file = "One_Zone_Data.csv", row.names = FALSE) df <- read.csv("One_Zone_Data.csv") df_list <- data.frame() EXCEL_grouping.rFUNC(x)
}
###################################
# This grabs the data for two zones
###################################
if (number_of_zones == "2") { data_z1 <- as.data.frame(read.table(text = dat[grep("Zone Totals", dat) + 5])[,1:10]) data_z2 <- as.data.frame(read.table(text = dat[grep("Zone Totals", dat) + 6])[,1:10]) data_z1 <- time_converter.rFUNC(data_z1) data_z2 <- time_converter.rFUNC(data_z2) data <- cbind(data_z1, data_z2) out_data <- group_subject_data_bind.rFUNC(dat) out_data <- out_data[,c(1, 2, 3, 13, 4, 14, 5, 15, 6, 16, 7, 17, 8, 18, 9, 19, 10, 20, 11, 21, 12, 22)] colnames(out_data) <- c("Subject ID", "Treatment", "Dist.Trav.(cm)_Zone1", "Dist.Trav.(cm)_Zone2", "Amb.T.(s.ms)_Zone1", "Amb.T.(s.ms)_Zone2", "Amb.Cnts._Zone1", "Amb.Cnts._Zone2", "Ster.T.(s.ms)_Zone1", "Ster.T.(s.ms)_Zone2", "Ster.Cnts._Zone1", "Ster.Cnts._Zone2", "Rest.T.(s.ms)_Zone1", "Rest.T.(s.ms)_Zone2", "Vert.Cnts._Zone1", "Vert.Cnts._Zone2", "Vert.T.(s.ms)_Zone1", "Vert.T.(s.ms)_Zone2", "Zone.Ent._Zone1", "Zone.Ent._Zone2", "Zone.T.(s.ms)_Zone1", "Zone.T.(s.ms)_Zone2") out_data <- as.data.frame(apply(out_data,2,function(x)gsub('\\s+', '',x))) write.csv(out_data, file = "Two_Zone_Data.csv", row.names = FALSE) df <- read.csv("Two_Zone_Data.csv") df_list <- data.frame() EXCEL_grouping.rFUNC(x)
}
###################################
# This grabs the data for three zones
###################################
# if (number_of_zones == "3") {
# data_z1 <- as.data.frame(read.table(text = dat[grep("Zone Totals", dat) + 5])[,1:10])
# data_z2 <- as.data.frame(read.table(text = dat[grep("Zone Totals", dat) + 6])[,1:10])
# data_z3 <- as.data.frame(read.table(text = dat[grep("Zone Totals", dat) + 7])[,1:10])
# data_z1 <- time_converter.rFUNC(data_z1)
# data_z2 <- time_converter.rFUNC(data_z2)
# data_z3 <- time_converter.rFUNC(data_z3)
# data <- cbind(data_z1, data_z2, data_z3)
# out_data <- group_subject_data_bind.rFUNC(dat)
# out_data <- out_data[,c(1, 2, 3, 13, 23, 4, 14, 24, 5, 15, 25, 6, 16, 26, 7, 17, 27, # 8, 18, 28, 9, 19, 29, 10, 20, 30, 11, 21, 31, 12, 22, 32)]
# colnames(out_data) <- c("Subject ID", "Treatment", # "Dist.Trav.(cm)_Zone1", "Dist.Trav.(cm)_Zone2", "Dist.Trav.(cm)_Zone3",
# "Amb.T.(s.ms)_Zone1", "Amb.T.(s.ms)_Zone2", "Amb.T.(s.ms)_Zone3",
# "Amb.Cnts._Zone1", "Amb.Cnts._Zone2", "Amb.Cnts._Zone3",
# "Ster.T.(s.ms)_Zone1", "Ster.T.(s.ms)_Zone2", "Ster.T.(s.ms)_Zone3",
# "Ster.Cnts._Zone1", "Ster.Cnts._Zone2", "Ster.Cnts._Zone3",
# "Rest.T.(s.ms)_Zone1", "Rest.T.(s.ms)_Zone2", "Rest.T.(s.ms)_Zone3",
# "Vert.Cnts._Zone1", "Vert.Cnts._Zone2", "Vert.Cnts._Zone3",
# "Vert.T.(s.ms)_Zone1", "Vert.T.(s.ms)_Zone2", "Vert.T.(s.ms)_Zone3",
# "Zone.Ent._Zone1", "Zone.Ent._Zone2", "Zone.Ent._Zone3",
# "Zone.T.(s.ms)_Zone1", "Zone.T.(s.ms)_Zone2", "Zone.T.(s.ms)_Zone3")
# # out_data <- as.data.frame(apply(out_data,2,function(x)gsub('\\s+', '',x)))
# write.csv(out_data, file = "Three_Zone_Data.csv", row.names = FALSE)
# df <- read.csv("Three_Zone_Data.csv")
# df_list <- data.frame()
# EXCEL_grouping.rFUNC(x)
# }
###################################
# This starts the binned data code
###################################
# One zone section
###################################
# end_row <- "--------------------------------------------------------------------------------------------------------"
colnames(df_delim) <- c('Col')
df_delim$Col <- as.character(df_delim$Col)
# df_delim[75,]
# one_zone_row <- "Zone 1 (0.5, 0.5) to (16, 16)"
zone_row <- df_delim[75,]
all_zone_row <- which(df_delim$Col == zone_row)
data <- all_zone_row + 4
final <- data.frame(matrix(data = NA, ncol = 10)) for (i in data) { new_num = i while (df_delim[new_num, "Col"] != df_delim[109,]) { # while (df_delim[new_num, "Col"] != end_row) { final = rbind(final, unlist(strsplit(df_delim[new_num,], " "))[which(unlist(strsplit(df_delim[new_num,], " ")) != "")]) new_num = new_num + 1 }
}
final <- na.omit(final)
# final
colname1 <- unlist(strsplit(df_delim[76,], " "))[which(unlist(strsplit(df_delim[77,], " ")) != "")]
# colname1 <- unlist(strsplit(one_zone_row, " ")+1)[which(unlist(strsplit(one_zone_row, " ")+1) != "")]
colname2 <- unlist(strsplit(df_delim[77,], " "))[which(unlist(strsplit(df_delim[77,], " ")) != "")]
# colname2 <- unlist(strsplit(one_zone_row+2, " "))[which(unlist(strsplit(one_zone_row+2, " ")) != "")]
finalcolnames <- c() for (i in seq(1, 10)) { finalcolnames = append(finalcolnames, paste0(colname1[i], " ", colname2[i]))
} colnames(final) <- finalcolnames
final <- as.data.frame(final)
csvname = "zone1_binned.csv"
final <- time_converter.rFUNC(final) colnames(final) <- c("Dist.Tr(cm)", "Time.Amb", "Amb.Cnts", "Time.Ster", "Ster.Cnts", "Time.Rest", "Vert.Cnts", "Vert.Time", "Zone.Entries", "Zone.Time") write.csv(final, file = paste(csvname, sep = ""), row.names = FALSE)
df_delim <- read.csv(csvname)
################################################################################################
###################################
# Two zone section
###################################
df_delim <- read.csv(csvname) if (number_of_zones == "1") { df_delim$Zone = 1
} else if (number_of_zones == "2") { df_delim$Zone = 2
} else if (number_of_zones == "3") { df_delim$Zone = 2
} if (number_of_zones == "2") { df_delim = read.delim(Export_File_Name)
} else if (number_of_zones == "3") { df_delim = read.delim(Export_File_Name)
} colnames(df_delim) <- c('Col')
df_delim$Col <- as.character(df_delim$Col)
# df_delim[144,]
zone_row <- df_delim[110,]
all_zone_row = which(df_delim$Col == zone_row)
data = all_zone_row + 4
final = data.frame(matrix(data = NA, ncol = 10))
# df_delim[144,]
for (i in data) { new_num = i while (df_delim[new_num, "Col"] != df_delim[144,]) { final = rbind(final, unlist(strsplit(df_delim[new_num,], " "))[which(unlist(strsplit(df_delim[new_num,], " ")) != "")]) new_num = new_num + 1 }
} final = na.omit(final)
colname1 <- unlist(strsplit(df_delim[111,], " "))[which(unlist(strsplit(df_delim[111,], " ")) != "")]
colname2 <- unlist(strsplit(df_delim[112,], " "))[which(unlist(strsplit(df_delim[112,], " ")) != "")]
finalcolnames = c() for (i in seq(1, 10)) { finalcolnames = append(finalcolnames, paste0(colname1[i], " ", colname2[i]))
} colnames(final) <- finalcolnames
final <- as.data.frame(final) if (number_of_zones == "2") { csvname = "zone2_binned.csv"
} else if (number_of_zones == "3") { csvname = "zone2_binned.csv"
} final <- time_converter.rFUNC(final) colnames(final) <- c("Dist.Tr(cm)", "Time.Amb", "Amb.Cnts", "Time.Ster", "Ster.Cnts", "Time.Rest", "Vert.Cnts", "Vert.Time", "Zone.Entries", "Zone.Time") write.csv(final, file = paste(csvname, sep = ""), row.names = FALSE)
################################################################################################
###################################
# Three zone section
###################################
df_delim <- read.csv(csvname) if (number_of_zones == "1") { df_delim$Zone = 1
} else if (number_of_zones == "2") { df_delim$Zone = 2
} else if (number_of_zones == "3") { df_delim$Zone = 3
} if (number_of_zones == "3") { df_delim = read.delim(Export_File_Name)
} colnames(df_delim) <- c('Col')
df_delim$Col <- as.character(df_delim$Col)
three_zone_row <- df_delim[86,]
all_zone_row = which(df_delim$Col == three_zone_row)
data = all_zone_row + 4
final = data.frame(matrix(data = NA, ncol = 10)) for (i in data) { new_num = i while (df_delim[new_num, "Col"] != end_row) { final = rbind(final, unlist(strsplit(df_delim[new_num,], " "))[which(unlist(strsplit(df_delim[new_num,], " ")) != "")]) new_num = new_num + 1 }
} final = na.omit(final)
colname1 = unlist(strsplit(df_delim[87,], " "))[which(unlist(strsplit(df_delim[87,], " ")) != "")]
colname2 = unlist(strsplit(df_delim[88,], " "))[which(unlist(strsplit(df_delim[88,], " ")) != "")]
finalcolnames = c() for (i in seq(1, 10)) { finalcolnames = append(finalcolnames, paste0(colname1[i], " ", colname2[i]))
} colnames(final) <- finalcolnames
final <- as.data.frame(final) if (number_of_zones == "3") { csvname = "zone3_binned.csv"
} final <- time_converter.rFUNC(final) colnames(final) <- c("Dist.Tr(cm)", "Time.Amb", "Amb.Cnts", "Time.Ster", "Ster.Cnts", "Time.Rest", "Vert.Cnts", "Vert.Time", "Zone.Entries", "Zone.Time") write.csv(final, file = paste(csvname, sep = ""), row.names = FALSE)
################################################
if (number_of_zones == "1") { Zone1 = read.csv("zone1_binned.csv") Zone1$Zone = c("zone1")
} else if (number_of_zones == "2") { Zone1 = read.csv("zone1_binned.csv") Zone2 = read.csv("zone2_binned.csv") Zone1$Zone = c("zone1") Zone2$Zone = c("zone2")
} else if (number_of_zones == "3") { Zone1 = read.csv("zone1_binned.csv") Zone2 = read.csv("zone2_binned.csv") Zone3 = read.csv("zone3_binned.csv") Zone1$Zone = c("zone1") Zone2$Zone = c("zone2") Zone3$Zone = c("zone3")
} ntot <- number_of_animals * number_of_bins animal <- apply(data.frame(grep("Subject ID:", df_lines), grep("Experiment ID:", df_lines) - 1), 1, function(x) (df_lines[x[1]:x[2]]))
animal <- as.list(animal)
animal <- gsub("Subject ID:", "", animal)
animal <- gsub('\\s+', '', animal) df_lines_a <- data.frame(matrix(nrow = ntot, ncol = 2))
colnames(df_lines_a) <- c("Number",	"Subject_ID")
num_list = c(seq(1, number_of_bins, 1))
repeat_x = c(seq(1, number_of_animals))
stored_a <- c() for (i in repeat_x) { for (j in num_list) { stored_a <- append(stored_a, j) }
} df_lines_a$Number <- stored_a
df_lines_b <- data.frame(matrix(nrow = number_of_animals, ncol = 1))
colnames(df_lines_b) <- c('Subject_ID')
df_lines_b$Subject_ID <- animal
stored_b <- c() for (i in animal) { for (j in num_list) { stored_b <- append(stored_b, i) }
} df_lines_a$Subject_ID <- stored_b if (number_of_zones == "1") { Zone1$Subject_ID = df_lines_a$Subject_ID
} else if (number_of_zones == "2") { Zone1$Subject_ID = df_lines_a$Subject_ID Zone2$Subject_ID = df_lines_a$Subject_ID
} else if (number_of_zones == "3") { Zone1$Subject_ID = df_lines_a$Subject_ID Zone2$Subject_ID = df_lines_a$Subject_ID Zone3$Subject_ID = df_lines_a$Subject_ID
} group <- apply(data.frame(grep("Group ID:", df_lines), grep("Session No:", df_lines) - 1), 1, function(x) (df_lines[x[1]:x[2]]))
group <- as.list(group)
group <- gsub("Group ID:", "", group)
group <- gsub('\\s+', '', group) df_lines_a <- data.frame(matrix(nrow = ntot, ncol = 2))
colnames(df_lines_a) <- c("Number",	"Group_ID")
num_list = c(seq(1, number_of_bins, 1))
repeat_x = c(seq(1, number_of_animals))
stored_a <- c() for (i in repeat_x) { for (j in num_list) { stored_a <- append(stored_a, j) }
} df_lines_a$Number <- stored_a
df_lines_b <- data.frame(matrix(nrow = number_of_animals, ncol = 1))
colnames(df_lines_b) <- c('Group_ID')
df_lines_b$Group_ID <- group
stored_b <- c() for (i in group) { for (j in num_list) { stored_b <- append(stored_b, i) }
} df_lines_a$Group_ID <- stored_b if (number_of_zones == "1") { Zone1$Group_ID = df_lines_a$Group_ID
} else if (number_of_zones == "2") { Zone1$Group_ID = df_lines_a$Group_ID Zone2$Group_ID = df_lines_a$Group_ID
} else if (number_of_zones == "3") { Zone1$Group_ID = df_lines_a$Group_ID Zone2$Group_ID = df_lines_a$Group_ID Zone3$Group_ID = df_lines_a$Group_ID
} if (number_of_zones == "1") { df_lines <- Zone1
} else if (number_of_zones == "2") { df_lines <- rbind(Zone1, Zone2)
} else if (number_of_zones == "3") { df_lines <- rbind(Zone1, Zone2, Zone3)
} if (number_of_zones == "1") { csvname = "one_zone_data_bin_output.csv"
} else if (number_of_zones == "2") { csvname = "two_zones_data_bin_output.csv"
} else if (number_of_zones == "3") { csvname = "three_zones_data_bin_output.csv"
} colnames(df_lines) <- c("Dist.Tr(cm)", "Time.Amb", "Amb.Cnts", "Time.Ster", "Ster.Cnts", "Time.Rest", "Vert.Cnts", "Vert.Time", "Zone.Entries", "Zone.Time", "Zone", "Subject_ID", "Group_ID") # this function fixes the cumulative binned lines to give true bin values
DF <- df_lines[, c("Dist.Tr(cm)", "Time.Amb", "Amb.Cnts", "Time.Ster", "Ster.Cnts", "Time.Rest", "Vert.Cnts", "Vert.Time")]
for(row in 2:nrow(df_lines)) { if(df_lines[row - 1, "Subject_ID"] == df_lines[row, "Subject_ID"]) { df_lines[row, c("Dist.Tr(cm)", "Time.Amb", "Amb.Cnts", "Time.Ster", "Ster.Cnts", "Time.Rest", "Vert.Cnts", "Vert.Time")] <- DF[row, ] - DF[row-1, ] } else {df_lines[row,] == df_lines[row,]}
} write.csv(df_lines, file = paste(csvname, sep = ""), row.names = FALSE)
#############################################################
df <- read.csv(csvname)
df$Dist.Tr.cm. <- as.numeric(as.character(df$Dist.Tr.cm.))
df$Time.Amb <- as.numeric(as.character(df$Time.Amb))
df$Amb.Cnts <- as.numeric(as.character(df$Amb.Cnts))
df$Time.Ster <- as.numeric(as.character(df$Time.Ster))
df$Ster.Cnts <- as.numeric(as.character(df$Ster.Cnts))
df$Time.Rest <- as.numeric(as.character(df$Time.Rest))
df$Vert.Cnts <- as.numeric(as.character(df$Vert.Cnts))
df$Vert.Time <- as.numeric(as.character(df$Vert.Time))
df$Zone.Entries <- as.numeric(as.character(df$Zone.Entries))
df$Zone.Time <- as.numeric(as.character(df$Zone.Time)) if (number_of_zones == "1") { csvname = "one_zone_data_bin_output.csv"
} else if (number_of_zones == "2") { csvname = "two_zones_data_bin_output.csv"
} else if (number_of_zones == "3") { csvname = "three_zones_data_bin_output.csv"
} write.csv(df, file = paste(csvname, sep = ""), row.names = FALSE)
df <- read.csv(csvname) Cumulative_Row_Fix.rFUNC(x)
#############################################################
if (number_of_zones == "1") { csvname = "one_zone_data_bin_output.csv"
} else if (number_of_zones == "2") { csvname = "two_zones_data_bin_output.csv"
} else if (number_of_zones == "3") { csvname = "three_zones_data_bin_output.csv"
} write.csv(df, file = paste(csvname, sep = ""), row.names = FALSE)
#############################################################
df1 <- read.csv(csvname)
df1$index <- stored_a
######################################################
if (number_of_zones == "1") { csvname = "one_zone_data_bin_output.csv"
} else if (number_of_zones == "2") { csvname = "two_zones_data_bin_output.csv"
} else if (number_of_zones == "3") { csvname = "three_zones_data_bin_output.csv"
} write.csv(df1, file = paste(csvname, sep = ""), row.names = FALSE)
df1 <- read.csv(csvname)
#################################################################
output <- data.frame()
for (zone_type in unique(df1$Zone)) { for (group_label in unique(df1$Group_ID)) { for (index_label in unique(df1$index)) { subset_index <- subset(df1, index == index_label & Group_ID == group_label & Zone == zone_type) subset_index <- subset_index[, 1:10] subset_index <- as.data.frame(t(colMeans(subset_index))) subset_index$Group <- rep(group_label, dim(subset_index)[1]) if (str_detect(group_label, "nocue")) {subset_index$Cue = rep("no_cue", dim(subset_index)[1]) } else if (str_detect(group_label, "cue")) { subset_index$Cue = rep("cue", dim(subset_index)[1]) } subset_index$Zone <- rep(zone_type, dim(subset_index)[1]) output <- rbind(output, subset_index) } }
}
output[, 1:8] <- round(output[, 1:8], digits = 3)
output$Bin <- seq(1, number_of_bins, 1)
#################################################################
df <- output if(number_of_zones == "3"){
df <- df[order(df$Group, df$Bin, df$Cue),]
} rownames(df) <- NULL if (number_of_zones == "1") { csvname = "one_zone_bin_group_averages.csv"
} else if (number_of_zones == "2") { csvname = "two_zones_bin_group_averages.csv"
} else if (number_of_zones == "3") { csvname = "three_zones_bin_group_averages.csv"
} write.csv(df, file = paste(csvname, sep = ""), row.names = FALSE)
#############################################################
if (number_of_zones == "1") { csvname = "one_zone_data_bin_output.csv"
} else if (number_of_zones == "2") { csvname = "two_zones_data_bin_output.csv"
} else if (number_of_zones == "3") { csvname = "three_zones_data_bin_output.csv"
} df <- read.csv(csvname)
df$Bin <- seq(1, number_of_bins, 1)
################################################################
# Function to loop through columns and get calculation summary
################################################################
df_list <- data.frame()
for (zone_type in unique(df$Zone)) { for (group_label in unique(df$Group_ID)) { for (bin_label in unique(df$Bin)) { subset_index <- subset(df, Bin == bin_label & Group_ID == group_label & Zone == zone_type) for (i in colnames(subset_index[, 1:10])) { output <- column.rFUNC(subset_index, i) output$Zone <- rep(zone_type, dim(output)[1]) output$Group_ID <- rep(group_label, dim(output)[1]) output$Bin <- rep(bin_label, dim(output)[1]) output$Behav_Type <- i df_list = rbind(df_list , output) } } }
} summary <- df_list
summary <- summary[order(summary$Behav_Type),]
output <- split(summary, summary$Behav_Type)
wb <- createWorkbook() for (i in 1:length(output)) { addWorksheet(wb, sheetName = names(output[i])) writeData(wb, sheet = names(output[i]), x = output[[i]])
} if (number_of_zones == "1") { csvname = "one_zone_bin_calc_summary.xlsx"
} else if (number_of_zones == "2") { csvname = "two_zones_bin_calc_summary.xlsx"
} else if (number_of_zones == "3") { csvname = "three_zones_bin_calc_summary.xlsx"
} saveWorkbook(wb, file = paste(csvname, sep = ""), overwrite = TRUE) unlink("zone1_binned.csv")
unlink("zone2_binned.csv")
unlink("zone3_binned.csv") 