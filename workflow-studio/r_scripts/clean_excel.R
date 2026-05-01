args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) { stop("Usage: Rscript clean_excel.R <input_file> <output_dir>")
} input_file <- normalizePath(args[1], winslash = "/", mustWork = TRUE)
output_dir <- args[2]
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE) suppressWarnings({ if (!requireNamespace("openxlsx", quietly = TRUE)) { stop("Package 'openxlsx' is required. Install it in R with: install.packages('openxlsx')") }
}) library(openxlsx) base_name <- tools::file_path_sans_ext(basename(input_file))
timestamp <- format(Sys.time(), "%Y%m%d_%H%M%S")
output_xlsx <- file.path(output_dir, paste0(base_name, "_cleaned_", timestamp, ".xlsx"))
output_csv <- file.path(output_dir, paste0(base_name, "_cleaned_", timestamp, ".csv"))
report_file <- file.path(output_dir, paste0(base_name, "_cleaning_report_", timestamp, ".txt")) trim_text <- function(x) { x <- as.character(x) x <- gsub("^\\s+|\\s+$", "", x) x[x %in% c("", "NA", "N/A", "NULL", "null", "na")] <- NA x
} normalize_name_case <- function(x) { x <- trim_text(x) ifelse(is.na(x), x, tools::toTitleCase(tolower(x)))
} normalize_status <- function(x) { y <- tolower(trim_text(x)) y[y == "active"] <- "Active" y[y == "leave"] <- "Leave" y[y == "terminated"] <- "Terminated" other <- !is.na(y) & !(y %in% c("Active", "Leave", "Terminated")) y[other] <- tools::toTitleCase(y[other]) y
} parse_date_text <- function(x) { raw <- trim_text(x) out <- rep(NA_character_, length(raw)) fmts <- c("%m/%d/%Y", "%Y-%m-%d", "%B %d %Y", "%m-%d-%Y", "%d/%m/%Y", "%m/%d/%y") for (fmt in fmts) { idx <- is.na(out) & !is.na(raw) if (any(idx)) { parsed <- as.Date(raw[idx], format = fmt) ok <- !is.na(parsed) if (any(ok)) { tmp <- out[idx] tmp[ok] <- format(parsed[ok], "%Y-%m-%d") out[idx] <- tmp } } } out[is.na(out) & !is.na(raw)] <- raw[is.na(out) & !is.na(raw)] out
} read_source <- function(path) { ext <- tolower(tools::file_ext(path)) if (ext == "csv") { return(read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)) } sheets <- getSheetNames(path) if (length(sheets) < 1) stop("No worksheets found.") read.xlsx(path, sheet = sheets[1], detectDates = FALSE, check.names = FALSE)
} safe_text_col <- function(x) { x <- as.character(x) x[is.nan(suppressWarnings(as.numeric(x)))] <- as.character(x[is.nan(suppressWarnings(as.numeric(x)))]) x
} df <- read_source(input_file)
original_rows <- nrow(df)
original_names <- names(df) names(df) <- make.names(trimws(as.character(names(df))), unique = TRUE)
lower_names <- tolower(names(df)) for (i in seq_along(df)) { df[[i]] <- if (is.factor(df[[i]])) as.character(df[[i]]) else df[[i]] nm <- lower_names[i] if (is.character(df[[i]])) { df[[i]] <- trim_text(df[[i]]) } if (grepl("name", nm)) { df[[i]] <- normalize_name_case(df[[i]]) } if (grepl("status", nm)) { df[[i]] <- normalize_status(df[[i]]) } if (grepl("date", nm)) { df[[i]] <- parse_date_text(df[[i]]) } if (grepl("salary|amount|revenue|price", nm)) { vals <- trim_text(gsub(",", "", as.character(df[[i]]))) suppressWarnings(num <- as.numeric(vals)) if (sum(!is.na(num)) > 0) { df[[i]] <- num } else { df[[i]] <- vals } } if (grepl("dept", nm)) { x <- trim_text(df[[i]]) x <- ifelse(is.na(x), x, tools::toTitleCase(tolower(x))) df[[i]] <- x }
} is_blank_row <- apply(df, 1, function(r) all(is.na(r) | trimws(as.character(r)) == ""))
blank_rows_removed <- sum(is_blank_row)
if (blank_rows_removed > 0) df <- df[!is_blank_row, , drop = FALSE] dup_rows <- duplicated(df)
duplicates_removed <- sum(dup_rows)
if (duplicates_removed > 0) df <- df[!dup_rows, , drop = FALSE] # make write safer for openxlsx by converting unsupported columns
for (i in seq_along(df)) { if (inherits(df[[i]], c("POSIXlt", "list"))) { df[[i]] <- as.character(df[[i]]) }
} write_mode <- "xlsx"
write_error <- NULL tryCatch({ wb <- createWorkbook() addWorksheet(wb, "Cleaned_Data") writeData(wb, "Cleaned_Data", df, colNames = TRUE, rowNames = FALSE) saveWorkbook(wb, output_xlsx, overwrite = TRUE)
}, error = function(e) { write_mode <<- "csv" write_error <<- conditionMessage(e) write.csv(df, output_csv, row.names = FALSE, na = "")
}) report_lines <- c( paste("Input file:", input_file), paste("Original rows:", original_rows), paste("Final rows:", nrow(df)), paste("Blank rows removed:", blank_rows_removed), paste("Duplicate rows removed:", duplicates_removed), paste("Original columns:", paste(original_names, collapse = " | ")), paste("Final columns:", paste(names(df), collapse = " | ")), paste("Write mode:", write_mode), if (!is.null(write_error)) paste("XLSX write fallback reason:", write_error) else NULL, paste("Output file:", if (write_mode == "xlsx") output_xlsx else output_csv)
)
writeLines(report_lines, report_file)
cat(paste(report_lines, collapse = "\n"))
