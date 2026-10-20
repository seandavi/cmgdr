# Download a release file, verified and cached

Downloads a file into the cache (keyed by its URL) and returns the local
path. Files listed in the release's indexes are verified by size and
SHA-256: table files, per-study files, the DuckLake catalog, the
gene-family indexes, and gene-family files from a study already listed
with
[`cmgd_genefamilies()`](https://seandavi.github.io/cmgdr/reference/cmgd_genefamilies.md)
on the same release handle. A mismatching download is deleted and an
error raised. A cached file that still verifies is not downloaded again.

## Usage

``` r
cmgd_download(rel, path_or_url, cache = cmgd_cache_dir())
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- path_or_url:

  A path relative to the release URL (as in the `path` column of
  [`cmgd_files()`](https://seandavi.github.io/cmgdr/reference/cmgd_files.md)
  or
  [`cmgd_study_files()`](https://seandavi.github.io/cmgdr/reference/cmgd_study_files.md))
  or a full URL (as in the `url` column of
  [`cmgd_genefamilies()`](https://seandavi.github.io/cmgdr/reference/cmgd_genefamilies.md)).

- cache:

  Cache directory.

## Value

The local file path.

## Examples

``` r
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
path <- cmgd_download(rel, "studies/ZellerG_2014/qc.tsv",
    cache = tempdir()
)
path
#> [1] "/tmp/RtmpbqlxGU/cmgd-public.cancerdatasci.org/cmgd_mpa4.2-2.3.0/2026-10-16/studies/ZellerG_2014/qc.tsv"
```
