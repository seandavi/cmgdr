# Open a release

Reads the release's `manifest.json` and returns a handle that every
other cmgdr function takes. Errors if the manifest uses a publication
spec major version this version of cmgdr does not understand.

## Usage

``` r
cmgd_release(dataset, release = "latest", base = cmgd_public_base,
    raw_base = NULL)
```

## Arguments

- dataset:

  Dataset id, for example `"cmgd_nextflow-2.2.1"`; see
  [`cmgd_datasets()`](https://seandavi.github.io/cmgdr/reference/cmgd_datasets.md).

- release:

  Release id, or `"latest"` for the newest release.

- base:

  Base URL of the public release site.

- raw_base:

  Base URL to download gene-family files from, overriding the URLs in
  `genefamilies/index.json`. `NULL` uses the index's URLs.

## Value

A `cmgd_release` object: a list with `dataset`, `release`, `url` (the
release's base URL), `base`, `raw_base` and `manifest`.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
rel
#> <cmgd_release> cmgd_mpa4.2-2.3.0 2026-10-16
#>   url:    https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16
#>   tables: marker_abundance, marker_presence, metadata_comparison, metadata_sources, qc_metrics, resistome, sample_metadata_cmd, sample_metadata_harmonized, sample_metadata_olm, samples, taxonomic_profile_bracken, taxonomic_profile_metaphlan
```
