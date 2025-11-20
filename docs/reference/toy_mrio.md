# Toy MRIO Model (4 Countries, 3 Sectors)

A simplified Multi-Regional Input-Output (MRIO) dataset for testing and
learning. This dataset replicates the structure of the full ADB MRIO
panel but with reduced dimensions (4 regions x 3 sectors). It includes
data for the year 2023.

## Usage

``` r
data(toy_mrio)
```

## Format

A list with the standard `adbmrio` structure:

metadata

:   List containing `countries` and `sectors`.

years

:   List containing the "2023" data object:

## Details

The dataset contains 4 regions: China, India, Japan, and ROW (Rest of
World). The 3 sectors are: Primary, Manufacturing, and Service. Note:
The Final Demand (Y) matrix has been structured with 5 columns per
country (20 columns total) to match the package's internal logic, though
the toy data aggregates demand into the first column of each country
block.
