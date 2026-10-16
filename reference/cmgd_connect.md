# Attach a release's tables in DuckDB

Opens an in-memory DuckDB connection and attaches the release's frozen,
read-only DuckLake catalog over HTTPS as database `cmgd` (also made the
default, so `dplyr::tbl(con, "qc_metrics")` works). Attaching is quick:
DuckDB fetches only the parts of the Parquet files a query touches.

## Usage

``` r
cmgd_connect(rel)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

## Value

A DBI connection.

## Details

Needs the DBI and duckdb packages (DuckDB 1.5.2 or newer). The first
call downloads DuckDB's `ducklake` and `httpfs` extensions. Close the
connection with `DBI::dbDisconnect(con, shutdown = TRUE)`.

## Examples

``` r
if (FALSE) { # \dontrun{
rel <- cmgd_release("cmgd_nextflow-2.2.1")
con <- cmgd_connect(rel)
DBI::dbGetQuery(con, "
  SELECT study_name, count(*) AS n_samples
  FROM qc_metrics GROUP BY study_name ORDER BY n_samples DESC")

library(dplyr)
tbl(con, "taxonomic_profile_metaphlan") |>
    filter(
        study_name == "ZellerG_2014", rank == "species",
        data_type == "full_data", is.na(humann_bundle)
    ) |>
    count(clade_name, sort = TRUE) |>
    collect()
DBI::dbDisconnect(con, shutdown = TRUE)
} # }
```
