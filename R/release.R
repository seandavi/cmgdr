cmgd_public_base <- "https://cmgd-public.cancerdatasci.org"

# Major version of the cdsci-lake publication spec this client reads.
supported_spec_major <- 2L

# Dataset ids published so far: `<workflow_id>-<version>`, one per pipeline
# registration. The site cannot be listed and has no top-level catalog.
known_datasets <- c("cmgd_nextflow-2.2.1", "cmgd_mpa4.2-2.3.0",
                    "cmgd_humann3.9-2.3.0", "cmgd_humann4a1-2.3.0")

#' Known cMD datasets
#'
#' Each pipeline registration (a pipeline version plus its configuration) is
#' published as its own dataset, named `<workflow_id>-<version>`, for example
#' `cmgd_nextflow-2.2.1`. The public site cannot be listed and has no
#' top-level catalog, so this function checks a built-in list of dataset ids
#' and reports each one's latest release.
#'
#' @param base Base URL of the public release site.
#' @param datasets Dataset ids to check. Pass your own to look up a dataset
#'   published after this version of cmgdr.
#' @return A data.frame with columns `dataset`, `workflow_id`, `version` and
#'   `latest` (the latest release id, `NA` when the dataset has no release yet).
#' @export
#' @examples
#' \dontrun{
#' cmgd_datasets()
#' }
cmgd_datasets <- function(base = cmgd_public_base, datasets = known_datasets) {
  latest <- vapply(datasets, function(d) {
    tryCatch(fetch_json(dataset_url(base, d, "latest.json"))$release,
             cmgd_not_found = function(e) NA_character_)
  }, character(1), USE.NAMES = FALSE)
  data.frame(dataset = datasets,
             workflow_id = sub("-[^-]*$", "", datasets),
             version = sub("^.*-", "", datasets),
             latest = latest)
}

#' Releases of a dataset
#'
#' A release is an immutable full snapshot of a dataset, named by its UTC build
#' date (`2026-10-08`; a second release that day is `2026-10-08.2`).
#'
#' @param dataset Dataset id, for example `"cmgd_nextflow-2.2.1"`; see
#'   [cmgd_datasets()].
#' @inheritParams cmgd_datasets
#' @return A data.frame from the dataset's `releases.json`, oldest first, with
#'   columns `release`, `release_date`, `published_at` and `pinned`.
#' @export
#' @examples
#' \dontrun{
#' cmgd_releases("cmgd_nextflow-2.2.1")
#' }
cmgd_releases <- function(dataset, base = cmgd_public_base) {
  fetch_json(dataset_url(base, dataset, "releases.json"))$releases
}

#' Open a release
#'
#' Reads the release's `manifest.json` and returns a handle that every other
#' cmgdr function takes. Errors if the manifest uses a publication spec major
#' version this version of cmgdr does not understand.
#'
#' @inheritParams cmgd_releases
#' @param release Release id, or `"latest"` for the newest release.
#' @param raw_base Base URL to download gene-family files from, overriding
#'   the URLs in `genefamilies/index.json`. `NULL` uses the index's URLs.
#' @return A `cmgd_release` object: a list with `dataset`, `release`, `url`
#'   (the release's base URL), `base`, `raw_base` and `manifest`.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_nextflow-2.2.1")
#' rel
#' }
cmgd_release <- function(dataset, release = "latest", base = cmgd_public_base,
                         raw_base = NULL) {
  if (identical(release, "latest")) {
    release <- fetch_json(dataset_url(base, dataset, "latest.json"))$release
  }
  url <- dataset_url(base, dataset, release)
  manifest <- fetch_json(paste0(url, "/manifest.json"))
  major <- as.integer(sub("\\..*$", "", manifest$spec_version))
  if (is.na(major) || major != supported_spec_major) {
    stop(sprintf(paste0(
      "%s/%s uses publication spec_version %s; this cmgdr reads major version %d.\n",
      "Update cmgdr: remotes::install_github(\"seandavi/cmgdr\")"),
      dataset, release, manifest$spec_version, supported_spec_major), call. = FALSE)
  }
  structure(list(dataset = dataset, release = release, url = url, base = base,
                 raw_base = raw_base, manifest = manifest, memo = new.env()),
            class = "cmgd_release")
}

#' @export
print.cmgd_release <- function(x, ...) {
  cat("<cmgd_release> ", x$dataset, " ", x$release, "\n", sep = "")
  cat("  url:    ", x$url, "\n", sep = "")
  cat("  tables: ", paste(x$manifest$tables$name, collapse = ", "), "\n", sep = "")
  invisible(x)
}

#' Tables in a release
#'
#' @param rel A release from [cmgd_release()].
#' @return A data.frame with one row per table: `name`, `description`,
#'   `grain`, `row_count` and `license`.
#' @export
#' @examples
#' \dontrun{
#' cmgd_tables(cmgd_release("cmgd_nextflow-2.2.1"))
#' }
cmgd_tables <- function(rel) {
  rel$manifest$tables[c("name", "description", "grain", "row_count", "license")]
}

#' Data files of release tables
#'
#' Each table's Parquet data files, from `tables/<table>/files.json`.
#'
#' @inheritParams cmgd_tables
#' @param table Table names; `NULL` for every table.
#' @return A data.frame with columns `table`, `path` (relative to the release
#'   URL), `url`, `bytes`, `sha256` and `rows`.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_nextflow-2.2.1")
#' cmgd_files(rel, "qc_metrics")
#' }
cmgd_files <- function(rel, table = NULL) {
  tables <- rel$manifest$tables
  if (is.null(table)) table <- tables$name
  unknown <- setdiff(table, tables$name)
  if (length(unknown)) {
    stop("no table ", paste(unknown, collapse = ", "), " in ", rel$dataset, "/",
         rel$release, " (tables: ", paste(tables$name, collapse = ", "), ")",
         call. = FALSE)
  }
  out <- lapply(table, function(t) {
    files_json <- tables$files[tables$name == t]  # tables/<t>/files.json
    f <- memo_json(rel, files_json)$files
    # file uris are relative to the table directory
    path <- paste0(dirname(files_json), "/", f$uri)
    data.frame(table = t, path = path, url = paste0(rel$url, "/", path),
               bytes = f$size, sha256 = f$sha256, rows = f$rows)
  })
  do.call(rbind, out)
}

dataset_url <- function(base, dataset, ...) {
  paste(sub("/+$", "", base), dataset, ..., sep = "/")
}

# JSON at `path` (relative to the release URL), fetched once per release handle.
memo_json <- function(rel, path) {
  if (is.null(rel$memo[[path]])) {
    rel$memo[[path]] <- fetch_json(paste0(rel$url, "/", path))
  }
  rel$memo[[path]]
}

fetch_json <- function(url) {
  jsonlite::fromJSON(rawToChar(http_get(url)))
}

http_get <- function(url) {
  res <- curl::curl_fetch_memory(url)
  check_status(res$status_code, url)
  res$content
}

check_status <- function(status, url) {
  if (status == 404L) {
    stop(structure(class = c("cmgd_not_found", "error", "condition"), list(
      message = paste0("not found: ", url,
                       "\n(is the dataset or release id right? has it been published yet?)"),
      call = NULL)))
  }
  if (status >= 400L) stop("HTTP ", status, " from ", url, call. = FALSE)
}
