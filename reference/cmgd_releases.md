# Releases of a dataset

A release is an immutable full snapshot of a dataset, named by its UTC
build date (`2026-10-08`; a second release that day is `2026-10-08.2`).

## Usage

``` r
cmgd_releases(dataset, base = cmgd_public_base)
```

## Arguments

- dataset:

  Dataset id, for example `"cmgd_nextflow-2.2.1"`; see
  [`cmgd_datasets()`](https://seandavi.github.io/cmgdr/reference/cmgd_datasets.md).

- base:

  Base URL of the public release site.

## Value

A data.frame from the dataset's `releases.json`, oldest first, with
columns `release`, `release_date`, `published_at` and `pinned`.

## Examples

``` r
cmgd_releases("cmgd_mpa4.2-2.3.0")
#>      release release_date                     published_at pinned
#> 1 2026-10-16   2026-10-16 2026-10-16T03:40:40.277445+00:00  FALSE
#> 2 2026-10-20   2026-10-20 2026-10-20T12:59:46.971411+00:00  FALSE
```
