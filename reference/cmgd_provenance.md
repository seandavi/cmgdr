# Provenance of a release

The release's `provenance.json`: the lake snapshots it was built from
(`source_asset_versions`) and, for releases since `2026-10-16`, a `cmgd`
section with the pipeline registration and runs (`registration`,
`pipeline_runs`), reference `databases`, pinned `metadata_sources`,
per-table `licenses` and `citation` text.

## Usage

``` r
cmgd_provenance(rel)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

## Value

A list, as parsed by
[`jsonlite::fromJSON()`](https://jeroen.r-universe.dev/jsonlite/reference/fromJSON.html).

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
prov <- cmgd_provenance(rel)
prov$cmgd$databases
#> $metaphlan
#> [1] "4.2.6"
#> 
#> $metaphlan_index
#> [1] "mpa_vJan26_CHOCOPhlAnSGB_202605"
#> 
#> $kraken2_bracken
#> [1] "k2_pluspf_16_GB_20260226"
#> 
#> $card
#> [1] "broadstreet-v4.0.1"
#> 
```
