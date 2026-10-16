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
if (FALSE) { # \dontrun{
rel <- cmgd_release("cmgd_nextflow-2.2.1")
cmgd_files(rel, "qc_metrics")
} # }
```
