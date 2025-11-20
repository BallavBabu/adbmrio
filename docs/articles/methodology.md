# Methodology: GVC Decomposition with adbmrio

## Introduction

The `adbmrio` package provides a streamlined toolkit for analyzing
Global Value Chains (GVCs) using the Asian Development Bank
Multi-Regional Input-Output (ADB MRIO) tables. This vignette explains
the mathematical framework behind the two primary decomposition methods
implemented in the package: the **National 5-Part Decomposition** (Zhang
et al., 2017) and the **Bilateral WWZ Decomposition** (Wang et al.,
2013).

We demonstrate these methods using the built-in `toy_mrio` dataset (4
countries, 3 sectors).

## 1. Fundamental Framework

Consider a world with $`G`$ countries and $`N`$ sectors. The global
input-output system is defined by the standard Leontief equation:

``` math

X = (I - A)^{-1} Y = B Y
```

Where:

- $`X`$: $`GN \times 1`$ vector of Gross Output.
- $`A`$: $`GN \times GN`$ matrix of technical coefficients (Direct
  requirements).
- $`Y`$: $`GN \times G`$ matrix of Final Demand (aggregated by
  destination country).
- $`B`$: The Global Leontief Inverse ($`B = (I-A)^{-1}`$).

### Local vs. Global Leontief

A critical distinction in GVC analysis is between the **Global Leontief
Inverse** ($`B`$) and the **Domestic Leontief Inverse** ($`L`$).

The package calculates $`L`$ by isolating the block-diagonal elements of
$`A`$ (domestic transactions only, denoted as $`A^D`$):

``` math

L = (I - A^D)^{-1}
```

While $`B`$ captures feedback loops across the entire world, $`L`$
captures how domestic industries ripple through *only* the local
economy.

------------------------------------------------------------------------

## 2. National 5-Part Decomposition (Macro)

The function
[`decompose_national_5part()`](https://ballavbabu.github.io/adbmrio/reference/decompose_national_5part.md)
breaks down a country’s gross output (or Value Added/Emissions) into
five distinct paths of absorption. This follows the logic proposed by
Zhang et al. (2017), focusing on where production is ultimately
consumed.

For a source country $`s`$, the total output $`X_s`$ is decomposed as:

``` math

X_s = \underbrace{L_{ss} Y_{ss}}_{\text{Dom\_Fin}} + \underbrace{L_{ss} A^D_{ss} X_s^*}_{\text{Dom\_Int}} + \underbrace{L_{ss} \sum_{r \neq s} Y_{sr}}_{\text{Exp\_Fin}} + \underbrace{L_{ss} \sum_{r \neq s} A_{sr} L_{rr} Y_{rr}}_{\text{Exp\_Int}} + \underbrace{\text{Residual}}_{\text{Exp\_GVC}}
```

### The Components

1.  **Dom_Fin:** Output produced and consumed domestically as final
    goods.
2.  **Dom_Int:** Output used as intermediates to produce other domestic
    goods consumed domestically.
3.  **Exp_Fin:** Exports consumed immediately by the importer as final
    goods.
4.  **Exp_Int:** Intermediate exports used by the importer to produce
    goods for their own consumption.
5.  **Exp_GVC:** Intermediate exports that enter complex trade networks
    (re-exported to third countries or returned to the source).

### Example Usage

``` r
library(adbmrio)
library(data.table)

# Load the 4-country, 3-sector toy model
data(toy_mrio)
```

``` r
# Run the decomposition for 2023
macro_results <- decompose_national_5part(toy_mrio, 2023)

# View results for China's Manufacturing Sector
china_mfg <- macro_results[country == "China" & sector == "Manufacturing"]

# Display the 5 components of Value Added
print(china_mfg[, .(VA_Dom_Fin, VA_Dom_Int, VA_Exp_Fin, VA_Exp_Int, VA_Exp_GVC)])
#>    VA_Dom_Fin VA_Dom_Int VA_Exp_Fin VA_Exp_Int VA_Exp_GVC
#>         <num>      <num>      <num>      <num>      <num>
#> 1:    1877459    3048168     971061   734263.8   82791.12
```

------------------------------------------------------------------------

## 3. Bilateral WWZ Decomposition (Micro)

While the national decomposition looks at a country’s total output, the
[`compute_bilateral_wwz()`](https://ballavbabu.github.io/adbmrio/reference/compute_bilateral_wwz.md)
function zooms in on the trade relationship between a specific **Source
($`s`$)** and **Reporting ($`r`$)** country.

It isolates the **Domestic Value Added (DVA)** embodied in gross
exports. According to the Wang-Wei-Zhu (WWZ) framework, bilateral
exports can be traced into absorption paths:

### Mathematical Formulation used in Package

Let $`V_s`$ be the direct value-added coefficient vector for country
$`s`$. The package calculates:

1.  **DVA in Final Goods Exports ($`T_f`$):** Value added crossing the
    border as a final good.

    ``` math

    DVA\_Fin = V_s L_{ss} Y_{sr}
    ```

2.  **DVA in Intermediate Exports absorbed by Importer ($`T_i`$):**
    Value added crossing as an intermediate, processed by $`r`$, and
    consumed in $`r`$.

    ``` math

    DVA\_Int = V_s L_{ss} A_{sr} L_{rr} Y_{rr}
    ```

3.  **DVA in GVC Trade (Re-exports) ($`T_{g1}`$):** Value added that is
    re-exported by $`r`$ to third countries.

    ``` math

    DVA\_GVC = V_s L_{ss} A_{sr} \sum_{t \neq s, r} B_{rt} Y_{t}
    ```

### Example Usage

We analyze the value-added trade flow from **China (Index 1)** to
**India (Index 2)**.

``` r
# 1 = China, 2 = India
bilateral_res <- compute_bilateral_wwz(toy_mrio, 2023, s_idx = 1, r_idx = 2)

print(bilateral_res)
#>    s_index s_country r_index r_country        sector   DVA_Fin   DVA_Int
#>      <int>    <char>   <int>    <char>        <char>     <num>     <num>
#> 1:       1     China       2     India       Primary  3456.706  4741.570
#> 2:       1     China       2     India Manufacturing 22135.700 28891.225
#> 3:       1     China       2     India       Service  6897.628  9308.548
#>     DVA_GVC1
#>        <num>
#> 1:  5.802237
#> 2: 35.290019
#> 3: 11.266690
```

### Interpretation

- **DVA_Fin:** How much Chinese value added did India consume directly
  as finished Chinese goods?
- **DVA_Int:** How much Chinese value added did India import as parts,
  turn into Indian goods, and consume?
- **DVA_GVC1:** How much Chinese value added did India import, process,
  and then re-export to the rest of the world?

------------------------------------------------------------------------

## 4. Understanding the Results

### National Decomposition Output

The
[`decompose_national_5part()`](https://ballavbabu.github.io/adbmrio/reference/decompose_national_5part.md)
function returns a data.table with the following columns:

- **country:** Source country name
- **sector:** Industry sector name
- \*\*GO\_\*:\*\* Gross Output components (Dom_Fin, Dom_Int, Exp_Fin,
  Exp_Int, Exp_GVC)
- \*\*VA\_\*:\*\* Value Added components (same breakdown)
- \*\*CO2\_\*:\*\* CO2 Emissions components (same breakdown)

This allows you to answer questions like:

- What percentage of China’s manufacturing output is exported?
- How much of India’s value added comes from domestic consumption
  vs. exports?
- Which sectors are most embedded in global value chains?

### Bilateral Decomposition Output

The
[`compute_bilateral_wwz()`](https://ballavbabu.github.io/adbmrio/reference/compute_bilateral_wwz.md)
function returns a data.table with sector-level bilateral trade flows
decomposed into:

- **DVA_Fin:** Direct value added in final goods
- **DVA_Int:** Value added in intermediates absorbed by partner
- **DVA_GVC1:** Value added re-exported to third countries
- **DVA_GVC2:** Value added that returns to source country
- **FVA:** Foreign value added in exports

------------------------------------------------------------------------

## 5. Practical Applications

### Application 1: Carbon Footprint Analysis

``` r
# Analyze where China's manufacturing emissions end up
china_emissions <- macro_results[country == "China" & sector == "Manufacturing"]

# Calculate export-embodied emissions
export_emissions <- china_emissions$CO2_Exp_Fin + 
                    china_emissions$CO2_Exp_Int + 
                    china_emissions$CO2_Exp_GVC

cat("China Manufacturing Export Emissions:", round(export_emissions, 2), "units\n")
```

### Application 2: Trade Policy Analysis

``` r
# Compare bilateral trade relationships
china_india <- compute_bilateral_wwz(toy_mrio, 2023, s_idx = 1, r_idx = 2)
china_usa <- compute_bilateral_wwz(toy_mrio, 2023, s_idx = 1, r_idx = 3)

# Which trade partner has more complex value chains?
china_india_gvc_share <- sum(china_india$DVA_GVC1) / sum(china_india$DVA_Fin + china_india$DVA_Int)
china_usa_gvc_share <- sum(china_usa$DVA_GVC1) / sum(china_usa$DVA_Fin + china_usa$DVA_Int)

cat("China-India GVC Share:", round(china_india_gvc_share * 100, 1), "%\n")
cat("China-USA GVC Share:", round(china_usa_gvc_share * 100, 1), "%\n")
```

------------------------------------------------------------------------

## 6. Data Requirements

The package expects MRIO data in a specific format. The input should be
a list containing:

- **Z:** Intermediate demand matrix (country-sector by country-sector)
- **Y:** Final demand matrix (country-sector by country)
- **VA:** Value added vector (country-sector)
- **GO:** Gross output vector (country-sector)
- **CO2:** CO2 emissions vector (country-sector, optional)
- **countries:** Vector of country names
- **sectors:** Vector of sector names
- **years:** Vector of years available

The built-in `toy_mrio` dataset demonstrates this structure.

------------------------------------------------------------------------

## 7. Computational Notes

### Performance

For large MRIO tables (e.g., 63 countries × 35 sectors = 2,205
dimensions):

- National decomposition: ~5-10 seconds per year
- Bilateral decomposition: ~1-2 seconds per country-pair

### Memory Requirements

The package uses sparse matrix operations where possible, but large
inversions $`(I-A)^{-1}`$ require substantial RAM:

- Small tables (\< 500 dimensions): \< 1 GB
- Medium tables (500-1500 dimensions): 2-8 GB
- Large tables (1500-3000 dimensions): 16+ GB

------------------------------------------------------------------------

## References

1.  **Zhang, Z., Zhu, K., & Hewings, G. J. (2017).** A multi-regional
    input–output analysis of the pollution haven hypothesis from the
    perspective of global production fragmentation. *Energy Economics*,
    64, 13-23.

2.  **Wang, Z., Wei, S. J., & Zhu, K. (2013).** Quantifying
    international production sharing at the bilateral and sector levels.
    *NBER Working Paper No. 19677*.

3.  **Asian Development Bank (2024).** Multi-Regional Input-Output
    Database. Available at: <https://mrio.adbx.online/>

------------------------------------------------------------------------

## Session Info

``` r
sessionInfo()
#> R version 4.5.1 (2025-06-13)
#> Platform: aarch64-apple-darwin20
#> Running under: macOS Sequoia 15.6
#> 
#> Matrix products: default
#> BLAS:   /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRblas.0.dylib 
#> LAPACK: /Library/Frameworks/R.framework/Versions/4.5-arm64/Resources/lib/libRlapack.dylib;  LAPACK version 3.12.1
#> 
#> locale:
#> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
#> 
#> time zone: Asia/Tokyo
#> tzcode source: internal
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] data.table_1.17.8 adbmrio_0.1.0    
#> 
#> loaded via a namespace (and not attached):
#>  [1] cli_3.6.5         knitr_1.50        rlang_1.1.6       xfun_0.54        
#>  [5] textshaping_1.0.4 jsonlite_2.0.0    htmltools_0.5.8.1 ragg_1.5.0       
#>  [9] sass_0.4.10       rmarkdown_2.30    grid_4.5.1        evaluate_1.0.5   
#> [13] jquerylib_0.1.4   fastmap_1.2.0     yaml_2.3.10       lifecycle_1.0.4  
#> [17] compiler_4.5.1    fs_1.6.6          htmlwidgets_1.6.4 rstudioapi_0.17.1
#> [21] systemfonts_1.3.1 lattice_0.22-7    digest_0.6.38     R6_2.6.1         
#> [25] bslib_0.9.0       Matrix_1.7-4      tools_4.5.1       pkgdown_2.2.0    
#> [29] cachem_1.1.0      desc_1.4.3
```
