# Data files of release tables

Each table's Parquet data files, from `tables/<table>/files.json`.

## Usage

``` r
cmgd_files(rel, table = NULL)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- table:

  Table names; `NULL` for every table.

## Value

A data.frame with columns `table`, `path` (relative to the release URL),
`url`, `size` (bytes), `sha256` and `rows`.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
cmgd_files(rel, "qc_metrics")
#>        table                                      path
#> 1 qc_metrics tables/qc_metrics/data/part-00000.parquet
#>                                                                                                            url
#> 1 https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/tables/qc_metrics/data/part-00000.parquet
#>    size                                                           sha256 rows
#> 1 16845 0403bd0b02b62e60d850e007bf81fcab7bf65e193e68faaf8425f3cb17ef216b  125
```
