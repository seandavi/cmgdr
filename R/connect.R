#' Attach a release's tables in DuckDB
#'
#' Opens an in-memory DuckDB connection and attaches the release's frozen,
#' read-only DuckLake catalog over HTTPS as database `cmgd` (also made the
#' default, so `dplyr::tbl(con, "qc_metrics")` works). Attaching is quick:
#' DuckDB fetches only the parts of the Parquet files a query touches.
#'
#' Needs the DBI and duckdb packages (DuckDB 1.5.2 or newer). The first call
#' downloads DuckDB's `ducklake` and `httpfs` extensions. Close the connection
#' with `DBI::dbDisconnect(con, shutdown = TRUE)`.
#'
#' @inheritParams cmgd_tables
#' @return A DBI connection.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_nextflow-2.2.1")
#' con <- cmgd_connect(rel)
#' DBI::dbGetQuery(con, "
#'   SELECT study_name, count(*) AS n_samples
#'   FROM qc_metrics GROUP BY study_name ORDER BY n_samples DESC")
#'
#' library(dplyr)
#' tbl(con, "taxonomic_profile_metaphlan") |>
#'   filter(study_name == "ZellerG_2014", rank == "species",
#'          data_type == "full_data", is.na(humann_bundle)) |>
#'   count(clade_name, sort = TRUE) |>
#'   collect()
#' DBI::dbDisconnect(con, shutdown = TRUE)
#' }
cmgd_connect <- function(rel) {
  need(c("DBI", "duckdb"), "attach a release in DuckDB")
  con <- DBI::dbConnect(duckdb::duckdb())
  for (sql in c("INSTALL ducklake", "LOAD ducklake", "INSTALL httpfs", "LOAD httpfs")) {
    DBI::dbExecute(con, sql)
  }
  DBI::dbExecute(con, sprintf(paste0(
    "ATTACH '%s/%s' AS cmgd ",
    "(TYPE DUCKLAKE, DATA_PATH '%s/', OVERRIDE_DATA_PATH, READ_ONLY)"),
    rel$url, rel$manifest$artifacts$ducklake$location, rel$url))
  DBI::dbExecute(con, "USE cmgd")
  con
}

#' HUMAnN gene-family files
#'
#' Gene families are too large for the release tables, so each sample's HUMAnN
#' gene-family table is a separate download from cmgd-raw (HUMAnN datasets
#' only). The release's `genefamilies/index.json` lists the studies; each
#' study's files are in their own index, fetched only when asked for. Values
#' are HUMAnN's unnormalized output in the bundle's units. Pass a `url` to
#' [cmgd_download()] to fetch a file, verified by size and SHA-256.
#'
#' @inheritParams cmgd_tables
#' @param study `study_name` values. `NULL` returns the list of studies.
#' @param sample Optional `sample_key` values to keep (needs `study`).
#' @return Without `study`: a data.frame of studies with `study_name`,
#'   `n_samples`, `n_files`, `path`, `size` and `sha256` (of the study's
#'   index). With `study`: one row per file with `study_name`, `sample_key`,
#'   `readset_id`, `humann_bundle`, `branch`, `key` (the object key in
#'   cmgd-raw), `url`, `size` (bytes), `sha256` and `rows`.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_humann3.9-2.3.0")
#' cmgd_genefamilies(rel)
#' gf <- cmgd_genefamilies(rel, study = "ZellerG_2014")
#' cmgd_download(rel, gf$url[1])
#' }
cmgd_genefamilies <- function(rel, study = NULL, sample = NULL) {
  index <- genefamily_index(rel)
  if (is.null(study)) {
    if (!is.null(sample)) stop("give the study of the samples", call. = FALSE)
    return(index$studies)
  }
  unknown <- setdiff(study, index$studies$study_name)
  if (length(unknown)) {
    stop("no gene families for study ", paste(unknown, collapse = ", "), " in ",
         rel$dataset, "/", rel$release, call. = FALSE)
  }
  paths <- index$studies$path[match(study, index$studies$study_name)]
  files <- do.call(rbind, lapply(paths, genefamily_study_files, rel = rel))
  if (!is.null(sample)) files <- files[files$sample_key %in% sample, ]
  rownames(files) <- NULL
  files
}

# genefamilies/index.json, verified against studies/index.json's artifacts.
genefamily_index <- function(rel) {
  path <- "genefamilies/index.json"
  artifacts <- cmgd_index(rel, "studies/index.json")$artifacts
  if (!is.data.frame(artifacts) || !path %in% artifacts$path) {
    stop(rel$dataset, " has no gene families (only HUMAnN datasets do)", call. = FALSE)
  }
  cmgd_index(rel, path, as.list(artifacts[artifacts$path == path, c("size", "sha256")]))
}

# One study's gene-family files (`path` from genefamilies/index.json), with
# `url` resolved against `raw_base`.
genefamily_study_files <- function(rel, path) {
  studies <- genefamily_index(rel)$studies
  hit <- studies[studies$path == path, ]
  files <- cmgd_index(rel, path, list(size = hit$size, sha256 = hit$sha256))$files
  if (!is.null(rel$raw_base)) {
    files$url <- paste0(sub("/+$", "", rel$raw_base), "/", files$key)
  }
  files
}
