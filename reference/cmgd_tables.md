# Tables in a release

Tables in a release

## Usage

``` r
cmgd_tables(rel)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

## Value

A data.frame with one row per table: `name`, `description`, `grain`,
`row_count` and `license`.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
cmgd_tables(rel)
#>                           name
#> 1             marker_abundance
#> 2              marker_presence
#> 3          metadata_comparison
#> 4             metadata_sources
#> 5                   qc_metrics
#> 6                    resistome
#> 7          sample_metadata_cmd
#> 8   sample_metadata_harmonized
#> 9          sample_metadata_olm
#> 10                     samples
#> 11   taxonomic_profile_bracken
#> 12 taxonomic_profile_metaphlan
#>                                                                                                                                                                                                                                                                                                                                                                                                         description
#> 1                                                                                                                                                                                                                                                                                                                                                                                      MetaPhlAn marker abundances.
#> 2                                                                                                                                                                                                                                                                                                                                   MetaPhlAn markers present in a sample (a row exists iff the marker is present).
#> 3                                                             Agreement between cMD curation and the Olm Microbiome Repo per study and field, with Olm's cMD-imported rows included (olm_rows = all) and excluded (independent). Attribution required: Microbiome Repo, OlmLab, release R2026.25 (data package 1.20.0), doi:10.5281/zenodo.23087712; values derived. Required attribution for the CC-BY-4.0 tables.
#> 4                                                                                                                                                                                                                                                                                                                       The metadata source releases in the store; `pinned` marks the one the metadata tables read.
#> 5                                                                                                                                                                                                                                                                                                                                                                        Per-sample read accounting and provenance.
#> 6                                                                                                                                                                                                                                                                                                                                                                Antimicrobial-resistance genes (KMA against CARD).
#> 7                                                                                                                                                                                                                                         Sample metadata curated by curatedMetagenomicData (curation repo, pinned commit), one row per field. `field`/`value` are harmonized where the field map covers the field.
#> 8  One value per sample and harmonized field, with the source and source release it came from (precedence: cMD curation, then Olm R1/R2 not imported from cMD, then Olm R3/R4 with confidence >= 0.5). Mixes Olm-derived values; attribution required: Microbiome Repo, OlmLab, release R2026.25 (data package 1.20.0), doi:10.5281/zenodo.23087712; values derived. Required attribution for the CC-BY-4.0 tables.
#> 9                                                                                     Sample metadata from the Olm lab Microbiome Repo (pinned release), one row per field, with Olm's route and confidence; no evidence quotes. Attribution required: Microbiome Repo, OlmLab, release R2026.25 (data package 1.20.0), doi:10.5281/zenodo.23087712; values derived. Required attribution for the CC-BY-4.0 tables.
#> 10                                                                                                                                                                                                                                                         One row per sample in the release: the join hub from readset id to run accessions, BioSample and BioProject, with the pipeline version that produced it.
#> 11                                                                                                                                                                                                                                                                                                                                                                      Kraken2/Bracken species and genus profiles.
#> 12                                                                                                                                                                                                                                                                                                                MetaPhlAn taxonomic profiles: the main pass, plus a HUMAnN bundle's own pass (humann_bundle set).
#>                                                   grain row_count   license
#> 1                 one row per sample, branch and marker   5013703   CC0-1.0
#> 2         one row per sample, branch and present marker   4688706   CC0-1.0
#> 3           one row per study, field and olm_rows scope        84 CC-BY-4.0
#> 4                            one row per source release         2   CC0-1.0
#> 5                                    one row per sample       125   CC0-1.0
#> 6          one row per sample, branch and CARD template     15582   CC0-1.0
#> 7       one row per sample, field and cMD sample record      2331   CC0-1.0
#> 8                          one row per sample and field       562 CC-BY-4.0
#> 9              one row per sample, field and Olm sample       987 CC-BY-4.0
#> 10                                   one row per sample       125   CC0-1.0
#> 11                 one row per sample, branch and taxon   1223560   CC0-1.0
#> 12 one row per sample, branch, MetaPhlAn pass and clade    127012   CC0-1.0
```
