# cmgdr 0.99.0

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
