# adbmrio: Computational Framework for ADB MRIO Global Value Chain Decomposition
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://www.r-project.org/)

## 📖 Overview
The **`adbmrio`** package is an R toolbox for Global Value Chain (GVC) analysis using the **Asian Development Bank (ADB) Multi-Regional Input-Output (MRIO)** tables. It implements decomposition methods that move directly from ADB MRIO data to bilateral and national indicators of production sharing, embodied CO₂, and value-added flows across countries and sectors.

This package implements a **Two-Track Approach**:

1. **Track A (Macro)**: National 5-part decomposition of Gross Output, Value-Added, and CO₂ emissions for each country and sector.
2. **Track B (Micro)**: Bilateral export decomposition based on the Wang–Wei–Zhu (WWZ) framework, including DVA, FVA, and GVC-related terms.

### Key Features
- **Bilateral Export Decomposition**: Decompose gross bilateral exports into domestic value-added, foreign value-added, and double-counting components following the Wang–Wei–Zhu (WWZ) framework.
- **National Aggregation**: Compute forward linkages and total GVC participation at the country level (5-Part Model).
- **Environmental Accounting**: Calculate embodied CO₂ emissions in trade flows.
- **Value-Added Analysis**: Trace value-added content across global production networks (DVA vs FVA).
- **Sectoral Granularity**: Full support for 35 sectors across 63 economies.
- **Matrix Extraction Tools**: Extract raw Input-Output ($Z$) matrices for specific country pairs.
- **Performance Optimized**: Sparse matrix algebra and block-wise operations for efficient computation.

### Objectives
1. Provide analytical tools for bilateral and national GVC decomposition using ADB MRIO data.
2. Generate quantitative indicators of GVC participation, positioning, and embodied emissions.
3. Support climate-related trade studies through embodied CO₂ calculations in exports and imports.
4. Facilitate reproducible MRIO-based empirical research by standardizing data structures and functions.

---

## 📚 Methodological Framework
This package implements decomposition methodologies grounded in the following theoretical frameworks:

### Primary Literature
**Main Decomposition Framework:**
- **Zhang, Z., Zhu, K., & Hewings, G. J. D. (2017).** "A multi-regional input–output analysis of the pollution haven hypothesis from the perspective of global production fragmentation." *Energy Economics*, 64, 13-23. DOI: [10.1016/j.eneco.2017.03.007](https://doi.org/10.1016/j.eneco.2017.03.007)

**Foundational GVC Decomposition Theory:**
- **Wang, Z., Wei, S. J., & Zhu, K. (2013).** "Quantifying International Production Sharing at the Bilateral and Sector Levels." *NBER Working Paper No. 19677*
- **Wang, Z., Wei, S. J., Yu, X., & Zhu, K. (2018).** "Characterizing Global Value Chains: Production Length and Upstreamness." *NBER Working Paper No. 23261*

Track A follows the production extension ideas in Zhang et al. (2017) for national decomposition, and Track B follows the bilateral decomposition logic of Wang et al. (2013, 2018).

**Notation**: In this documentation, $B$ denotes the global Leontief inverse and $L_{ss}$ its domestic block for country $s$.

---

### Track A: National 5-Part Decomposition (Macro-Level Analysis)

This decomposition partitions total gross output into domestic final, domestic intermediate, and three export-oriented components, which can be aggregated to national indicators of GVC orientation.

The package decomposes total Gross Output ($X_s$) for every country-sector into five distinct components:

$$X_s = \underbrace{Y_{ss}}_{\substack{\text{1. Domestic} \\ \text{Final}}} + \underbrace{A_{ss}L_{ss}Y_{ss}}_{\substack{\text{2. Domestic} \\ \text{Intermediate}}} + \underbrace{L_{ss}T_f}_{\substack{\text{3. Export} \\ \text{Final}}} + \underbrace{L_{ss}T_i}_{\substack{\text{4. Export} \\ \text{Intermediate}}} + \underbrace{L_{ss}T_g}_{\substack{\text{5. Export} \\ \text{GVC}}}$$

**Where:**
1. **Domestic Final** ($Y_{ss}$): Goods produced and consumed domestically as final demand.
2. **Domestic Intermediate** ($A_{ss}L_{ss}Y_{ss}$): Goods produced and consumed domestically as intermediate inputs.
3. **Export Final** ($L_{ss}T_f$): Domestic value-added embodied in final goods exports.
4. **Export Intermediate** ($L_{ss}T_i$): Domestic value-added embodied in intermediate exports absorbed by direct importers.
5. **Export GVC** ($L_{ss}T_g$): Domestic value-added embodied in intermediates that cross borders multiple times (complex GVCs).

**Research Applications:**
- Measure GVC participation rates at the national level
- Assess domestic versus export orientation of production
- Track structural transformation in production networks over time
- Compare GVC integration across countries and sectors

---

### Track B: Bilateral Export Decomposition (Micro-Level Analysis)

For specific country pairs ($s \rightarrow r$), gross bilateral exports are decomposed into three primary terms based on the Wang-Wei-Zhu (WWZ) framework:

$$EX_{sr} = Y_{sr} + A_{sr}X_r = T_f + T_i + T_g$$

**Where:**
- **$T_f$ (Final Goods Exports)**: Direct exports consumed in the importing country.
  $$T_f = Y_{sr}$$
  
- **$T_i$ (Traditional Intermediate Exports)**: Intermediate goods absorbed by the importer for domestic production.
  $$T_i = A_{sr} L_{rr} Y_{rr}$$
  
- **$T_g$ (GVC-Related Trade)**: Intermediate exports that are reflected back to the source country or re-exported to third countries (complex cross-border value chains).
  $$T_g = A_{sr}L_{rr} \sum_{t \neq r} (A_{rt} B_{tr} Y_{rr}) + A_{sr} \sum_{t \neq r} (B_{rt} Y_{tr}) + A_{sr} \sum_{t} B_{rt} \sum_{u \neq r} Y_{tu}$$

### GVC Components ($T_g$ Decomposition)

The GVC-related trade term ($T_g$) captures complex cross-border supply chain linkages and can be further decomposed into three components:

- **$TG1$ (Feedback Loops)**: Value added that returns to the source country $s$ or is absorbed domestically in $r$ after crossing borders.
- **$TG2$ (Third-Country Final Demand)**: Goods re-exported by $r$ to third country $t$ for final consumption.
- **$TG3$ (Third-Country Intermediate Use)**: Goods re-exported by $r$ to $t$ for further production, then exported to ultimate destination $u$.

*Full algebraic derivations of $TG1$, $TG2$, and $TG3$ are provided in the package vignette.*

**Research Applications:**
- Analyze bilateral trade relationships and value chain linkages
- Identify feedback loops and re-export patterns
- Quantify third-country participation in bilateral trade
- Assess bilateral trade imbalances in value-added terms

---

### Embodied Emissions & Value Added

The package calculates the environmental and economic footprint embodied in trade flows using the Leontief production extension model. For any export component $Q$ (e.g., $Q = T_f$, $T_i$, or $T_g$):

$$EEX_{sr}^Q = \hat{e}_s (L_{ss} Q) \quad \text{and} \quad VAX_{sr}^Q = \hat{v}_s (L_{ss} Q)$$

**Where:**
- $\hat{e}_s$: Diagonalized vector of direct CO₂ emission intensity coefficients for country $s$.
- $\hat{v}_s$: Diagonalized vector of direct value-added coefficients for country $s$.
- $L_{ss}$: Domestic Leontief inverse matrix.

**Research Applications:**
- Carbon footprint analysis of trade flows
- Pollution haven hypothesis testing
- Carbon leakage assessment
- Value-added accounting in bilateral and multilateral trade

---

## 📊 Data Source & Structure

### ADB MRIO Tables
This package is designed to process the **Asian Development Bank (ADB) Multi-Regional Input-Output (MRIO) Tables** and **Environmentally Extended MRIO Tables (EE-MRIOTs)**.

The panel is built from the ADB MRIO release as of 2024. Users should refer to the ADB MRIO documentation for details on construction and any future updates.

**Coverage:**
- **Economies**: 63 countries/regions (see `?country_codes`)
- **Sectors**: 35 ISIC Rev.4 Sectors (see `?sector_codes`)
- **Years**: 2000 – 2023
- **CO₂ Emissions**: Available from 2017–2023

**Note**: For 2000–2016, CO₂ variables are zero-filled placeholders included only to keep the panel structure consistent. Emission analysis should be restricted to 2017–2023 unless users load external emission data.

### Key Dimensions
- **S** = 63 countries/economies
- **N** = 35 sectors per country (ISIC Rev. 4-based classification)
- **GN** = 2,205 total sectors (63 × 35)
- **FD_per_country** = 5 final demand categories per absorbing country

### Country Codes
The ADB MRIO includes 63 economies with the following country codes:
```r
[1]  "AUS" "AUT" "BEL" "BGR" "BRA" "CAN" "SWI" "PRC" "CYP" "CZE" "GER" "DEN" 
[13] "SPA" "EST" "FIN" "FRA" "UKG" "GRC" "HRV" "HUN" "INO" "IND" "IRE" "ITA"
[25] "JPN" "KOR" "LVA" "LTU" "LUX" "MLT" "MEX" "NLD" "NOR" "POL" "PRT" "ROU"
[37] "RUS" "SVK" "SVN" "SWE" "TUR" "TWN" "USA" "ARG" "KHM" "HKG" "LAO" "MYA"
[49] "PAK" "PHL" "SGP" "THA" "VNM" "BGD" "FIJ" "MNG" "NPL" "NZL" "PNG" "SRI"
[61] "BRN" "MAS" "RoW"
```

### Key Country Indices
| Country                | Code | Index | Notes                          |
|:-----------------------|:-----|:------|:-------------------------------|
| **China**              | PRC  | **8** | People's Republic of China     |
| **India**              | IND  | **22**| Republic of India              |
| **United States**      | USA  | **43**| United States of America       |
| **Japan**              | JPN  | **25**| Major Asian economy            |
| **South Korea**        | KOR  | **26**| Republic of Korea              |
| **Germany**            | GER  | **11**| Largest EU economy             |
| **United Kingdom**     | UKG  | **17**| United Kingdom                 |
| **Rest of World**      | RoW  | **63**| Aggregate of remaining economies|

*Note: Complete country and sector mapping tables are included in the package documentation and can be accessed via `?adbmrio::country_codes` and `?adbmrio::sector_codes`.*

---

## 📥 Data Access & Download

To facilitate immediate research use, a pre-harmonized **Master Panel Dataset** combining historical ADB MRIO tables with environmentally extended tables is provided.

### Dataset: ADB_MRIO_Merged_Panel_2000_2023.rds

| Attribute       | Description                                                                                           |
|:----------------|:------------------------------------------------------------------------------------------------------|
| Time Period     | 2000 – 2023 (Annual)                                                                                  |
| Valuation       | Constant Prices (Real Terms)                                                                          |
| Economic Data   | Available for all years (2000–2023)                                                                   |
| Emission Data   | Real data for 2017–2023; Zero placeholders for 2000–2016 to ensure compatibility                     |
| File Format     | R Data Serialization (.rds), compressed                                                               |

📥 **Download Link**: [Pre-processed MRIO Panel via Zenodo](https://zenodo.org/records/17648887)

---

### 🗂 Dataset Structure & Variable Definitions

The `ADB_MRIO_Merged_Panel_2000_2023.rds` file contains a large list object named `mrio_panel`. The data is organized hierarchically by year. Below is a summary of key variables available for each year.

#### Core Matrices
- **Z** (dgCMatrix | 2205 × 2205): Intermediate consumption matrix
- **X** (numeric | 2205): Total Gross Output vector
- **Y** (dgCMatrix | 2205 × 315): Final demand matrix
- **VA_raw** (matrix | 2205 × 1): Total Value Added vector

#### Coefficients
- **A** (dgCMatrix | 2205 × 2205): Technical Coefficient Matrix ($Z \cdot \hat{x}^{-1}$)
- **B** (dgCMatrix | 2205 × 2205): Global Leontief Inverse Matrix $(I - A)^{-1}$
- **A_D / A_F** (dgCMatrix): Domestic vs. Foreign input coefficients
- **B_D / B_F** (dgCMatrix): Local vs. Foreign Leontief blocks
- **VA_coeff** (numeric | 2205): Value-added intensity coefficients
- **VA_diag** (ddiMatrix | 2205 × 2205): Diagonalized value-added matrix

#### Block Matrices (Country-Level Subsets)
- **L_blocks** (list): Domestic Leontief inverse matrices ($L_{ss}$) for all 63 countries
- **A_blocks** (list): Domestic technical coefficient matrices ($A_{ss}$) for all countries

#### Environmental Accounts
- **CO2_raw** (dgCMatrix | 2205 × 1): Total CO₂ emissions by sector (sparse)
- **CO2_coeff** (dgCMatrix | 2205 × 1): Emission intensities (sparse)
- **CO2_diag** (ddiMatrix | 2205 × 2205): Diagonalized emission matrix

A complete list of objects in `mrio_panel[[year]]` is provided in the package help (`?mrio_panel_structure`) and vignette.

---

## 🚀 Installation

### Step 1: Install Package from GitHub
```r
# Install devtools if not already installed
if (!require("devtools")) install.packages("devtools")

# Install adbmrio from GitHub
devtools::install_github("BallavBabu/adbmrio")
```

### Step 2: Download ADB MRIO Data
Download the pre-processed MRIO panel dataset from Zenodo:

📥 **[Download ADB MRIO Panel (2000-2023)](https://zenodo.org/records/17648887)**

Save the `.rds` file to your local directory and note the file path for use in the examples below.

### Dependencies
The package requires the following R packages:
- `data.table` (≥ 1.14.0)
- `Matrix` (≥ 1.5.0)
- `R` (≥ 4.0.0)

---

## 📖 Usage Examples

Below is a comprehensive example script demonstrating the core functionalities of the `adbmrio` package. This script covers:
1. Loading Data
2. Track A: National & Sectoral Decomposition (5-Part Model)
3. Track B: Bilateral Trade Analysis (WWZ Framework)
4. Environmental Analysis (CO₂ Emissions)
5. Time-Series Analysis

### Complete Example Script

```r
# ==============================================================================
# adbmrio: COMPREHENSIVE EXAMPLE SCRIPT
# ==============================================================================
# This script demonstrates the core functionalities of the 'adbmrio' package:
# 1. Loading Data
# 2. Track A: National & Sectoral Decomposition (5-Part Model)
# 3. Track B: Bilateral Trade Analysis (WWZ Framework)
# 4. Environmental Analysis (CO2 Emissions)
# 5. Time-Series Analysis
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. SETUP & DATA LOADING
# ------------------------------------------------------------------------------
library(adbmrio)
library(data.table)

# Define path to your local MRIO .rds file
# NOTE: Users should adjust this path to their own data location
mrio_path <- "path/to/ADB_MRIO_Merged_Panel_2000_2023.rds"

cat("Loading ADB MRIO Panel Data...\n")
mrio_data <- load_adb_mrio(mrio_path)

# ------------------------------------------------------------------------------
# EXAMPLE 1: SECTOR-LEVEL DECOMPOSITION (TRACK A)
# Goal: Analyze GVC participation for specific sectors in a specific year.
# ------------------------------------------------------------------------------
target_year <- 2021

cat(paste0("\n--- Running 5-Part Decomposition for ", target_year, " ---\n"))

# This function calculates the 5 terms for ALL sectors in ALL countries
national_results <- decompose_national_5part(mrio_data, year = target_year)

# Filter: Analyze China's (PRC) Electronics Sector
# We look for sectors containing "Electrical"
china_electronics <- national_results[country == "PRC" & sector %like% "Electrical"]

cat("\n[Sector Analysis] PRC Electronics Breakdown:\n")
print(china_electronics[, .(sector, X_Dom_Fin, X_Dom_Int, X_Exp_GVC, X_Total)])

# Calculate 'GVC Participation Rate' (GVC Exports / Total Output)
china_electronics[, GVC_Rate := (X_Exp_GVC / X_Total) * 100]
cat(paste0("GVC Participation Rate: ", round(china_electronics$GVC_Rate, 2), "%\n"))

# ------------------------------------------------------------------------------
# EXAMPLE 2: COUNTRY-LEVEL AGGREGATION
# Goal: Aggregate sector data to see macroeconomic trends (GDP/Export shares).
# ------------------------------------------------------------------------------
cat("\n--- Aggregating to Country Level ---\n")

country_summary <- national_results[, .(
  # Summing Gross Output components
  Total_Output  = sum(X_Total),
  Total_Exports = sum(X_Exp_Fin + X_Exp_Int + X_Exp_GVC),
  GVC_Exports   = sum(X_Exp_GVC),
  
  # Summing Value Added (GDP contribution)
  Total_VA      = sum(VA_Total)
), by = country]

# Compare Major Economies
target_economies <- c("PRC", "USA", "IND", "JPN", "GER")
comparison <- country_summary[country %in% target_economies]

# Calculate Export dependence
comparison[, Export_Share_of_Output := (Total_Exports / Total_Output) * 100]

print(comparison[, .(country, Total_Output, Total_Exports, Export_Share_of_Output)])

# ------------------------------------------------------------------------------
# EXAMPLE 3: BILATERAL TRADE ANALYSIS (TRACK B)
# Goal: Analyze the detailed trade relationship between two countries (WWZ).
# ------------------------------------------------------------------------------
# Indices: PRC = 8, USA = 43 (Check mrio_data$metadata$countries for indices)
exporter_idx <- 8   # PRC
importer_idx <- 43  # USA

cat(paste0("\n--- Running Bilateral WWZ: PRC (", exporter_idx, ") -> USA (", 
           importer_idx, ") ---\n"))

bilateral_res <- compute_bilateral_wwz(mrio_data, year = 2021, 
                                       s_idx = exporter_idx, 
                                       r_idx = importer_idx)

# Show top 5 sectors by "Domestic Value Added in Intermediate Exports" (DVA_Int)
top_sectors <- bilateral_res[order(-DVA_Int)][1:5]

cat("Top 5 Sectors sending Intermediate Value-Added to USA:\n")
print(top_sectors[, .(sector, DVA_Int, DVA_Fin, DVA_GVC1)])

# Note: This output can be directly used to report DVA, FVA, and GVC-related 
# components of PRC–USA exports in an empirical paper.

# ------------------------------------------------------------------------------
# EXAMPLE 4: ENVIRONMENTAL LINKAGES (CO2)
# Goal: Identify which sectors export the most Embodied Carbon.
# ------------------------------------------------------------------------------
cat("\n--- Environmental Analysis: Embodied Carbon in Exports ---\n")

# Filter for India (IND)
india_res <- national_results[country == "IND"]

# Calculate Total Embodied Carbon in Exports
india_res[, Export_CO2 := E_Exp_Fin + E_Exp_Int + E_Exp_GVC]

# Sort by dirtiest export sectors
top_polluters <- india_res[order(-Export_CO2)][1:5]

cat("Top 5 Indian Sectors by Embodied CO2 in Exports:\n")
print(top_polluters[, .(sector, Export_CO2, E_Total)])

# ------------------------------------------------------------------------------
# EXAMPLE 5: TIME-SERIES LOOP
# Goal: Track the evolution of Global GVC Volume over time.
# ------------------------------------------------------------------------------
cat("\n--- Running Time-Series Analysis (2017-2021) ---\n")

years <- 2017:2021
history_list <- list()

for (y in years) {
  # Run decomposition silently
  res <- decompose_national_5part(mrio_data, y)
  
  # Calculate Global GVC Volume (Sum of X_Exp_GVC across all countries)
  global_gvc_vol <- sum(res$X_Exp_GVC)
  
  history_list[[as.character(y)]] <- data.table(Year = y, 
                                                 Global_GVC_Volume = global_gvc_vol)
}

history_dt <- rbindlist(history_list)
print(history_dt)

cat("\nDone.\n")
```

### Quick Start Examples

#### Example 1: Basic National Decomposition
```r
library(adbmrio)
library(data.table)

# Load data
mrio <- load_adb_mrio("path/to/ADB_MRIO_Merged_Panel_2000_2023.rds")

# Run 5-Part Decomposition for 2021
results <- decompose_national_5part(mrio, year = 2021)

# View China's results
china_results <- results[country == "PRC"]
print(china_results[, .(sector, X_Total, X_Exp_GVC, VA_Total)])
```

#### Example 2: Bilateral Trade Analysis
```r
# Analyze China → USA trade
bilateral <- compute_bilateral_wwz(mrio, year = 2021, s_idx = 8, r_idx = 43)

# Summarize by trade component
summary <- bilateral[, .(
  Total_Exports = sum(EX_direct),
  Final_Goods = sum(Tf),
  Traditional_Intermediates = sum(Ti),
  GVC_Related = sum(Tg)
)]
print(summary)
```

#### Example 3: Environmental Footprint
```r
# Get national results with emissions
results <- decompose_national_5part(mrio, year = 2021)

# Calculate carbon intensity of exports
results[, Carbon_Intensity := (E_Exp_Fin + E_Exp_Int + E_Exp_GVC) / 
                                (X_Exp_Fin + X_Exp_Int + X_Exp_GVC)]

# Top 10 countries by export carbon intensity
top_carbon <- results[, .(
  Total_Export_CO2 = sum(E_Exp_Fin + E_Exp_Int + E_Exp_GVC)
), by = country][order(-Total_Export_CO2)][1:10]

print(top_carbon)
```

---

## 📋 Planned Updates

Planned enhancements include:

1. Integration of pre-2017 CO₂ emission datasets, subject to ADB data availability.
2. Additional decomposition frameworks such as Koopman–Wang–Wei (KWW) and Borin–Mancini (BM), where compatible with ADB MRIO.
3. Convenience functions for visualization of GVC position and network structure.
4. Parallel computation support for large-scale bilateral decomposition workflows.

*Note: This routine is computationally intensive for full-year bilateral calculations. Users may want to subset countries or sectors when exploring new research ideas.*

---

## 📄 License
This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing
Contributions, bug reports, and feature requests are welcome! Please feel free to:
- Open an issue on GitHub
- Submit a pull request
- Contact the maintainer for collaboration opportunities

---

## 📧 Contact & Citation

**Package Maintainer**: Lila Ballav Bhusal  
**GitHub**: [BallavBabu/adbmrio](https://github.com/BallavBabu/adbmrio)

### Citation
If you use this package in your research, please cite:
```
Bhusal, L.B. (2025). adbmrio: Computational Framework for ADB MRIO Global Value Chain Decomposition. 
R package version 0.1.0. https://github.com/BallavBabu/adbmrio
```

---

## 📚 References

Zhang, Z., Zhu, K., & Hewings, G. J. D. (2017). A multi-regional input–output analysis of the pollution haven hypothesis from the perspective of global production fragmentation. *Energy Economics*, 64, 13-23. https://doi.org/10.1016/j.eneco.2017.03.007

Wang, Z., Wei, S. J., & Zhu, K. (2013). *Quantifying International Production Sharing at the Bilateral and Sector Levels* (NBER Working Paper No. 19677). National Bureau of Economic Research.

Wang, Z., Wei, S. J., Yu, X., & Zhu, K. (2018). *Characterizing Global Value Chains: Production Length and Upstreamness* (NBER Working Paper No. 23261). National Bureau of Economic Research.

Asian Development Bank. (2024). *Multi-Regional Input-Output Tables*. Available at: https://mrio.adbx.online/

---

## ⚠️ Disclaimer
This package is an independent research tool and is not officially affiliated with or endorsed by the Asian Development Bank (ADB). Users are responsible for ensuring compliance with ADB's data usage terms and conditions.
