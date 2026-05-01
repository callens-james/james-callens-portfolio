# social_interaction_2023June16.R
# Purpose: Analysis/processing script for behavioral workflow data.
# Note: Public portfolio version; paths and sensitive identifiers should be parameterized. wd = "C:/Users/PC/Desktop/social_interaction_2023June16/" setwd(wd)
csvname = "output.csv" library(tidyr)
library(dplyr)
library(reshape2)
library(purrr)
library(lubridate)
library(tidyverse) files <- list.files(path = wd, pattern = "*.csv", full.names = TRUE, recursive = FALSE)
names <- tools::file_path_sans_ext(basename(files)) lap.list <- lapply(files, function(x) { read.csv(x, header = TRUE)
}) names(lap.list) = names lap.list <- melt(lap.list)
df <- lap.list
df$variable <- c("Id") for (row in 1:nrow(df)){ if (df[row,"value"] == 1 & df[row+1,"value"] == 0){ df[row,"value"] = 0 }
} df <- subset(df, select = -c(Total, Mean, variable))
colnames(df) <- c("time","lap","ID")
df <- df[,c(3,2,1)]
df <- as.data.frame(df)
df$time <- as.numeric(lubridate::ms(as.character(df$time)))
df$int_type <- NA for (row in 1:length(df$time)) { if (is.na(df$time[row])) { df$time[row] = 600 }
} grouped_data <- as.data.frame(df %>% group_by(ID) %>% arrange(time)) grouped_data <- grouped_data[order(grouped_data$ID,grouped_data$lap),]
rownames(grouped_data) <- NULL grouped_data <- as.data.frame(grouped_data %>% group_by(ID) %>% mutate(cumulative_time = cumsum(time))) colnames(grouped_data) <- c("ID","lap","time","int_type","Value") df_filtered <- grouped_data %>% group_by(ID) %>% mutate(KeepRow = ifelse(row_number() == which.max(Value > 600), TRUE, FALSE)) %>% filter(KeepRow | Value <= 600) %>% select(-KeepRow) df <- df_filtered
df <- df[,-5] int <- subset(df, lap %% 2 == 0)
no_int <- subset(df, lap %% 2 == 1) int$int_type <- c("int")
no_int$int_type <- c("no_int") df <- rbind(no_int,int)
df <- df[order(df$ID,df$lap),] last_row <- df %>% group_by(ID) %>% slice_tail(n = 1)
tot_time <- aggregate(time ~ ID, df, sum) for (row in 1:nrow(tot_time)){ if (tot_time[row,"time"] < 600){ tot_time[row,"time"] = 600 - tot_time[row,"time"] } if (tot_time[row,"time"] > 600){ tot_time[row,"time"] = 0 }
} last_row$time <- last_row$time + tot_time$time
last_row <- as.data.frame(last_row) lookup_table <- setNames(last_row$time, paste(last_row$ID, last_row$lap, sep = "-")) for (row in 1:nrow(df)) { key <- paste(df[row, "ID"], df[row, "lap"], sep = "-") if (key %in% names(lookup_table)) { df[row, "time"] <- lookup_table[key] }
} df <- df %>% group_by(ID) %>% mutate(tot_int = sum(int_type == "int"), tot_no_int = sum(int_type == "no_int")) summation <- aggregate(time ~ ID + int_type, df, sum)
summation$tot_int <- NA
summation$tot_no_int <- NA match_index <- match(paste(df$ID, df$int_type), paste(summation$ID, summation$int_type))
summation$tot_int[match_index] <- df$tot_int
summation$tot_no_int[match_index] <- df$tot_no_int
summation <- summation[order(summation$ID),]
rownames(summation) <- NULL summation <- summation %>% pivot_wider(names_from = int_type, values_from = c(time, tot_int, tot_no_int), names_sep = "_") summation <- summation[,-c(5,7)]
colnames(summation) <- c("ID","int_time","no_int_time","tot_int","tot_no_int")
summation$value <- summation$ID jailrat_df <- summation[grepl("jailrat", summation$ID), ]
empty_df <- summation[grepl("empty", summation$ID), ]
num_rows <- max(nrow(jailrat_df), nrow(empty_df)) jailrat_df <- jailrat_df[1:num_rows, ]
empty_df <- empty_df[1:num_rows, ]
colnames(jailrat_df) <- paste0("Jailrat_", colnames(jailrat_df))
colnames(empty_df) <- paste0("Empty_", colnames(empty_df))
final_df <- cbind(jailrat_df, empty_df)
id_columns <- grep("ID", colnames(final_df), value = TRUE)
final_df[id_columns] <- lapply(final_df[id_columns], function(x) substr(x, 1, 3))
final_df$Jailrat_ID <- gsub("_","",final_df$Jailrat_ID)
final_df$Empty_ID <- gsub("_","",final_df$Empty_ID)
summation <- final_df
summation$Jailrat_value <- sub(".*?_", "", summation$Jailrat_value)
summation$Empty_value <- sub(".*?_", "", summation$Empty_value)
summation$Jailrat_value <- sub("_.*", "", summation$Jailrat_value)
summation$Empty_value <- sub("_.*", "", summation$Empty_value)
dat <- summation
###############################
for (row in 1:nrow(dat)) { if (dat[row, "Jailrat_tot_int"] == 2 && dat[row, "Jailrat_tot_no_int"] == 0) { dat[row, "Jailrat_tot_int"] <- NA dat[row, "Jailrat_tot_no_int"] <- NA } if (dat[row, "Empty_tot_int"] == 2 && dat[row, "Empty_tot_no_int"] == 0) { dat[row, "Empty_tot_int"] <- NA dat[row, "Empty_tot_no_int"] <- NA }
} dat$Jailrat_ID <- as.numeric(dat$Jailrat_ID)
dat$Jailrat_ID <- sprintf("%03s", dat$Jailrat_ID)
dat <- dat[order(dat$Jailrat_ID,dat$Empty_ID),]
dat <- dat[,c(1,6,2,3,4,5,7,8,9,10,11,12)]
dat <- dat[,-c(7,12)] for (row in 1:nrow(dat)) { if (is.na(dat$Jailrat_no_int_time[row])) { dat$Jailrat_int_time[row] = NA } if (is.na(dat$Empty_no_int_time[row])) { dat$Empty_int_time[row] = NA }
} summation <- dat write.csv(df,file=paste(wd,"full_data.csv",sep=""), row.names=FALSE, quote=FALSE, na = "")
write.csv(summation,file=paste(wd,csvname,sep=""), row.names=FALSE, quote=FALSE, na = "") 