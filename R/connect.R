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
#' gene-family table is a separate download from cmgd-raw, listed in the
#' release's `genefamilies/index.json` (HUMAnN datasets only). Values are
#' HUMAnN's unnormalized output in the bundle's units. Pass a `url` to
#' [cmgd_download()] to fetch a file.
#'
#' @inheritParams cmgd_tables
#' @param study,sample Optional `study_name` and `sample_key` values to keep.
#' @return A data.frame with columns `study_name`, `sample_key`, `readset_id`,
#'   `humann_bundle`, `branch`, `key` (the object key in cmgd-raw), `url`,
#'   `bytes` and `rows`.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_humann3.9-2.3.0")
#' gf <- cmgd_genefamilies(rel, study = "ZellerG_2014")
#' cmgd_download(rel, gf$url[1])
#' }
cmgd_genefamilies <- function(rel, study = NULL, sample = NULL) {
  files <- genefamily_files(rel)
  if (is.null(files)) {
    stop(rel$dataset, " has no gene families (only HUMAnN datasets do)", call. = FALSE)
  }
  if (!is.null(study)) files <- files[files$study_name %in% study, ]
  if (!is.null(sample)) files <- files[files$sample_key %in% sample, ]
  rownames(files) <- NULL
  files
}

# The gene-family index with `url` resolved against `raw_base`; NULL if the
# release has no index.
genefamily_files <- function(rel) {
  files <- tryCatch(memo_json(rel, "genefamilies/index.json")$files,
                    cmgd_not_found = function(e) NULL)
  if (!is.null(files) && !is.null(rel$raw_base)) {
    files$url <- paste0(sub("/+$", "", rel$raw_base), "/", files$key)
  }
  files
}
