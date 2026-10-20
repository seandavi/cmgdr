# Accessing curatedMetagenomicData releases with cmgdr

## Background

[curatedMetagenomicData](https://waldronlab.io/curatedMetagenomicData/)
(cMD) is a collection of human shotgun metagenomes from published
studies, every sample processed through the same pipeline and paired
with curated sample metadata, so that profiles from different studies
can be compared and pooled. Each sample’s raw reads are
quality-controlled and profiled with MetaPhlAn (taxonomic relative
abundance), Kraken2/Bracken, a resistome screen against CARD and, in
some pipeline configurations, HUMAnN (functional profiles).

The profiles are now published as open **data releases** at
<https://cmgd-public.cancerdatasci.org>. The layout has a few concepts
that the rest of this vignette relies on:

- A **dataset** is one pipeline registration: a pipeline version
  together with its configuration, named `<workflow_id>-<version>`, for
  example `cmgd_mpa4.2-2.3.0` (pipeline 2.3.0, MetaPhlAn 4.2, no
  HUMAnN). Profiles from different datasets were made with different
  tools or databases and are kept apart.
- A **release** is an immutable, full snapshot of a dataset, named by
  its UTC build date (`2026-10-16`). A release never changes once
  published; new data arrive as a new release. Cite the dataset and the
  release id.
- Each release has a **manifest** (`manifest.json`) listing its
  **tables** (long, tidy tables such as `taxonomic_profile_metaphlan` or
  `qc_metrics`, stored as Parquet files), ready-made **per-study
  files**, and a read-only [DuckLake](https://ducklake.select) catalog
  that lets DuckDB query the whole release in place.
- Every file is listed with its size and SHA-256 checksum. cmgdr
  downloads files into a local **cache** and verifies them against those
  checksums; a file that does not verify is deleted and an error raised.
  Because releases are immutable, a cached file never goes stale.

The site cannot be listed like a directory: everything is found through
JSON indexes, which is what cmgdr reads.

cmgdr is deliberately a low-level client. It knows the published layout
and returns plain data frames, lists, local file paths, a DuckDB
connection, and (for convenience) a species `TreeSummarizedExperiment`.
It does not reshape, join or model the data; higher-level packages are
expected to build on it.

This vignette uses the small `cmgd_mpa4.2-2.3.0` release (125 samples in
8 studies) and, within it, the three-sample `ZellerG_2014` study, so it
downloads only a few hundred kilobytes. All code runs against the live
site.

## Setup

cmgdr is not on Bioconductor yet. Install it from GitHub; once it is
accepted, `BiocManager::install("cmgdr")` will work.

``` r

if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("seandavi/cmgdr")
```

Downloads go to
[`cmgd_cache_dir()`](https://seandavi.github.io/cmgdr/reference/cmgd_cache_dir.md),
which is `tools::R_user_dir("cmgdr", "cache")` and moves with the
`R_USER_CACHE_DIR` environment variable. This vignette points it at a
temporary directory so building it leaves nothing behind.

``` r

library(cmgdr)
Sys.setenv(R_USER_CACHE_DIR = tempfile("cmgdr-cache"))
cmgd_cache_dir()
#> [1] "/tmp/RtmpKrKMl8/cmgdr-cache1c491f9e0759/R/cmgdr"
```

## Finding datasets and releases

[`cmgd_datasets()`](https://seandavi.github.io/cmgdr/reference/cmgd_datasets.md)
takes no required arguments (only `base`, the site URL) and returns a
data frame with one row per published dataset: its id (`dataset`), the
pipeline registration it comes from (`workflow_id`, `version`), and the
id of its newest release (`latest`).

``` r

datasets <- cmgd_datasets()
datasets
#>               dataset   workflow_id version     latest
#> 1   cmgd_mpa4.2-2.3.0   cmgd_mpa4.2   2.3.0 2026-10-16
#> 2 cmgd_nextflow-2.2.1 cmgd_nextflow   2.2.1 2026-10-08
```

[`cmgd_releases()`](https://seandavi.github.io/cmgdr/reference/cmgd_releases.md)
takes a dataset id and returns one row per release of that dataset,
oldest first: the release id, its build date, when it was published, and
whether it is `pinned` (kept as a long-term reference).

``` r

cmgd_releases("cmgd_mpa4.2-2.3.0")
#>      release release_date                     published_at pinned
#> 1 2026-10-16   2026-10-16 2026-10-16T03:40:40.277445+00:00  FALSE
```

[`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md)
opens a release. It takes a dataset id and a release id; the default
`release = "latest"` resolves to the newest one, but for reproducible
work pin the id, as here. It reads the release’s manifest and returns a
`cmgd_release` object, the handle every other cmgdr function takes. It
is a list with the dataset and release ids, the release URL and the
parsed manifest; printing it shows the tables it holds.

``` r

rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
rel
#> <cmgd_release> cmgd_mpa4.2-2.3.0 2026-10-16
#>   url:    https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16
#>   tables: marker_abundance, marker_presence, metadata_comparison, metadata_sources, qc_metrics, resistome, sample_metadata_cmd, sample_metadata_harmonized, sample_metadata_olm, samples, taxonomic_profile_bracken, taxonomic_profile_metaphlan
class(rel)
#> [1] "cmgd_release"
names(rel$manifest)
#>  [1] "spec_version"          "dataset"               "release"              
#>  [4] "release_date"          "status"                "published_at"         
#>  [7] "run_id"                "source_asset_versions" "artifacts"            
#> [10] "tables"                "provenance"            "lineage"
```

## Tables and files

[`cmgd_tables()`](https://seandavi.github.io/cmgdr/reference/cmgd_tables.md)
takes a release and returns one row per table: its `name`, a
`description`, its `grain` (what one row of the table means), its
`row_count`, and its `license`. Most tables are CC0-1.0; tables that
include values derived from the Olm lab Microbiome Repo are CC-BY-4.0
(see [Sample metadata](#sample-metadata)).

``` r

tables <- cmgd_tables(rel)
tables[, c("name", "grain", "row_count", "license")]
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

A table is stored as one or more Parquet files.
[`cmgd_files()`](https://seandavi.github.io/cmgdr/reference/cmgd_files.md)
takes a release and, optionally, table names, and returns one row per
file: the `table`, the file’s `path` relative to the release, its full
`url`, its `size` in bytes, its `sha256`, and the number of `rows` it
holds.

``` r

files <- cmgd_files(rel, "qc_metrics")
str(files)
#> 'data.frame':    1 obs. of  6 variables:
#>  $ table : chr "qc_metrics"
#>  $ path  : chr "tables/qc_metrics/data/part-00000.parquet"
#>  $ url   : chr "https://cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/tables/qc_metrics/data/part-00000.parquet"
#>  $ size  : int 16845
#>  $ sha256: chr "0403bd0b02b62e60d850e007bf81fcab7bf65e193e68faaf8425f3cb17ef216b"
#>  $ rows  : int 125
```

[`cmgd_download()`](https://seandavi.github.io/cmgdr/reference/cmgd_download.md)
takes a release and one path (as in the `path` column) or full URL,
downloads the file into the cache, verifies its size and SHA-256, and
returns the local file path. Calling it again returns the cached copy
without downloading, as long as the copy still verifies.

``` r

local <- cmgd_download(rel, files$path[1])
local
#> [1] "/tmp/RtmpKrKMl8/cmgdr-cache1c491f9e0759/R/cmgdr/cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/tables/qc_metrics/data/part-00000.parquet"
file.size(local) == files$size[1]
#> [1] TRUE
```

## Studies

Besides whole tables, each release has ready-made files for each study.
[`cmgd_studies()`](https://seandavi.github.io/cmgdr/reference/cmgd_studies.md)
takes a release and returns one row per study: its `study_name` and
`n_samples`.

``` r

studies <- cmgd_studies(rel)
studies
#>       study_name n_samples
#> 1  AsnicarF_2017        24
#> 2      BaiX_2021        24
#> 3   DavidLA_2015         1
#> 4       HMP_2012         4
#> 5 LassalleF_2017        23
#> 6  WibowoMC_2021        22
#> 7   ZellerG_2014         3
#> 8    ZhangM_2023        24
```

[`cmgd_study_files()`](https://seandavi.github.io/cmgdr/reference/cmgd_study_files.md)
takes a release and a study name and returns one row per file published
for that study: its `name`, `path`, `url`, `size`, `sha256` and a
`description` of what it holds. There is a species × samples matrix
(`metaphlan_species.tsv.gz`), the study’s rows of the main tables as
Parquet, and a QC table (`qc.tsv`).

``` r

study_files <- cmgd_study_files(rel, "ZellerG_2014")
study_files[, c("name", "size")]
#>                       name   size
#> 1          bracken.parquet 253158
#> 2         metadata.parquet   2053
#> 3        metaphlan.parquet  79353
#> 4 metaphlan_species.tsv.gz  14183
#> 5                   qc.tsv   1206
#> 6        resistome.parquet  10860
```

[`cmgd_read_study()`](https://seandavi.github.io/cmgdr/reference/cmgd_read_study.md)
takes a release, a study and the file’s `name` without extension
(`"qc"`, `"metaphlan"`, `"bracken"`, `"metaphlan_species"`, …),
downloads it through the verified cache and reads it into a data frame.
Parquet files are read with the duckdb package. The QC table has one row
per sample: its keys (`sample_key`, `readset_id`, `run_ids`), read and
base counts before and after decontamination, and the pipeline version
and commit that produced it.

``` r

qc <- cmgd_read_study(rel, "ZellerG_2014", "qc")
str(qc)
#> 'data.frame':    3 obs. of  18 variables:
#>  $ sample_key              : chr  "RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p" "RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9" "RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj"
#>  $ sample_id               : chr  "06e398e0194de8d2aa185b9d8996a474" "72080b9ed6d4c860afb54bd9feee501a" "a08d985474ca4b67bb6fc3bb4093e640"
#>  $ readset_id              : chr  "RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p" "RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9" "RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj"
#>  $ study_name              : chr  "ZellerG_2014" "ZellerG_2014" "ZellerG_2014"
#>  $ run_ids                 : chr  "ERR478962;ERR478963;ERR480458;ERR480459" "ERR478964;ERR478965;ERR478966;ERR478967;ERR480460;ERR480461;ERR480462;ERR480463" "ERR478958;ERR478959;ERR478960;ERR478961;ERR480454;ERR480455;ERR480456;ERR480457"
#>  $ workflow_id             : chr  "cmgd_mpa4.2" "cmgd_mpa4.2" "cmgd_mpa4.2"
#>  $ version                 : chr  "2.3.0" "2.3.0" "2.3.0"
#>  $ reads_raw               : int  47190574 87631061 76003628
#>  $ reads_decontaminated    : int  47189630 87630399 76003320
#>  $ bases_raw               : num  3.30e+09 7.85e+09 6.51e+09
#>  $ bases_decontaminated    : num  3.30e+09 7.85e+09 6.51e+09
#>  $ reads_surviving_fraction: num  1 1 1
#>  $ bases_surviving_fraction: num  1 1 1
#>  $ metaphlan_index         : logi  NA NA NA
#>  $ metaphlan_profile       : chr  "mpa4.2.6_vJan26" "mpa4.2.6_vJan26" "mpa4.2.6_vJan26"
#>  $ humann_bundle           : logi  NA NA NA
#>  $ pipeline_version        : chr  "2.3.0" "2.3.0" "2.3.0"
#>  $ git_commit              : chr  "793996bafae99c65ce4f9ff85a08f08b68fa6227" "793996bafae99c65ce4f9ff85a08f08b68fa6227" "793996bafae99c65ce4f9ff85a08f08b68fa6227"
```

## A species TreeSummarizedExperiment

[`cmgd_species_tse()`](https://seandavi.github.io/cmgdr/reference/cmgd_species_tse.md)
takes a release and a study and builds a `TreeSummarizedExperiment` from
the study’s species matrix. Rows are MetaPhlAn species clades (full
`k__...|s__...` names), columns are samples (`sample_key`), and the one
assay, `relative_abundance`, is a sparse matrix of percentages from the
main MetaPhlAn pass on all reads. The QC table above is its `colData`.

``` r

tse <- cmgd_species_tse(rel, "ZellerG_2014")
#> Warning: replacing previous import 'S4Arrays::makeNindexFromArrayViewport' by
#> 'DelayedArray::makeNindexFromArrayViewport' when loading 'SummarizedExperiment'
tse
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
abundance <- SummarizedExperiment::assay(tse, "relative_abundance")
class(abundance)
#> [1] "dgCMatrix"
#> attr(,"package")
#> [1] "Matrix"
# Shorten the clade names to the species for display
rownames(abundance) <- sub(".*\\|s__", "", rownames(abundance))
top <- order(-Matrix::rowSums(abundance))[1:5]
as.matrix(abundance[top, ])
#>                              RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p
#> Segatella_copri                                        29.921103
#> Ruminococcus_bromii                                     5.315938
#> Faecalibacterium_prausnitzii                            0.421233
#> Agathobacter_rectalis                                   0.067662
#> Phocaeicola_vulgatus                                    2.469772
#>                              RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9
#> Segatella_copri                                         4.796209
#> Ruminococcus_bromii                                     3.709005
#> Faecalibacterium_prausnitzii                            6.880550
#> Agathobacter_rectalis                                   4.503933
#> Phocaeicola_vulgatus                                    0.751966
#>                              RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj
#> Segatella_copri                                         0.000000
#> Ruminococcus_bromii                                     1.899035
#> Faecalibacterium_prausnitzii                            2.502379
#> Agathobacter_rectalis                                   1.278033
#> Phocaeicola_vulgatus                                    1.663834
```

## Sample metadata

Releases since `cmgd_mpa4.2-2.3.0` / `2026-10-16` publish sample
metadata as tables.
[`cmgd_sample_metadata()`](https://seandavi.github.io/cmgdr/reference/cmgd_sample_metadata.md)
takes a release, a `source`, optional `study` names and `wide`, and
returns a data frame. The sources are:

- `harmonized` (the default): one value per sample and harmonized field,
  taken from the cMD curation where it has one and from the Olm lab
  Microbiome Repo otherwise. CC-BY-4.0.
- `cmd`: the curatedMetagenomicData curation as published. CC0-1.0.
- `olm`: the Olm lab Microbiome Repo, with its route and confidence.
  CC-BY-4.0.

With `wide = FALSE` (the default) the table comes back long, as
published: one row per sample and field, with the `value`, the `source`
it came from, the source’s `release`, and for Olm values the `route` and
`confidence`.

``` r

meta <- cmgd_sample_metadata(rel, study = "ZellerG_2014")
#> sample_metadata_harmonized is licensed CC-BY-4.0; attribution required: cite doi:10.5281/zenodo.23087712
head(meta)
#>     study_name                          sample_key            field
#> 1 ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p        age_years
#> 2 ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p              bmi
#> 3 ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p          country
#> 4 ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p health_condition
#> 5 ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p              sex
#> 6 ZellerG_2014 RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9        age_years
#>             value source                                  release   route
#> 1            53.0    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4 curated
#> 2            32.0    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4 curated
#> 3              FR    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4 curated
#> 4 healthy_control    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4 curated
#> 5            male    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4 curated
#> 6            35.0    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4 curated
#>   confidence
#> 1         NA
#> 2         NA
#> 3         NA
#> 4         NA
#> 5         NA
#> 6         NA
```

Reading a CC-BY-4.0 table prints a message naming the licence and the
DOI to cite. The licence and the pinned source releases the table was
built from (with their DOIs and checksums) are also attached as
attributes, so they travel with the data:

``` r

attr(meta, "license")
#> [1] "CC-BY-4.0"
attr(meta, "sources")[, c("source", "release", "doi", "license")]
#>   source                                  release                     doi
#> 1    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4                    <NA>
#> 2    olm                                 R2026.25 10.5281/zenodo.23087712
#>     license
#> 1   CC0-1.0
#> 2 CC-BY-4.0
```

If you use the `harmonized` or `olm` tables, cite the Microbiome Repo
DOI above as well as curatedMetagenomicData; the
[provenance](#provenance) lists the full citation text.

With `wide = TRUE` the result has one row per sample: the sample’s
`study_name`, `sample_key`, `biosample`, `bioproject` and
`run_accessions`, then one character column per field, `NA` where a
sample has no value.

``` r

wide <- cmgd_sample_metadata(
    rel,
    source = "cmd", study = "ZellerG_2014", wide = TRUE
)
dim(wide)
#> [1]  3 25
wide[, c("sample_key", "biosample", "age_years", "sex", "health_condition")]
#>                            sample_key    biosample age_years    sex
#> 1 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p SAMEA2466896   53;53.0   male
#> 2 RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9 SAMEA2466965   35.0;35   male
#> 3 RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj SAMEA2467039   72;72.0 female
#>   health_condition
#> 1  healthy_control
#> 2  healthy_control
#> 3  healthy_control
```

A release without metadata tables raises an error of class
`cmgdr_no_metadata`, which callers can catch with
[`tryCatch()`](https://rdrr.io/r/base/conditions.html).

## Finding samples by run accession

[`cmgd_find_runs()`](https://seandavi.github.io/cmgdr/reference/cmgd_find_runs.md)
takes a release and a vector of SRA/ENA run accessions (`SRR...`,
`ERR...`, `DRR...`) and looks them up in the release’s `samples` table,
where a sample’s runs are `;`-joined. It returns a data frame with one
row per accession, in the order given: the `run`, then the matching
`samples` row (study, `sample_key`, BioSample, BioProject, pipeline
version, …). A run the release does not have gets a row of `NA`s, so the
result always lines up with the input.

``` r

runs <- cmgd_find_runs(rel, c("ERR478962", "SRR0000000"))
runs[, c("run", "study_name", "sample_key", "biosample", "bioproject")]
#>          run   study_name                          sample_key    biosample
#> 1  ERR478962 ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p SAMEA2466896
#> 2 SRR0000000         <NA>                                <NA>         <NA>
#>   bioproject
#> 1  PRJEB6070
#> 2       <NA>
```

## Provenance

[`cmgd_provenance()`](https://seandavi.github.io/cmgdr/reference/cmgd_provenance.md)
takes a release and returns its `provenance.json` as a list: the lake
snapshots the release was built from (`source_asset_versions`) and, for
releases since `2026-10-16`, a `cmgd` section with the pipeline
registration (repository, revision, parameters), the pipeline runs, the
reference database versions, the pinned metadata sources, the licence of
every table, and citation text.

``` r

prov <- cmgd_provenance(rel)
names(prov$cmgd)
#> [1] "registration"     "pipeline_runs"    "databases"        "metadata_sources"
#> [5] "licenses"         "citation"
str(prov$cmgd$databases)
#> List of 4
#>  $ metaphlan      : chr "4.2.6"
#>  $ metaphlan_index: chr "mpa_vJan26_CHOCOPhlAnSGB_202605"
#>  $ kraken2_bracken: chr "k2_pluspf_16_GB_20260226"
#>  $ card           : chr "broadstreet-v4.0.1"
prov$cmgd$pipeline_runs
#>   pipeline_version                               git_commit n_samples n_studies
#> 1            2.3.0 793996bafae99c65ce4f9ff85a08f08b68fa6227       125         8
prov$cmgd$citation
#> $cmgd
#> [1] "Pasolli E, Schiffer L, Manghi P, Renson A, Obenchain V, Truong DT, Beghini F, Malik F, Ramos M, Dowd JB, Huttenhower C, Morgan M, Segata N, Waldron L. Accessible, curated metagenomic data through ExperimentHub. Nat Methods. 2017;14(11):1023-1024. doi:10.1038/nmeth.4468"
#> 
#> $olm
#> [1] "Microbiome Repo, OlmLab, release R2026.25 (data package 1.20.0), doi:10.5281/zenodo.23087712; values derived. Required attribution for the CC-BY-4.0 tables."
```

## Whole tables with SQL and dplyr

[`cmgd_connect()`](https://seandavi.github.io/cmgdr/reference/cmgd_connect.md)
takes a release and returns a DBI connection to an in-memory DuckDB
database with the release’s DuckLake catalog attached read-only. Every
table in
[`cmgd_tables()`](https://seandavi.github.io/cmgdr/reference/cmgd_tables.md)
is available by name. Nothing is downloaded up front: DuckDB fetches
only the parts of the remote Parquet files a query needs.

``` r

con <- cmgd_connect(rel)
DBI::dbGetQuery(con, "
    SELECT study_name, count(*) AS n_samples,
        avg(reads_decontaminated) AS mean_reads
    FROM qc_metrics
    GROUP BY study_name
    ORDER BY n_samples DESC")
#>       study_name n_samples mean_reads
#> 1    ZhangM_2023        24   41242176
#> 2      BaiX_2021        24   81421066
#> 3  AsnicarF_2017        24   18436539
#> 4 LassalleF_2017        23   29695992
#> 5  WibowoMC_2021        22   63099853
#> 6       HMP_2012         4   42665646
#> 7   ZellerG_2014         3   70274450
#> 8   DavidLA_2015         1     500546
```

The same connection works with dplyr (and dbplyr). Here are the five
most abundant species in `ZellerG_2014`, averaged over its samples. A
species missing from a sample has no row, so divide by the study’s
sample count rather than taking a mean.

``` r

library(dplyr)
n <- tbl(con, "qc_metrics") |>
    filter(study_name == "ZellerG_2014") |>
    count() |>
    pull(n)
tbl(con, "taxonomic_profile_metaphlan") |>
    filter(
        study_name == "ZellerG_2014", rank == "species",
        data_type == "full_data", is.na(humann_bundle)
    ) |>
    group_by(clade_name) |>
    summarise(mean_percent = sum(relative_abundance, na.rm = TRUE) / n) |>
    arrange(desc(mean_percent)) |>
    head(5) |>
    collect() |>
    mutate(species = sub(".*\\|s__", "", clade_name), .keep = "unused")
#> # A tibble: 5 × 2
#>   mean_percent species                     
#>          <dbl> <chr>                       
#> 1        11.6  Segatella_copri             
#> 2         3.64 Ruminococcus_bromii         
#> 3         3.27 Faecalibacterium_prausnitzii
#> 4         1.95 Agathobacter_rectalis       
#> 5         1.63 Phocaeicola_vulgatus
DBI::dbDisconnect(con, shutdown = TRUE)
```

Before computing across tables:

1.  Abundances from different methods are not on the same scale.
    MetaPhlAn `relative_abundance` is a percent; Bracken
    `fraction_total_reads` is a 0–1 fraction.
2.  Pick one `data_type`, either `full_data` (all reads) or
    `rarefied_data` (a 1M-read subsample). Most analyses want
    `full_data`.
3.  Pick one MetaPhlAn pass. In HUMAnN datasets the bundle’s own
    MetaPhlAn pass (`humann_bundle` set) sits next to the main pass
    (`humann_bundle IS NULL`).

Each release’s `README.md` and `tables/<table>/schema.json` document
every column.

## HUMAnN gene families

HUMAnN datasets (`cmgd_humann3.9-2.3.0`, `cmgd_humann4a1-2.3.0`) also
publish per-sample HUMAnN gene-family tables. These are too large for
the release tables, so each is its own download from
`https://cmgd-raw.cancerdatasci.org`, listed in the release’s
gene-family index.
[`cmgd_genefamilies()`](https://seandavi.github.io/cmgdr/reference/cmgd_genefamilies.md)
takes a release and returns one row per study with gene families; with
`study`, one row per file with its `url`, `size`, `sha256` and row
count, which
[`cmgd_download()`](https://seandavi.github.io/cmgdr/reference/cmgd_download.md)
fetches and verifies. No HUMAnN dataset is on the public site yet, so
this code is shown but not run.

``` r

gf_rel <- cmgd_release("cmgd_humann3.9-2.3.0")
cmgd_genefamilies(gf_rel)
gf <- cmgd_genefamilies(gf_rel, study = "ZellerG_2014")
path <- cmgd_download(gf_rel, gf$url[1])
genefamilies <- read.delim(path, check.names = FALSE)
```

## Session info

``` r

sessionInfo()
#> R version 4.6.1 (2026-06-24)
#> Platform: x86_64-pc-linux-gnu
#> Running under: Ubuntu 24.04.5 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas-pthread/libblas.so.3 
#> LAPACK: /usr/lib/x86_64-linux-gnu/openblas-pthread/libopenblasp-r0.3.26.so;  LAPACK version 3.12.0
#> 
#> locale:
#>  [1] LC_CTYPE=C.UTF-8       LC_NUMERIC=C           LC_TIME=C.UTF-8       
#>  [4] LC_COLLATE=C.UTF-8     LC_MONETARY=C.UTF-8    LC_MESSAGES=C.UTF-8   
#>  [7] LC_PAPER=C.UTF-8       LC_NAME=C              LC_ADDRESS=C          
#> [10] LC_TELEPHONE=C         LC_MEASUREMENT=C.UTF-8 LC_IDENTIFICATION=C   
#> 
#> time zone: UTC
#> tzcode source: system (glibc)
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#> [1] dplyr_1.2.1  cmgdr_0.99.0
#> 
#> loaded via a namespace (and not attached):
#>  [1] yulab.utils_0.2.5               utf8_1.2.6                     
#>  [3] rappdirs_0.3.4                  tidyr_1.3.2                    
#>  [5] generics_0.1.4                  SparseArray_1.12.3             
#>  [7] lattice_0.22-9                  digest_0.6.39                  
#>  [9] magrittr_2.0.5                  evaluate_1.0.5                 
#> [11] grid_4.6.1                      blob_1.3.0                     
#> [13] fastmap_1.2.0                   jsonlite_2.0.0                 
#> [15] Matrix_1.7-5                    ape_5.8-1                      
#> [17] DBI_1.3.0                       purrr_1.2.2                    
#> [19] SingleCellExperiment_1.34.0     Biostrings_2.80.2              
#> [21] lazyeval_0.2.3                  codetools_0.2-20               
#> [23] duckdb_1.5.6                    abind_1.4-8                    
#> [25] cli_3.6.6                       rlang_1.3.0                    
#> [27] crayon_1.5.3                    dbplyr_2.6.0                   
#> [29] XVector_0.52.0                  Biobase_2.72.0                 
#> [31] tidytree_0.4.8                  withr_3.0.3                    
#> [33] DelayedArray_0.38.2             yaml_2.3.12                    
#> [35] otel_0.2.0                      S4Arrays_1.12.1                
#> [37] tools_4.6.1                     parallel_4.6.1                 
#> [39] BiocParallel_1.46.0             SummarizedExperiment_1.42.0    
#> [41] BiocGenerics_0.58.1             curl_8.1.0                     
#> [43] vctrs_0.7.3                     R6_2.6.1                       
#> [45] matrixStats_1.5.0               stats4_4.6.1                   
#> [47] lifecycle_1.0.5                 Seqinfo_1.2.0                  
#> [49] fs_2.1.0                        S4Vectors_0.50.3               
#> [51] IRanges_2.46.0                  treeio_1.36.1                  
#> [53] pkgconfig_2.0.3                 TreeSummarizedExperiment_2.20.0
#> [55] pillar_1.11.1                   glue_1.8.1                     
#> [57] Rcpp_1.1.2                      xfun_0.62                      
#> [59] tibble_3.3.1                    GenomicRanges_1.64.0           
#> [61] tidyselect_1.2.1                MatrixGenerics_1.24.0          
#> [63] knitr_1.52                      htmltools_0.5.9                
#> [65] nlme_3.1-169                    rmarkdown_2.32                 
#> [67] compiler_4.6.1
```
