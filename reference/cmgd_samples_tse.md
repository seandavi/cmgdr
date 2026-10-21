# Species profiles of any samples as a TreeSummarizedExperiment

Builds a species x samples `TreeSummarizedExperiment` for an arbitrary
set of samples, possibly from several studies, with their sample
metadata as `colData`. Pick the samples by filtering
`cmgd_sample_metadata(rel, wide = TRUE)`, for example with
[`dplyr::filter()`](https://dplyr.tidyverse.org/reference/filter.html).

## Usage

``` r
cmgd_samples_tse(rel, samples, source = names(metadata_tables),
    cache = cmgd_cache_dir())
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- samples:

  `sample_key` values, or a data.frame with a `sample_key` column such
  as a filtered `cmgd_sample_metadata(rel, wide = TRUE)`. Columns are in
  this order.

- source:

  Which metadata table to read.

- cache:

  Cache directory.

## Value

A `TreeSummarizedExperiment`. `metadata()` has `license` and `sources`
of the metadata table, as for
[`cmgd_sample_metadata()`](https://seandavi.github.io/cmgdr/reference/cmgd_sample_metadata.md),
which also gives the attribution message for a CC-BY table. Errors
naming any `samples` not in the release, and with class
`cmgdr_no_metadata` if the release has no sample-metadata tables.

## Details

Each sample's study comes from the release's `samples` table. The
`relative_abundance` assay (sparse, percent) is built from each study's
`metaphlan_species.tsv.gz` as in
[`cmgd_species_tse()`](https://seandavi.github.io/cmgdr/reference/cmgd_species_tse.md):
rows are the union of the studies' species, `0` where a species is
absent. `colData` is the study's `qc.tsv` row followed by the wide
metadata columns from `source` (`NA` where a sample has no value).

## Examples

``` r
if (requireNamespace("duckdb", quietly = TRUE)) {
    rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
    meta <- cmgd_sample_metadata(rel, wide = TRUE, cache = tempdir())
    # Female cases, across studies
    picked <- meta[meta$health_condition %in% "case", ]
    picked <- picked[picked$sex %in% "female", ]
    tse <- cmgd_samples_tse(rel, picked, cache = tempdir())
    tse
    table(tse$study_name)
}
#> sample_metadata_harmonized is licensed CC-BY-4.0; attribution required: cite doi:10.5281/zenodo.23087712
#> sample_metadata_harmonized is licensed CC-BY-4.0; attribution required: cite doi:10.5281/zenodo.23087712
#> Warning: replacing previous import ‘S4Arrays::makeNindexFromArrayViewport’ by ‘DelayedArray::makeNindexFromArrayViewport’ when loading ‘SummarizedExperiment’
#> 
#>     BaiX_2021 WibowoMC_2021   ZhangM_2023 
#>             9             4            11 
```
