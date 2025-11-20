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

```r
# Install devtools if not already installed
if (!require("devtools")) install.packages("devtools")

# Install adbmrio from GitHub
devtools::install_github("BallavBabu/adbmrio")
```

**Dependencies:**
- `data.table` (≥ 1.14.0)
- `Matrix` (≥ 1.5.0)
- `R` (≥ 4.0.0)

---

## 📖 Usage Examples

### 1. Basic National Decomposition

Calculate the 5-part decomposition for all sectors and countries. This returns Output ($X$), Emissions ($E$), and Value-Added ($VA$) columns.

```r
library(adbmrio)
library(data.table)

# Load data
mrio <- load_adb_mrio("path/to/ADB_MRIO_Merged_Panel_2000_2023.rds")

# Run 5-Part Decomposition for 2021
# This returns data for ALL 63 countries and 35 sectors
results <- decompose_national_5part(mrio, year = 2021)

# View China's (PRC) Electronics output breakdown
china_elec <- results[country == "PRC" & sector %like% "Electrical"]
print(china_elec[, .(sector, X_Dom_Fin, X_Exp_GVC, X_Total)])
```

---

### 2. Bilateral Trade Analysis (WWZ)

Analyze the Value-Added content of trade between China (PRC) and USA.

*Note: Track B currently calculates DVA terms only.*

```r
# Indices: PRC=8, USA=43 (Check mrio$metadata$countries for your specific indices)
bilateral <- compute_bilateral_wwz(mrio, year = 2021, s_idx = 8, r_idx = 43)

# Summarize Domestic Value Added (DVA) flows by category
summary <- bilateral[, .(
  DVA_Final_Goods   = sum(DVA_Fin),
  DVA_Intermediates = sum(DVA_Int),
  DVA_GVC_ReExports = sum(DVA_GVC1)
)]
print(summary)
```

*This output can be directly used to report DVA, FVA, and GVC-related components of PRC–USA exports in an empirical paper.*

---

### 3. Environmental Footprint (Track A)

Identify the sectors exporting the most embodied CO₂ using the National Decomposition.

```r
# National results include emissions columns starting with 'E_'
results <- decompose_national_5part(mrio, year = 2021)

# Calculate Total Embodied Carbon in Exports (Final + Int + GVC)
results[, Export_CO2 := E_Exp_Fin + E_Exp_Int + E_Exp_GVC]

# Top 5 Global Sectors by Exported Emissions
top_polluters <- results[order(-Export_CO2)][1:5]
print(top_polluters[, .(country, sector, Export_CO2)])
```

---

## 🛠 Advanced Usage: Flexible Inputs & Filtering

The package includes intelligent helpers (`resolve_country`) allowing you to use Country Codes, Numeric Indices, or a mix of both.

### Flexible Country Selection

You don't need to memorize numeric indices. You can use ISO-like codes (e.g., "PRC", "USA", "IND") directly in functions.

```r
# Option A: Using Character Codes (Recommended)
res_codes <- compute_bilateral_wwz(mrio, 2021, s_idx = "PRC", r_idx = "USA")

# Option B: Using Numeric Indices (PRC=8, USA=43)
res_nums  <- compute_bilateral_wwz(mrio, 2021, s_idx = 8, r_idx = 43)

# Option C: Mixing Types (e.g., Code for Exporter, Index for Importer)
res_mixed <- compute_bilateral_wwz(mrio, 2021, s_idx = "PRC", r_idx = 43)

# Verify results are identical
print(identical(res_codes, res_mixed)) # TRUE
```

---

### Matrix Extraction by Name

Similarly, extract specific $Z$ matrices using country codes.

```r
# Extract intermediate flows from Japan (JPN) to Korea (KOR)
z_matrix <- get_sector_to_sector_matrix(mrio, year = 2019, 
                                        exporter = "JPN", 
                                        importer = "KOR")
dim(z_matrix) # Returns 35x35 matrix
```

---

### Filtering Sectors (Name vs. Number)

Results can be filtered by full sector names or by ADB sector index (1-35).

```r
# Get results for India
ind_res <- decompose_national_5part(mrio, 2021)[country == "IND"]

# Method A: Filter by Name (using data.table's %like%)
textiles <- ind_res[sector %like% "Textiles"]

# Method B: Filter by Sector Number (1-35)
# Add an ID column to map 1:35 to the rows
ind_res[, Sector_ID := 1:.N] 
food_sector <- ind_res[Sector_ID == 3] # Sector 3 is Food & Bev

print(food_sector[, .(Sector_ID, sector, X_Total)])
```

---

### 4. Data Validation & Gross Exports

The package includes tools to verify the Leontief identity ($X = BY$) and calculate baseline gross exports before performing complex decompositions.

#### A. Check Leontief Inverse Consistency

Verify that the calculated output matches observed output to ensure data integrity.

```r
# Calculate Global Gross Output using the Leontief Inverse (B)
# Checks the identity: X_calculated = B * Y
identity_check <- calculate_gross_output_identity(mrio, year = 2021)

# View the difference between Calculated and Observed Output
# Small floating-point differences are expected
print(summary(identity_check$diff))

# Identify any sectors with significant deviations
outliers <- identity_check[abs(diff) > 1e-4]
print(outliers)
```

#### B. Calculate Total Gross Exports

Compute total exports ($EX_{sr} = A_{sr}X_r + Y_{sr}$) for every country-sector to the rest of the world.

```r
# Calculate Total Gross Exports (Eq. 5)
gross_exports <- calculate_total_exports_eq5(mrio, year = 2021)

# Compare Top Exporting Sectors in Vietnam (VNM)
vnm_exports <- gross_exports[country == "VNM"][order(-total_exports_eq5)]
print(vnm_exports[1:5, .(sector, total_exports_eq5)])
```

---

### 5. Supply Chain Inspection (Matrix Extraction)

For granular analysis, you can extract the specific $N \times N$ input-output matrix ($Z$) between two economies to analyze direct technical flows.

```r
# Scenario: Analyze how much Australian (AUS) inputs go into Chinese (PRC) production

# Extract the 35x35 transaction matrix from AUS -> PRC
# Uses flexible country codes
z_aus_prc <- get_sector_to_sector_matrix(mrio, year = 2021, 
                                         exporter = "AUS", 
                                         importer = "PRC")

# The matrix rows are Exporter Sectors (AUS); Columns are Importer Sectors (PRC)
# Example: How much 'Mining and Quarrying' from AUS is used by 'Basic Metals' in PRC?

# Note: Row/Col names format is "Country_Sector"
val <- z_aus_prc["AUS_Mining and Quarrying", "PRC_Basic Metals"]

print(paste("Direct flow from AUS Mining to PRC Basic Metals:", round(val, 2)))
```

---

## 📋 Planned Updates

Planned enhancements include:

1. Integration of pre-2017 CO₂ emission datasets, subject to ADB data availability.
2. Additional decomposition frameworks such as Koopman–Wang–Wei (KWW) and Borin–Mancini (BM), where compatible with ADB MRIO.
3. Convenience functions for visualization of GVC position and network structure.
4. Parallel computation support for large-scale bilateral decomposition workflows.

*Note: Full-year bilateral calculations are computationally intensive. Users may want to subset countries or sectors when exploring new research ideas.*

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
