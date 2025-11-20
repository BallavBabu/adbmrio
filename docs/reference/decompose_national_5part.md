# National 5-Part GVC Decomposition (Macro Analysis)

Performs a national-level decomposition of Gross Output (\$X\$), Value
Added (\$VA\$), and CO2 Emissions (\$E\$) into 5 components based on the
framework by Zhang et al. (2017).

## Usage

``` r
decompose_national_5part(mrio_panel, year)
```

## Arguments

- mrio_panel:

  The list object loaded via
  [`load_adb_mrio`](https://ballavbabu.github.io/adbmrio/reference/load_adb_mrio.md).

- year:

  Integer. The specific year to analyze (e.g., 2021).

## Value

A `data.table` with the following columns...

## Details

The function decomposes total output for every country-sector into:

- **Dom_Fin**: Production consumed domestically as final goods.

- **Dom_Int**: Production consumed domestically as intermediate goods.

- **Exp_Fin**: Exports consumed immediately by the importer (Final
  Demand).

- **Exp_Int**: Intermediate exports absorbed by the direct importer.

- **Exp_GVC**: Intermediate exports involved in complex GVCs
  (re-exports).

## Examples

``` r
if (FALSE) { # \dontrun{
# Load the built-in toy dataset
data(toy_mrio)

# Perform the decomposition for the year 2023
results <- decompose_national_5part(toy_mrio, 2023)

# Inspect results for the "Manufacturing" sector
library(data.table)
print(results[sector == "Manufacturing"])
} # }
```
