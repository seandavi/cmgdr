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
[`suppressMessages()`](https://rdrr.io/r/base/message.html).

To pick samples, filter the wide table, for example
`cmgd_sample_metadata(rel, wide = TRUE) |> dplyr::filter(...)`, and pass
the result to
[`cmgd_samples_tse()`](https://seandavi.github.io/cmgdr/reference/cmgd_samples_tse.md)
for their species profiles with this metadata as `colData`.

## Examples

``` r
if (requireNamespace("duckdb", quietly = TRUE)) {
    rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
    meta <- cmgd_sample_metadata(rel, "cmd",
        study = "ZellerG_2014", wide = TRUE, cache = tempdir()
    )
    meta[1:3, 1:6]
    attr(meta, "sources")
    # Pick samples by their metadata.
    if (requireNamespace("dplyr", quietly = TRUE)) {
        dplyr::filter(meta, health_condition == "case")$sample_key
    }
}
#> character(0)
```
