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
if (requireNamespace("TreeSummarizedExperiment", quietly = TRUE)) {
    rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
    tse <- cmgd_species_tse(rel, "ZellerG_2014", cache = tempdir())
    tse
}
#> Warning: replacing previous import ‘S4Arrays::makeNindexFromArrayViewport’ by ‘DelayedArray::makeNindexFromArrayViewport’ when loading ‘SummarizedExperiment’
#> class: TreeSummarizedExperiment 
#> dim: 643 3 
#> metadata(0):
#> assays(1): relative_abundance
#> rownames(643):
#>   k__Archaea|p__Methanobacteriota|c__Methanobacteria|o__Methanobacteriales|f__Methanobacteriaceae|g__Methanobrevibacter|s__Methanobrevibacter_smithii
#>   k__Archaea|p__Thermoplasmatota|c__Thermoplasmata|o__Methanomassiliicoccales|f__Methanomassiliicoccaceae|g__Methanomassiliicoccaceae_unclassified|s__Methanomassiliicoccaceae_unclassified_SGB380
#>   ...
#>   k__Eukaryota|p__Ascomycota|c__Saccharomycetes|o__Saccharomycetales|f__Saccharomycetaceae|g__Saccharomyces|s__Saccharomyces_cerevisiae
#>   k__Eukaryota|p__Eukaryota_unclassified|c__Bigyra|o__Opalinata|f__Blastocystidae|g__Blastocystis|s__Blastocystis_sp_subtype_6
#> rowData names(0):
#> colnames(3): RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p
#>   RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9
#>   RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj
#> colData names(18): sample_key sample_id ... pipeline_version git_commit
#> reducedDimNames(0):
#> mainExpName: NULL
#> altExpNames(0):
#> rowLinks: NULL
#> rowTree: NULL
#> colLinks: NULL
#> colTree: NULL
```
