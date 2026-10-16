# Changelog

## cmgdr 0.99.0

- Prepared for Bioconductor submission: `biocViews`, version 0.99.0, a
  Quarto vignette that runs against the live site.
- Find datasets and releases from the site’s JSON indexes
  ([`cmgd_datasets()`](https://seandavi.github.io/cmgdr/reference/cmgd_datasets.md),
  [`cmgd_releases()`](https://seandavi.github.io/cmgdr/reference/cmgd_releases.md),
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md)).
- List tables, files and studies; download files into a SHA-256-verified
  cache
  ([`cmgd_tables()`](https://seandavi.github.io/cmgdr/reference/cmgd_tables.md),
  [`cmgd_files()`](https://seandavi.github.io/cmgdr/reference/cmgd_files.md),
  [`cmgd_studies()`](https://seandavi.github.io/cmgdr/reference/cmgd_studies.md),
  [`cmgd_study_files()`](https://seandavi.github.io/cmgdr/reference/cmgd_study_files.md),
  [`cmgd_download()`](https://seandavi.github.io/cmgdr/reference/cmgd_download.md)).
- Read per-study files and build species `TreeSummarizedExperiment`
  objects
  ([`cmgd_read_study()`](https://seandavi.github.io/cmgdr/reference/cmgd_read_study.md),
  [`cmgd_species_tse()`](https://seandavi.github.io/cmgdr/reference/cmgd_species_tse.md)).
- Read the published sample-metadata tables
  ([`cmgd_sample_metadata()`](https://seandavi.github.io/cmgdr/reference/cmgd_sample_metadata.md)),
  look up samples by run accession
  ([`cmgd_find_runs()`](https://seandavi.github.io/cmgdr/reference/cmgd_find_runs.md))
  and read a release’s provenance
  ([`cmgd_provenance()`](https://seandavi.github.io/cmgdr/reference/cmgd_provenance.md)).
- Attach a release’s DuckLake catalog in DuckDB
  ([`cmgd_connect()`](https://seandavi.github.io/cmgdr/reference/cmgd_connect.md)).
- HUMAnN gene-family file indexes
  ([`cmgd_genefamilies()`](https://seandavi.github.io/cmgdr/reference/cmgd_genefamilies.md)).
