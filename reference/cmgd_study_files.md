# Per-study download files

Per-study download files

## Usage

``` r
cmgd_study_files(rel, study)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- study:

  Study name, for example `"ZellerG_2014"`.

## Value

A data.frame with columns `name`, `path` (relative to the release URL),
`url`, `size` (bytes), `sha256` and `description`.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
cmgd_study_files(rel, "ZellerG_2014")
#>                       name                                          path
#> 1          bracken.parquet          studies/ZellerG_2014/bracken.parquet
#> 2         metadata.parquet         studies/ZellerG_2014/metadata.parquet
#> 3        metaphlan.parquet        studies/ZellerG_2014/metaphlan.parquet
#> 4 metaphlan_species.tsv.gz studies/ZellerG_2014/metaphlan_species.tsv.gz
#> 5                   qc.tsv                   studies/ZellerG_2014/qc.tsv
#> 6        resistome.parquet        studies/ZellerG_2014/resistome.parquet
#>                                                                                                                url
#> 1          https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/bracken.parquet
#> 2         https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/metadata.parquet
#> 3        https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/metaphlan.parquet
#> 4 https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/metaphlan_species.tsv.gz
#> 5                   https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/qc.tsv
#> 6        https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/resistome.parquet
#>     size                                                           sha256
#> 1 253158 69b114a1fa2cec8f387c67d6964e2dc77017c8a38b6a24a0ac0a02d59e1c4ea2
#> 2   2053 a08c047847c8eda3d91b7c197579b8ce79a76ace1ad65df416c5a034d1d6ed2b
#> 3  79353 c58c4437fa1c77961bc84b3197f4c3f88c9583053b84bdb601c7fd683291f2d0
#> 4  14183 3c3b1d20ef5b637393e13cd49baf5767ce0ae334e130f2827a1c6b6e2666859b
#> 5   1206 f7ed447f4238b1bb8cba3cd4366db93fd5a3bc8bbe05748bbf0ed9366cbe9fab
#> 6  10860 40964ec21576e1748ea6a091c3c6c8e63a5e5412076c1f6c1b4a40b03722fe99
#>                                                                                                                                                                                                                                                                                         description
#> 1                                                                                                                                                                                                                                              taxonomic_profile_bracken rows for the study (long).
#> 2                                                                                                                                                 sample_metadata_harmonized rows for the study (long: one row per sample and field, with source and source release). CC-BY-4.0, see manifest.json.
#> 3                                                                                                                                                                                                                   taxonomic_profile_metaphlan rows for the study (long; all passes and branches).
#> 4 Species x samples matrix: one row per MetaPhlAn species clade (clade_name), one column per sample_key; relative abundance in percent from the main MetaPhlAn pass on full_data; 0 = not detected. Every sample in qc.tsv has a column: a sample with no species-level rows is an all-zero column.
#> 5                                                                                                                                                                                                                                  qc_metrics rows for the study: one row per sample, with run_ids.
#> 6                                                                                                                                                                                                                                                              resistome rows for the study (long).
```
