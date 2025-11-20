# Detailed Bilateral WWZ Decomposition (Micro Analysis)

Decomposes the **Domestic Value Added (DVA)** content of bilateral
exports from a source country (\$s\$) to a reporting country (\$r\$)
using the Wang-Wei-Zhu (WWZ) framework.

## Usage

``` r
compute_bilateral_wwz(mrio_panel, year, s_idx, r_idx)
```

## Arguments

- mrio_panel:

  The list object loaded via
  [`load_adb_mrio`](https://ballavbabu.github.io/adbmrio/reference/load_adb_mrio.md).

- year:

  Integer. Year to analyze.

- s_idx:

  Exporter identifier. Can be a numeric index (e.g., `8`) or character
  code (e.g., `"PRC"`).

- r_idx:

  Importer identifier. Can be a numeric index (e.g., `43`) or character
  code (e.g., `"USA"`).

## Value

A `data.table` containing sector-level DVA terms for the specified pair.

## Details

Unlike standard gross export data, this function isolates the value
originating strictly from the source country. It calculates:

- **DVA_Fin**: DVA embodied in Final Goods exports (\$T_f\$).

- **DVA_Int**: DVA embodied in Intermediate exports absorbed by the
  importer (\$T_i\$).

- **DVA_GVC1**: DVA embodied in re-exported intermediates (GVC trade)
  (\$T_g1\$).
