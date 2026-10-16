# Read a per-study file

Downloads (via
[`cmgd_download()`](https://seandavi.github.io/cmgdr/reference/cmgd_download.md),
so cached and verified) and reads one of a study's ready-made files:

## Usage

``` r
cmgd_read_study(
  rel,
  study,
  what = names(study_file_names),
  cache = cmgd_cache_dir()
)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- study:

  Study name, for example `"ZellerG_2014"`.

- what:

  Which file to read.

- cache:

  Cache directory.

## Value

A data.frame.

## Details

- `metaphlan_species`: species x samples relative abundance (percent)
  from the main MetaPhlAn pass on all reads; column `clade_name` then
  one column per `sample_key`; `0` means not detected. Every sample in
  `qc` has a column: a sample with no species-level rows is an all-zero
  column.

- `metaphlan`, `bracken`, `resistome`, `pathways` (HUMAnN datasets
  only): the study's rows of the corresponding release table, in long
  form. These are Parquet and need the duckdb package.

- `qc`: one row per sample with read counts and `run_ids`.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
# Downloads go to the cache; tempdir() keeps them out of yours.
qc <- cmgd_read_study(rel, "ZellerG_2014", "qc", cache = tempdir())
head(qc)
#>                            sample_key                        sample_id
#> 1 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p 06e398e0194de8d2aa185b9d8996a474
#> 2 RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9 72080b9ed6d4c860afb54bd9feee501a
#> 3 RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj a08d985474ca4b67bb6fc3bb4093e640
#>                            readset_id   study_name
#> 1 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p ZellerG_2014
#> 2 RS.bZz5VlfYIkTVYKmDibnmPtWb6pkLWBP9 ZellerG_2014
#> 3 RS.l29A5uBFtCKLgc-EPvUhj0hD6Q02Z7qj ZellerG_2014
#>                                                                           run_ids
#> 1                                         ERR478962;ERR478963;ERR480458;ERR480459
#> 2 ERR478964;ERR478965;ERR478966;ERR478967;ERR480460;ERR480461;ERR480462;ERR480463
#> 3 ERR478958;ERR478959;ERR478960;ERR478961;ERR480454;ERR480455;ERR480456;ERR480457
#>   workflow_id version reads_raw reads_decontaminated  bases_raw
#> 1 cmgd_mpa4.2   2.3.0  47190574             47189630 3298640533
#> 2 cmgd_mpa4.2   2.3.0  87631061             87630399 7846466205
#> 3 cmgd_mpa4.2   2.3.0  76003628             76003320 6512170482
#>   bases_decontaminated reads_surviving_fraction bases_surviving_fraction
#> 1           3298570852                        1                        1
#> 2           7846406740                        1                        1
#> 3           6512143912                        1                        1
#>   metaphlan_index metaphlan_profile humann_bundle pipeline_version
#> 1              NA   mpa4.2.6_vJan26            NA            2.3.0
#> 2              NA   mpa4.2.6_vJan26            NA            2.3.0
#> 3              NA   mpa4.2.6_vJan26            NA            2.3.0
#>                                 git_commit
#> 1 793996bafae99c65ce4f9ff85a08f08b68fa6227
#> 2 793996bafae99c65ce4f9ff85a08f08b68fa6227
#> 3 793996bafae99c65ce4f9ff85a08f08b68fa6227
```
