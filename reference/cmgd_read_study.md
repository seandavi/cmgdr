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
if (FALSE) { # \dontrun{
rel <- cmgd_release("cmgd_nextflow-2.2.1")
qc <- cmgd_read_study(rel, "ZellerG_2014", "qc")
} # }
```
