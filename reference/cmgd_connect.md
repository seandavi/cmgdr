# Attach a release's tables in DuckDB

Opens an in-memory DuckDB connection and attaches the release's frozen,
read-only DuckLake catalog over HTTPS as database `cmgd` (also made the
default, so `dplyr::tbl(con, "qc_metrics")` works). Attaching is quick:
DuckDB fetches only the parts of the Parquet files a query touches.

## Usage

``` r
cmgd_connect(rel, cache = cmgd_cache_dir())
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- cache:

  Cache directory.

## Value

A DBI connection.

## Details

The first call downloads DuckDB's `ducklake` and `httpfs` extensions
into `duckdb/` in the cache directory (not `~/.duckdb`), where later
sessions reuse them. Close the connection with
`DBI::dbDisconnect(con, shutdown = TRUE)`.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
# DuckDB's extensions are kept under `cache` too.
con <- cmgd_connect(rel, cache = tempdir())
DBI::dbGetQuery(con, "
    SELECT study_name, count(*) AS n_samples
    FROM qc_metrics GROUP BY study_name
    ORDER BY n_samples DESC LIMIT 5")
#>       study_name n_samples
#> 1    ZhangM_2023        24
#> 2      BaiX_2021        24
#> 3  AsnicarF_2017        24
#> 4 LassalleF_2017        23
#> 5  WibowoMC_2021        22
DBI::dbDisconnect(con, shutdown = TRUE)
```
