# Gross Output Identity Check (Validation)

Verifies the fundamental Leontief identity \\X = B \times Y\\. This
function is primarily used for data validation to ensure the inverse
matrix (\$B\$) is consistent with the observed output (\$X\$).

## Usage

``` r
calculate_gross_output_identity(mrio_panel, year)
```

## Arguments

- mrio_panel:

  MRIO data object.

- year:

  Year to analyze.

## Value

A `data.table` comparing calculated vs. observed output, including a
`diff` column.
