# HUMAnN gene-family files

Gene families are too large for the release tables, so each sample's
HUMAnN gene-family table is a separate download from cmgd-raw (HUMAnN
datasets only). The release's `genefamilies/index.json` lists the
studies; each study's files are in their own index, fetched only when
asked for. Values are HUMAnN's unnormalized output in the bundle's
units. Pass a `url` to
[`cmgd_download()`](https://seandavi.github.io/cmgdr/reference/cmgd_download.md)
to fetch a file, verified by size and SHA-256.

## Usage

``` r
cmgd_genefamilies(rel, study = NULL, sample = NULL)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- study:

  `study_name` values. `NULL` returns the list of studies.

- sample:

  Optional `sample_key` values to keep (needs `study`).

## Value

Without `study`: a data.frame of studies with `study_name`, `n_samples`,
`n_files`, `path`, `size` and `sha256` (of the study's index). With
`study`: one row per file with `study_name`, `sample_key`, `readset_id`,
`humann_bundle`, `branch`, `key` (the object key in cmgd-raw), `url`,
`size` (bytes), `sha256` and `rows`.

## Examples

``` r
# Runs once a HUMAnN dataset is published; none is on the site yet.
ds <- cmgd_datasets()
humann <- ds$dataset[startsWith(ds$dataset, "cmgd_humann") &
    !is.na(ds$latest)]
if (length(humann)) {
    rel <- cmgd_release(humann[1])
    studies <- cmgd_genefamilies(rel)
    gf <- cmgd_genefamilies(rel, study = studies$study_name[1])
    head(gf)
    # cmgd_download(rel, gf$url[1], cache = tempdir())
}
```
