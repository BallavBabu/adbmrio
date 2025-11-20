# Calculate Total Bilateral Gross Exports

Calculates total gross exports from Country S to the world based on the
formula: \\EX\_{sr} = A\_{sr}X_r + Y\_{sr}\\.

## Usage

``` r
calculate_total_exports_eq5(mrio_panel, year)
```

## Arguments

- mrio_panel:

  MRIO data object.

- year:

  Year to analyze.

## Value

A `data.table` of total exports by sector.
