# Extract Sector-to-Sector Trade Matrix (Z)

Extracts the specific N x N block of the intermediate transaction matrix
(\$Z\$) representing direct flows from the Exporter to the Importer.

## Usage

``` r
get_sector_to_sector_matrix(mrio_panel, year, exporter, importer)
```

## Arguments

- mrio_panel:

  The MRIO data object.

- year:

  Integer. The year to analyze.

- exporter:

  Source country. Numeric Index (e.g., 8) OR Country Code (e.g., "PRC").

- importer:

  Destination country. Numeric Index (e.g., 43) OR Country Code (e.g.,
  "USA").

## Value

A sparse matrix (35 x 35) with row names formatted as
`"Country_Sector"`. Values represent flows in millions of USD (constant
prices).
