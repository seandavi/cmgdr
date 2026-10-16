# A study's species profile as a TreeSummarizedExperiment

Builds a species x samples TreeSummarizedExperiment from the study's
`metaphlan_species.tsv.gz` (relative abundance in percent, main
MetaPhlAn pass, all reads) with a sparse `relative_abundance` assay and
the study's `qc.tsv` as `colData`. Every sample in `qc.tsv` is a column;
a sample with no species rows is all zero.

## Usage

``` r
cmgd_species_tse(rel, study, cache = cmgd_cache_dir())
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- study:

  Study name, for example `"ZellerG_2014"`.

- cache:

  Cache directory.

## Value

A `TreeSummarizedExperiment`.

## Details

Needs the Bioconductor package TreeSummarizedExperiment and Matrix.

## Examples

``` r
if (FALSE) { # \dontrun{
rel <- cmgd_release("cmgd_nextflow-2.2.1")
tse <- cmgd_species_tse(rel, "ZellerG_2014")
} # }
```
