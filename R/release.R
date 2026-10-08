cmgd_public_base <- "https://cmgd-public.cancerdatasci.org"

# Major versions of the specs this client reads: cdsci-lake's publication
# spec (manifest.json, files.json, releases.json) and cmgd's own index spec
# (index.json, studies/index.json, genefamilies/*.json).
supported_spec_major <- 2L
supported_index_major <- 1L

# Fallback for a site without a root index.json: dataset ids published so far.
known_datasets <- c("cmgd_nextflow-2.2.1", "cmgd_mpa4.2-2.3.0",
                    "cmgd_humann3.9-2.3.0", "cmgd_humann4a1-2.3.0")

#' Published cMD datasets
#'
#' Each pipeline registration (a pipeline version plus its configuration) is
#' published as its own dataset, named `<workflow_id>-<version>`, for example
#' `cmgd_nextflow-2.2.1`. The site's root `index.json` lists every dataset with
#' its latest release. If the site has no root index, a built-in list of
#' dataset ids is checked instead, with a message.
#'
#' @param base Base URL of the public release site.
#' @return A data.frame with columns `dataset`, `workflow_id`, `version` and
#'   `latest` (the latest release id, `NA` when the dataset has no release yet).
#' @export
#' @examples
#' \dontrun{
#' cmgd_datasets()
#' }
cmgd_datasets <- function(base = cmgd_public_base) {
  url <- paste0(sub("/+$", "", base), "/index.json")
  index <- tryCatch(fetch_json(url), cmgd_not_found = function(e) NULL)
  if (!is.null(index)) {
    check_spec(index$spec_version, supported_index_major, "cmgd index spec", url)
    ds <- index$datasets
    return(data.frame(dataset = ds$id, workflow_id = ds$workflow_id,
                      version = ds$version, latest = ds$latest_release))
  }
  message("no index.json at ", base, "; checking cmgdr's built-in dataset list")
  latest <- vapply(known_datasets, function(d) {
    tryCatch(fetch_json(dataset_url(base, d, "latest.json"))$release,
             cmgd_not_found = function(e) NA_character_)
  }, character(1), USE.NAMES = FALSE)
  data.frame(dataset = known_datasets,
             workflow_id = sub("-[^-]*$", "", known_datasets),
             version = sub("^.*-", "", known_datasets),
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
  check_spec(manifest$spec_version, supported_spec_major, "publication spec",
             paste0(dataset, "/", release))
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
#'   URL), `url`, `size` (bytes), `sha256` and `rows`.
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
               size = f$size, sha256 = f$sha256, rows = f$rows)
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

# A cmgd index at `path` in the release, fetched once per release handle,
# verified against `expected` (`size`, `sha256`) when given, spec-checked.
cmgd_index <- function(rel, path, expected = NULL) {
  if (is.null(rel$memo[[path]])) {
    url <- paste0(rel$url, "/", path)
    bytes <- http_get(url)
    problem <- verify_bytes(bytes, expected)
    if (!is.null(problem)) stop(problem, " for ", url, call. = FALSE)
    index <- jsonlite::fromJSON(rawToChar(bytes))
    check_spec(index$spec_version, supported_index_major, "cmgd index spec", url)
    rel$memo[[path]] <- index
  }
  rel$memo[[path]]
}

check_spec <- function(spec_version, supported, spec, where) {
  major <- suppressWarnings(as.integer(sub("\\..*$", "", spec_version %||% NA)))
  if (is.na(major) || major != supported) {
    stop(sprintf(paste0(
      "%s uses %s version %s; this cmgdr reads major version %d.\n",
      "Update cmgdr: remotes::install_github(\"seandavi/cmgdr\")"),
      where, spec, spec_version %||% "(none)", supported), call. = FALSE)
  }
}

`%||%` <- function(x, y) if (is.null(x)) y else x

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
