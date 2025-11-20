# Load ADB MRIO Panel Data

Loads the pre-processed Asian Development Bank Multi-Regional
Input-Output (ADB MRIO) panel data from a local RDS file. It performs a
basic structure validation to ensure the file contains the required
metadata and yearly matrix objects.

## Usage

``` r
load_adb_mrio(file_path)
```

## Arguments

- file_path:

  Character string. The full path to the `.rds` file containing the
  harmonized ADB MRIO panel.

## Value

A large list containing:

metadata

:   List of `countries` (63 economies) and `sectors` (35 industries).

years

:   A list of year-specific objects (e.g., "2021"), each containing:

## Examples

``` r
if (FALSE) { # \dontrun{
mrio <- load_adb_mrio("data/ADB_MRIO_Merged_Panel_2000_2023.rds")
print(mrio$metadata$countries)
} # }
```
