args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) stop("Usage: Rscript process_excel.R <input_file> <output_dir>")
input_file <- normalizePath(args[1], winslash = "/", mustWork = TRUE)
output_dir <- args[2]
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE) suppressWarnings({ if (!requireNamespace("openxlsx", quietly = TRUE)) { stop("Package 'openxlsx' is required. Install it in R with: install.packages('openxlsx')") }
})
library(openxlsx) read_source <- function(path) { ext <- tolower(tools::file_ext(path)) if (ext == "csv") return(read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)) sheets <- getSheetNames(path) if (length(sheets) < 1) stop("No worksheets found.") read.xlsx(path, sheet = sheets[1], detectDates = FALSE, check.names = FALSE)
} df <- read_source(input_file)
names(df) <- make.names(trimws(as.character(names(df))), unique = TRUE)
lower_names <- tolower(names(df))
for (i in seq_along(df)) if (is.factor(df[[i]])) df[[i]] <- as.character(df[[i]]) timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
base_name <- tools::file_path_sans_ext(basename(input_file))
output_xlsx <- file.path(output_dir, paste0(base_name, "_processed_", timestamp, ".xlsx"))
output_csv <- file.path(output_dir, paste0(base_name, "_summary_", timestamp, ".csv")) rev_col <- which(grepl("revenue|amount|sales", lower_names))[1]
region_col <- which(grepl("region", lower_names))[1]
product_col <- which(grepl("product", lower_names))[1] summary_df <- NULL
if (!is.na(rev_col)) { rev_vals <- suppressWarnings(as.numeric(gsub(",", "", as.character(df[[rev_col]])))) df$.__revenue__ <- rev_vals rows <- list() if (!is.na(region_col)) { region_sum <- aggregate(df$.__revenue__, by = list(Region = df[[region_col]]), FUN = sum, na.rm = TRUE) names(region_sum)[2] <- "Total_Revenue" rows[[length(rows)+1]] <- data.frame(View = "Revenue_by_Region", Key = region_sum$Region, Value = region_sum$Total_Revenue) } if (!is.na(product_col)) { product_sum <- aggregate(df$.__revenue__, by = list(Product = df[[product_col]]), FUN = sum, na.rm = TRUE) names(product_sum)[2] <- "Total_Revenue" rows[[length(rows)+1]] <- data.frame(View = "Revenue_by_Product", Key = product_sum$Product, Value = product_sum$Total_Revenue) } rows[[length(rows)+1]] <- data.frame(View = "Summary", Key = c("Rows", "Non-missing revenue rows", "Total Revenue"), Value = c(nrow(df), sum(!is.na(df$.__revenue__)), sum(df$.__revenue__, na.rm = TRUE))) summary_df <- do.call(rbind, rows)
} else { summary_df <- data.frame( View = "Column_Profile", Key = names(df), Value = sapply(df, function(x) sum(!is.na(x) & as.character(x) != "")) )
} write_mode <- "xlsx"
write_error <- NULL
tryCatch({ wb <- createWorkbook() addWorksheet(wb, "Raw_Copy") writeData(wb, "Raw_Copy", df) addWorksheet(wb, "Summary") writeData(wb, "Summary", summary_df) saveWorkbook(wb, output_xlsx, overwrite = TRUE)
}, error = function(e) { write_mode <<- "csv" write_error <<- conditionMessage(e) write.csv(summary_df, output_csv, row.names = FALSE, na = "")
}) cat(paste(c( paste("Processed input:", input_file), paste("Write mode:", write_mode), if (!is.null(write_error)) paste("XLSX write fallback reason:", write_error) else NULL, paste("Output file:", if (write_mode == "xlsx") output_xlsx else output_csv)
), collapse = "\n"))
