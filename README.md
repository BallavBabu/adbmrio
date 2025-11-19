# adbmrio: ADB MRIO Analysis for Global Value Chain Decomposition

The `adbmrio` package is a specialized tool for analyzing Asian Development Bank (ADB) Multi-Regional Input-Output (MRIO) tables. It performs detailed bilateral and national decomposition following the **Wang-Wei-Zhu (WWZ) framework** to isolate trade and economic variables driven by Global Value Chains (GVCs).

### 📐 Key Dimensions and Country Indices

This package is hardcoded for the ADB MRIO structure:
* **S** (Countries): 63
* **N** (Sectors): 35
* **FD** (Final Demand categories): 5 per country
* **Total Dimension (GN):** 2205 (63 × 35)

| Country | Index |
| :--- | :--- |
| **PRC (China)** | **8** |
| **IND (India)** | **22** |
| **USA (United States)** | **43** |
| RoW (Rest of World) | 63 |

### 🚀 Quick Start Example

This assumes you have your ADB MRIO data saved as an RDS file.

```r
# 1. Install the package (Assuming you are in the directory containing 'adbmrio')
# library(devtools)
# devtools::install("adbmrio")

library(adbmrio)
library(data.table)

# CRITICAL: Replace this with the actual path to your ADB MRIO RDS file.
file_path <- "~/path/to/ADB_MRIO_Panel_2017_2023_with_CO2.rds" 

# 2. Load and validate data
mrio <- load_adb_mrio(file_path) 

# 3. Compute Bilateral Decomposition (PRC (8) to USA (43) for 2020)
# This requires running bilateral decomposition for *all* 63*62 pairs 
# to calculate national totals in the next step.
# For quick testing, run only the required pair:
result_bilateral <- compute_bilateral(mrio, year = 2020, exporter = 8, importer = 43)

# 4. Aggregate to total (Example: sum exports by sector)
total_exports_prc_usa <- result_bilateral[, .(
  Total_Exports = sum(EX_direct),
  Final_Goods = sum(Tf),
  GVC_Exports = sum(Tg),
  Embodied_CO2 = sum(EEX_direct),
  Embodied_VA = sum(VAX_direct),
  Max_Diff_Check = max(abs(EX_diff))
)]

print(total_exports_prc_usa)