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
if (FALSE) { # \dontrun{
prov <- cmgd_provenance(cmgd_release("cmgd_mpa4.2-2.3.0"))
prov$cmgd$databases
} # }
```
