# adbmrio: Computational Framework for ADB MRIO Global Value Chain Decomposition
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![R](https://img.shields.io/badge/R-%3E%3D%204.0.0-blue.svg)](https://www.r-project.org/)

## Overview
The **`adbmrio`** package provides a comprehensive computational framework for analyzing Global Value Chains (GVCs) using the **Asian Development Bank (ADB) Multi-Regional Input-Output (MRIO)** tables. This package implements structural decomposition algorithms to quantify the intricate networks of international production sharing, embodied environmental impacts, and value-added flows across countries and sectors.

### Key Features
- **Bilateral Export Decomposition**: Decompose gross bilateral exports into domestic value-added, foreign value-added, and double-counting components following the Wang-Wei-Zhu (WWZ) framework.
- **National Aggregation**: Compute forward linkages and total GVC participation at the country level.
- **Environmental Accounting**: Calculate embodied CO₂ emissions in trade flows.
- **Value-Added Analysis**: Trace value-added content across global production networks.
- **Sectoral Granularity**: Analyze GVC participation at the sectoral level (35 sectors).
- **Matrix Extraction Tools**: Extract raw Input-Output ($Z$) matrices for specific country pairs and custom analysis.
- **Full-Year Workflow**: Automated computation of all bilateral pairs ($63 \times 62$) with national aggregation.

### Objectives
1. **Robust analytical tools** for understanding bilateral trade relationships within global value chains.
2. **Quantitative metrics** for assessing countries' GVC participation and positioning.
3. **Environmental footprint calculations** to support climate-informed trade policy analysis.
4. **Reproducible workflows** for MRIO-based empirical research.

---

## 📚 Methodological Framework
This package implements decomposition methodologies grounded in the following theoretical frameworks:

### Primary Literature
**Main Decomposition Framework:**
- **Zhang, Z., Zhu, K., & Hewings, G. J. D. (2017).** "A multi-regional input–output analysis of the pollution haven hypothesis from the perspective of global production fragmentation." *Energy Economics*, 64, 13-23. DOI: [10.1016/j.eneco.2017.03.007](https://doi.org/10.1016/j.eneco.2017.03.007)

**Foundational GVC Decomposition Theory:**
- **Wang, Z., Wei, S. J., & Zhu, K. (2013).** "Quantifying International Production Sharing at the Bilateral and Sector Levels." *NBER Working Paper No. 19677*
- **Wang, Z., Wei, S. J., Yu, X., & Zhu, K. (2018).** "Characterizing Global Value Chains: Production Length and Upstreamness." *NBER Working Paper No. 23261*

### 1. Bilateral Export Decomposition
Gross bilateral exports from country $s$ to country $r$ ($EX_{sr}$) are decomposed into three major categories based on where and how the goods are absorbed:

$$EX_{sr} = Y_{sr} + A_{sr}X_r = T_f + T_i + T_g$$

Where:
- **$T_f$ (Final Goods)**: Direct exports consumed in country *r* as final demand.
  $$T_f = Y_{sr}$$
- **$T_i$ (Traditional Intermediates)**: Intermediate inputs absorbed in *r* for domestic production that stays within *r*.
  $$T_i = A_{sr} L_{rr} Y_{rr}$$
- **$T_g$ (GVC-Related Trade)**: Intermediates that cross borders multiple times before final absorption.
  $$T_g = TG1 + TG2 + TG3$$

### 2. GVC Components ($T_g$ Decomposition)
The GVC-related trade term captures complex cross-border supply chain linkages:

- **$TG1$ (Feedback Loops)**: Value added that returns to the source country *s* or is absorbed domestically in *r* after crossing borders.
  $$TG1 = A_{sr} L_{rr} \sum_{t \neq r} (A_{rt} B_{tr} Y_{rr})$$
- **$TG2$ (Third-Country Final Demand)**: Goods re-exported by *r* to third country *t* for final consumption.
  $$TG2 = A_{sr} \sum_{t \neq r} (B_{rt} Y_{tr})$$
- **$TG3$ (Third-Country Intermediate Use)**: Goods re-exported by *r* to *t* for further production, then exported to ultimate destination *u*.
  $$TG3 = A_{sr} \sum_{t} B_{rt} \sum_{u \neq r} Y_{tu}$$

[Image of global trade network visualization]

### 3. National Aggregation (Forward Linkages)
To determine the total GVC participation of country *s*, bilateral flows are aggregated to decompose Total Gross Output ($X_s$):

$$X_s = \underbrace{L_{ss}Y_{ss}}_{\text{Domestic}} + \underbrace{L_{ss}T_{f*}}_{\text{Final Exp}} + \underbrace{L_{ss}T_{i*}}_{\text{Traditional Int}} + \underbrace{L_{ss}T_{g*}}_{\text{GVC Exp}}$$

### 4. Embodied Emissions & Value Added
The package calculates the environmental and economic footprint embodied in trade flows using the Leontief production extension model. For any export component $Q$ (e.g., $Q = T_f$):

$$EEX_{sr}^Q = \hat{e}_s (L_{ss} Q) \quad \text{and} \quad VAX_{sr}^Q = \hat{v}_s (L_{ss} Q)$$

Where:
- $\hat{e}_s$: Diagonalized vector of direct CO₂ emission intensity coefficients for country *s*.
- $\hat{v}_s$: Diagonalized vector of direct value-added coefficients for country *s*.
- $L_{ss}$: Domestic Leontief inverse matrix.

---

## 📊 Data Source & Structure

### ADB MRIO Tables
This package is designed to process the **Asian Development Bank (ADB) Multi-Regional Input-Output (MRIO) Tables** and **Environmentally Extended MRIO Tables (EE-MRIOTs)**.

**Current Data Availability:**
- **MRIO Tables**: Available for multiple years (pre-2017 to 2023)
- **CO₂ Emission Data**: Currently available from 2017 to 2023
- **Future Updates**: Earlier emission data and additional decomposition methods (Koopman, Borin & Mancini frameworks) will be incorporated in future releases

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

To facilitate immediate research use without requiring manual merging of annual files, a pre-harmonized Master Panel Dataset is provided via public download. This file combines historical ADB MRIO tables with the latest environmentally extended tables into a single, unified panel object.

### Dataset: ADB_MRIO_Merged_Panel_2000_2023.rds

| Attribute       | Description                                                                                           |
|:----------------|:------------------------------------------------------------------------------------------------------|
| Time Period     | 2000 – 2023 (Annual)                                                                                  |
| Valuation       | Constant Prices (Real Terms)                                                                          |
| Economic Data   | Available for all years (2000–2023)                                                                   |
| Emission Data   | Real data for 2017–2023; Zero placeholders for 2000–2016 to ensure compatibility                     |
| File Format     | R Data Serialization (.rds), compressed                                                               |

📥 **[Download Link: Click Here to Download Data via Dropbox]**

*(Note: Please insert the specific shared link to your Dropbox file here)*

### 🗂 Dataset Structure & Variable Definitions

The `ADB_MRIO_Merged_Panel_2000_2023.rds` file contains a large list object named `mrio_panel`. The data is organized hierarchically by year. Below is the technical specification of the variables available for every year.

#### 1. Dimensions
Basic metadata defining the size of the global economy matrix.

- **num_countries** (integer | Length: 1): 63 Economies
- **num_sectors** (numeric | Length: 1): 35 Sectors
- **total_sectors** (numeric | Length: 1): 2205 ($GN$)

#### 2. Core Matrices (The Economy)
The fundamental input-output identities.

- **Z** (dgCMatrix | Size: 2205 x 2205): Intermediate consumption matrix (Flows from Sector $i$ to Sector $j$).
- **X** (numeric | Size: 2205): Total Gross Output vector.
- **Y** (dgCMatrix | Size: 2205 x 315): Final demand matrix ($63 \text{ countries} \times 5 \text{ categories}$).
- **VA_raw** (matrix | Size: 2205 x 1): Total Value Added vector.

#### 3. Coefficients
Calculated indicators for decomposition analysis.

- **A** (dgCMatrix | Size: 2205 x 2205): Technical Coefficient Matrix ($Z \cdot \hat{x}^{-1}$).
- **B** (dgCMatrix | Size: 2205 x 2205): Global Leontief Inverse Matrix $(I - A)^{-1}$.
- **A_D / A_F** (dgCMatrix): Domestic vs. Foreign input coefficients.
- **B_D / B_F** (dgCMatrix): Local vs. Foreign Leontief blocks.
- **VA_coeff** (numeric | Size: 2205): Value-added intensity coefficients ($v = VA / X$).
- **VA_diag** (ddiMatrix | Size: 2205 x 2205): Diagonalized value-added matrix.

#### 4. Multipliers
Harmonized multiplier matrices for structural analysis.

- **L** (dgCMatrix | Size: 2205 x 2205): Domestic Leontief Inverse (Local production chains).
- **B** (dgCMatrix | Size: 2205 x 2205): Global Leontief Inverse (Same as in coefficients, repeated for convenience).

#### 5. Final Demand Decompositions
Aggregated views of final demand for easier analysis.

- **Y_D** (dgCMatrix | Size: 2205 x 315): Domestic Final Demand.
- **Y_F** (matrix | Size: 2205 x 315): Foreign Final Demand (Exports for direct consumption).
- **Y_country** (matrix | Size: 2205 x 63): Final demand aggregated by absorbing country.
- **Y_R, Y_D_R, Y_F_R** (numeric | Size: 2205): Row-summed final demand vectors.

#### 6. Trade & Verification

- **E_s** (numeric | Size: 2205): Total Gross Exports by sector.
- **verification**: Contains logic checks (LY_identity, output_identity) to ensure matrix integrity.

#### 7. Environmental Accounts (Emissions)
*Note: For years 2000–2016, these are zero-filled matrices.*

- **CO2_raw** (dgCMatrix | Size: 2205 x 1): Total CO₂ emissions by sector.
- **CO2_coeff** (dgCMatrix | Size: 2205 x 1): Emission intensities ($e = CO2 / X$).
- **CO2_diag** (ddiMatrix | Size: 2205 x 2205): Diagonalized emission matrix.

---

## 🚀 Installation
You can install the development version of `adbmrio` directly from GitHub:
```r
# Install devtools if not already installed
# install.packages("devtools")

# Install adbmrio from GitHub
devtools::install_github("BallavBabu/adbmrio")
```

### Dependencies
The package requires the following R packages:
- `data.table` (≥ 1.14.0)
- `Matrix` (≥ 1.5.0)
- `R` (≥ 4.0.0)

---

## 📖 Usage Examples

### 1. Automated Full-Year Analysis (Recommended)
The most efficient way to use the package is to run the full workflow, which calculates all bilateral pairs and aggregates them to national totals.
```r
library(adbmrio)
library(data.table)

# Step 1: Load ADB MRIO Data
# IMPORTANT: Replace with the actual path to your ADB MRIO RDS file
file_path <- "~/data/ADB_MRIO_Panel_2017_2023_with_CO2.rds"
mrio <- load_adb_mrio(file_path)

# Step 2: Run Full Analysis for 2020
# Calculates all 63×62 bilateral pairs and aggregates national totals
results_2020 <- calculate_full_year_gvc(
  mrio_panel = mrio,
  year = 2020
)

# Step 3: View National GVC Participation
# Results contain both bilateral and national aggregates
print(results_2020$national_totals)

# View specific country's forward linkages (e.g., China, index 8)
china_fwd <- results_2020$national_totals[s_index == 8]
print(china_fwd)
```

### 2. Granular Bilateral Decomposition
For analyzing specific trade relationships (e.g., China exporting to USA).
```r
# Decompose exports from China (PRC, index 8) to USA (index 43)
result_bilateral <- compute_bilateral(
  mrio_panel = mrio,
  year = 2020,
  exporter = 8,   # PRC
  importer = 43   # USA
)

# Aggregate Results by Trade Component
# Sum across all 35 sectors to get aggregate bilateral flows
summary <- result_bilateral[, .(
  Total_Exports = sum(EX_direct),
  Final_Goods = sum(Tf),
  Traditional_Intermediates = sum(Ti),
  GVC_Related = sum(Tg),
  Embodied_CO2 = sum(EEX_direct),
  Embodied_Value_Added = sum(VAX_direct),
  Max_Accounting_Diff = max(abs(EX_diff))
)]
print(summary)

# View sector-level details
print(result_bilateral[, .(sector, EX_direct, Tf, Ti, Tg)])
```

### 3. Input-Output Matrix Extraction
Extract the raw intermediate flow matrix ($Z$) between two countries for custom analysis.
```r
# Extract 35×35 sectoral flow matrix: 
# PRC Sectors (Rows) → USA Sectors (Columns)
io_matrix <- get_sector_to_sector_matrix(
  mrio_panel = mrio,
  year = 2020,
  exporter = 8,   # PRC
  importer = 43   # USA
)

# View first 5×5 block
print(io_matrix[1:5, 1:5])

# Calculate total intermediate exports from PRC manufacturing to USA services
manufacturing_to_services <- sum(io_matrix[10:25, 26:35])
print(manufacturing_to_services)
```

---

## 📋 Planned Updates
The following enhancements are planned for future releases:

1. **Extended Emission Data**: Integration of pre-2017 CO₂ emission datasets (pending ADB data availability)
2. **Alternative Decomposition Frameworks**:
   - Koopman, Wang, and Wei (KWW) decomposition
   - Borin and Mancini (BM) decomposition
3. **Visualization Tools**: Built-in functions for network diagrams and GVC position plots
4. **Performance Optimization**: Parallel computation support for large-scale bilateral decomposition

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
**Package Maintainer**: LILA BALLAV BHUSAL  
**GitHub**: [https://github.com/BallavBabu/adbmrio](https://github.com/BallavBabu/adbmrio)

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