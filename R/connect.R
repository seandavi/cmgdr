#' Attach a release's tables in DuckDB
#'
#' Opens an in-memory DuckDB connection and attaches the release's frozen,
#' read-only DuckLake catalog over HTTPS as database `cmgd` (also made the
#' default, so `dplyr::tbl(con, "qc_metrics")` works). Attaching is quick:
#' DuckDB fetches only the parts of the Parquet files a query touches.
#'
#' Needs the DBI and duckdb (1.5.4.1 or newer) packages. The first call
#' downloads DuckDB's `ducklake` and `httpfs` extensions into
#' `duckdb/` in the cache directory (not `~/.duckdb`), where later
#' sessions reuse them. Close the connection with
#' `DBI::dbDisconnect(con, shutdown = TRUE)`.
#'
#' @inheritParams cmgd_tables
#' @inheritParams cmgd_download
#' @return A DBI connection.
#' @export
#' @examples
#' if (requireNamespace("duckdb", quietly = TRUE)) {
#'     rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
#'     # DuckDB's extensions are kept under `cache` too.
#'     con <- cmgd_connect(rel, cache = tempdir())
#'     DBI::dbGetQuery(con, "
#'         SELECT study_name, count(*) AS n_samples
#'         FROM qc_metrics GROUP BY study_name
#'         ORDER BY n_samples DESC LIMIT 5")
#'     DBI::dbDisconnect(con, shutdown = TRUE)
#' }
cmgd_connect <- function(rel, cache = cmgd_cache_dir()) {
    need(c("DBI", "duckdb"), "attach a release in DuckDB")
    home <- file.path(cache, "duckdb")
    dir.create(home, recursive = TRUE, showWarnings = FALSE)
    con <- DBI::dbConnect(duckdb::duckdb(home = home))
    for (sql in c(
        "INSTALL ducklake",
        "LOAD ducklake",
        "INSTALL httpfs",
        "LOAD httpfs"
    )) {
        DBI::dbExecute(con, sql)
    }
    DBI::dbExecute(
        con,
        sprintf(
            paste0(
                "ATTACH '%s/%s' AS cmgd ",
                "(TYPE DUCKLAKE, DATA_PATH '%s/', OVERRIDE_DATA_PATH, ",
                "READ_ONLY)"
            ),
            rel$url,
            rel$manifest$artifacts$ducklake$location,
            rel$url
        )
    )
    DBI::dbExecute(con, "USE cmgd")
    con
}

#' HUMAnN gene-family files
#'
#' Gene families are too large for the release tables, so each sample's HUMAnN
#' gene-family table is a separate download from cmgd-raw (HUMAnN datasets
#' only). The release's `genefamilies/index.json` lists the studies; each
#' study's files are in their own index, fetched only when asked for. Values are
#' HUMAnN's unnormalized output in the bundle's units. Pass a `url` to
#' [cmgd_download()] to fetch a file, verified by size
#' and SHA-256.
#'
#' @inheritParams cmgd_tables
#' @param study `study_name` values. `NULL` returns the list of studies.
#' @param sample Optional `sample_key` values to keep (needs `study`).
#' @return Without `study`: a data.frame of studies with `study_name`,
#'   `n_samples`, `n_files`, `path`, `size` and `sha256` (of
#'   the study's index). With `study`: one row per file with `study_name`,
#'   `sample_key`, `readset_id`, `humann_bundle`, `branch`,
#'   `key` (the object key in cmgd-raw), `url`, `size` (bytes),
#'   `sha256` and `rows`.
#' @export
#' @examples
#' # Runs once a HUMAnN dataset is published; none is on the site yet.
#' ds <- cmgd_datasets()
#' humann <- ds$dataset[startsWith(ds$dataset, "cmgd_humann") &
#'     !is.na(ds$latest)]
#' if (length(humann)) {
#'     rel <- cmgd_release(humann[1])
#'     studies <- cmgd_genefamilies(rel)
#'     gf <- cmgd_genefamilies(rel, study = studies$study_name[1])
#'     head(gf)
#'     # cmgd_download(rel, gf$url[1], cache = tempdir())
#' }
cmgd_genefamilies <- function(rel, study = NULL, sample = NULL) {
    index <- genefamily_index(rel)
    if (is.null(study)) {
        if (!is.null(sample)) {
            stop("give the study of the samples", call. = FALSE)
        }
        return(index$studies)
    }
    unknown <- setdiff(study, index$studies$study_name)
    if (length(unknown)) {
        stop(
            "no gene families for study ",
            paste(unknown, collapse = ", "),
            " in ",
            rel$dataset,
            "/",
            rel$release,
            call. = FALSE
        )
    }
    paths <- index$studies$path[match(study, index$studies$study_name)]
    files <- do.call(rbind, lapply(paths, genefamily_study_files, rel = rel))
    if (!is.null(sample)) {
        files <- files[files$sample_key %in% sample, ]
    }
    rownames(files) <- NULL
    files
}

# genefamilies/index.json, verified against studies/index.json's artifacts.
genefamily_index <- function(rel) {
    path <- "genefamilies/index.json"
    artifacts <- cmgd_index(rel, "studies/index.json")$artifacts
    if (!is.data.frame(artifacts) || !path %in% artifacts$path) {
        stop(
            rel$dataset,
            " has no gene families (only HUMAnN datasets do)",
            call. = FALSE
        )
    }
    cmgd_index(
        rel,
        path,
        as.list(artifacts[artifacts$path == path, c("size", "sha256")])
    )
}

# One study's gene-family files (`path` from genefamilies/index.json), with
# `url` resolved against `raw_base`.
genefamily_study_files <- function(rel, path) {
    studies <- genefamily_index(rel)$studies
    hit <- studies[studies$path == path, ]
    files <- cmgd_index(
        rel,
        path,
        list(size = hit$size, sha256 = hit$sha256)
    )$files
    if (!is.null(rel$raw_base)) {
        files$url <- paste0(sub("/+$", "", rel$raw_base), "/", files$key)
    }
    files
}
