# ==============================================================================
# adbmrio: EXAMPLES (Dual Input Support)
# ==============================================================================

library(adbmrio)
library(data.table)

# Replace with your actual file path
mrio_path <- "/Users/ballavbabu/LB_files/Data/Mrio_Mater_Data/MRIO/ADB_MRIO_Merged_Panel_2000_2023.rds"
cat("Loading ADB MRIO Panel Data...\n")
mrio <- load_adb_mrio(mrio_path)
target_year <- 2021

# ------------------------------------------------------------------------------
# TRACK B: BILATERAL ANALYSIS - METHOD 1 (Using Country Codes)
# Best for readability and scripting
# ------------------------------------------------------------------------------
cat("\n--- Method 1: Using Country Codes (Recommended) ---\n")

# Nepal (NPL) -> India (IND)
res_code <- compute_bilateral_wwz(mrio, year = target_year, 
                                  s_idx = "NPL", 
                                  r_idx = "IND")

print(res_code[1:3, .(s_country, r_country, sector, DVA_Fin)])

# ------------------------------------------------------------------------------
# TRACK B: BILATERAL ANALYSIS - METHOD 2 (Using Numeric Indices)
# Best for loops or if you already have indices
# ------------------------------------------------------------------------------
cat("\n--- Method 2: Using Numeric Indices ---\n")

# Index 60 (Nepal) -> Index 22 (India)
res_index <- compute_bilateral_wwz(mrio, year = target_year, 
                                   s_idx = 60, 
                                   r_idx = 22)

print(res_index[1:3, .(s_country, r_country, sector, DVA_Fin)])

cat("\nDone. Both methods produce identical results.\n")
