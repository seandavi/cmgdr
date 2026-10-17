# Sample metadata tables

Reads one of the release's published sample-metadata tables (releases
since `cmgd_mpa4.2-2.3.0` / `2026-10-16`), downloaded via
[`cmgd_download()`](https://seandavi.github.io/cmgdr/reference/cmgd_download.md)
(so cached and verified) and read with duckdb:

## Usage

``` r
cmgd_sample_metadata(rel, source = names(metadata_tables), study = NULL,
    wide = FALSE, cache = cmgd_cache_dir())
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- source:

  Which metadata table to read.

- study:

  Optional `study_name` values to keep.

- wide:

  `FALSE` for the published long table as is. `TRUE` for one row per
  sample in the `samples` table: `study_name`, `sample_key`,
  `biosample`, `bioproject`, `run_accessions`, then one character column
  per `field` (`NA` where a sample has no value; a sample with more than
  one distinct value for a field gets them `;`-joined).

- cache:

  Cache directory.

## Value

A data.frame with attributes `license` (the table's licence from the
manifest) and `sources` (the pinned rows of `metadata_sources` the table
draws on: source, release, DOI, licence). Errors with class
`cmgdr_no_metadata` if the release has no sample-metadata tables.

## Details

- `harmonized`: one value per sample and harmonized field, with the
  source it came from (CC-BY-4.0: it mixes in Olm-derived values).

- `cmd`: curatedMetagenomicData curation, one row per field (CC0-1.0).

- `olm`: the Olm lab Microbiome Repo, one row per field, with Olm's
  route and confidence (CC-BY-4.0).

For a CC-BY table a message gives the licence and the source DOI to
cite; silence it with
[`suppressMessages()`](https://rdrr.io/r/base/message.html). Joining
metadata into a `TreeSummarizedExperiment` is left to higher-level
packages.

## Examples

``` r
if (requireNamespace("duckdb", quietly = TRUE)) {
    rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
    meta <- cmgd_sample_metadata(rel, "cmd",
        study = "ZellerG_2014", wide = TRUE, cache = tempdir()
    )
    meta[1:3, 1:6]
    attr(meta, "sources")
}
#>   source                                  release package_version  doi license
#> 1    cmd 6828fb9abdfc27a91b02e20568d27332eaf19ca4            <NA> <NA> CC0-1.0
#>                                                             sha256
#> 1 51b2be460816ceec68238e144f903feb4e74b20ce27ad3be4d06ae242a7c15bd
#>                      loaded_at pinned
#> 1 2026-10-15 21:09:41.84543-06   TRUE
```
