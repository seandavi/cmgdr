# cmgdr 0.99.1

* `cmgd_samples_tse()` builds a species `TreeSummarizedExperiment` for any
  samples, across studies, with their sample metadata (from `source`) after
  the `qc.tsv` columns in `colData`, and the licence and sources in
  `metadata()`. Pick samples by filtering
  `cmgd_sample_metadata(rel, wide = TRUE)`, for example with
  `dplyr::filter()` (#17).
* The test fixture's `cmgd_mpa4.2-2.3.0` slice gains `studies/` (species
  profiles and QC for its two studies).

# cmgdr 0.99.0

* `cmgd_connect()` gains a `cache` argument and keeps DuckDB's extensions
  and secrets in `duckdb/` under the cache directory
  (`tools::R_user_dir("cmgdr", "cache")`) instead of `~/.duckdb`; Parquet
  reads never use `~/.duckdb`. Needs duckdb 1.5.4.1 or newer.
* Every example now runs against the live site (small calls on
  `cmgd_mpa4.2-2.3.0`, downloads under `tempdir()`).
* duckdb (>= 1.5.4.1), DBI, TreeSummarizedExperiment, S4Vectors and Matrix
  move from Suggests to Imports: `cmgd_connect()`, Parquet reads and
  `cmgd_species_tse()` no longer need extra installs (#5).
* Prepared for Bioconductor submission: `biocViews`, version 0.99.0, a Quarto
  vignette that runs against the live site.
* Find datasets and releases from the site's JSON indexes (`cmgd_datasets()`,
  `cmgd_releases()`, `cmgd_release()`).
* List tables, files and studies; download files into a SHA-256-verified cache
  (`cmgd_tables()`, `cmgd_files()`, `cmgd_studies()`, `cmgd_study_files()`,
  `cmgd_download()`).
* Read per-study files and build species `TreeSummarizedExperiment` objects
  (`cmgd_read_study()`, `cmgd_species_tse()`).
* Read the published sample-metadata tables (`cmgd_sample_metadata()`), look
  up samples by run accession (`cmgd_find_runs()`) and read a release's
  provenance (`cmgd_provenance()`).
* Attach a release's DuckLake catalog in DuckDB (`cmgd_connect()`).
* HUMAnN gene-family file indexes (`cmgd_genefamilies()`).
