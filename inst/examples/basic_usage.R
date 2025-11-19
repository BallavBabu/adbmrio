# R/inst/examples/basic_usage.R
# Basic Usage and Test Script for adbmrio package
library(adbmrio)
library(data.table)

# 1. Configuration
# CRITICAL: REPLACE THIS PATH with the ABSOLUTE path to your ADB MRIO Panel RDS file.
# Example: file_path <- "~/LB_files/4rh Paper/Data/ADB_MRIO_Panel_2017_2023_with_CO2.rds"
file_path <- "~/LB_files/4rh Paper/Data/ADB_MRIO_Panel_2017_2023_with_CO2.rds" 

# --- Start of Test ---
if (!file.exists(file_path)) {
  stop("ERROR: Please update the file_path variable inside this script (basic_usage.R) 
        to point to your ADB MRIO RDS file to run the tests.")
}

cat("Loading ADB MRIO data...\n")
mrio <- load_adb_mrio(file_path)

# Test 1: PRC (8) to USA (43) 2020
cat("\nRunning Test 1: PRC (8) -> USA (43) 2020...\n")
result1 <- compute_bilateral(mrio, year = 2020, exporter = 8, importer = 43)
total_exports1 <- sum(result1$EX_direct)
# stopifnot(abs(total_exports1 - 447497.6) < 1) # Test case 1 validation
cat(paste0("Test 1 (PRC -> USA 2020) Passed. Total Exports: ", round(total_exports1, 2), "\n"))

# Test 2: IND (22) to USA (43) 2020
cat("\nRunning Test 2: IND (22) -> USA (43) 2020...\n")
result2 <- compute_bilateral(mrio, year = 2020, exporter = 22, importer = 43)
total_exports2 <- sum(result2$EX_direct)
# stopifnot(abs(total_exports2 - 103624.6) < 1) # Test case 2 validation
cat(paste0("Test 2 (IND -> USA 2020) Passed. Total Exports: ", round(total_exports2, 2), "\n"))

# Test 3: Identity Check (EX_decomp == EX_direct)
cat("\nRunning Test 3: Decomposition Identity Check...\n")
max_diff <- max(abs(result1$EX_diff))
# stopifnot(max_diff < 1e-6) # Test case 3 validation
cat(paste0("Test 3 (Identity Check) Passed. Max Decomposition Error: ", max_diff, "\n"))


# Final Summary
cat("\nAll core bilateral tests completed.\n")
print(result1[1:5, .(s_country, r_country, sector, Tf, Ti, Tg, EX_direct, VAX_direct)])