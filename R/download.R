#' cmgdr's download cache directory
#'
#' `tools::R_user_dir("cmgdr", "cache")`. Set the `R_USER_CACHE_DIR`
#' environment variable to move it. Releases are immutable, so cached files
#' never go stale; delete the directory to reclaim space.
#'
#' @return The cache directory path.
#' @export
#' @examples
#' cmgd_cache_dir()
cmgd_cache_dir <- function() {
  tools::R_user_dir("cmgdr", "cache")
}

#' Download a release file, verified and cached
#'
#' Downloads a file into the cache (keyed by its URL) and returns the local
#' path. Files listed in the release's indexes are verified: SHA-256 for table
#' files, per-study files and the DuckLake catalog; byte size for gene-family
#' files (their index has no checksum). A mismatching download is deleted and
#' an error raised. A cached file that still verifies is not downloaded again.
#'
#' @inheritParams cmgd_tables
#' @param path_or_url A path relative to the release URL (as in the `path`
#'   column of [cmgd_files()] or [cmgd_study_files()]) or a full URL (as in the
#'   `url` column of [cmgd_genefamilies()]).
#' @param cache Cache directory.
#' @return The local file path.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_nextflow-2.2.1")
#' cmgd_download(rel, "studies/ZellerG_2014/qc.tsv")
#' }
cmgd_download <- function(rel, path_or_url, cache = cmgd_cache_dir()) {
  stopifnot(length(path_or_url) == 1L)
  url <- if (grepl("^[a-z]+://", path_or_url)) path_or_url else paste0(rel$url, "/", path_or_url)
  expected <- expected_file(rel, url)
  dest <- file.path(cache, gsub(":", "_", sub("^[a-z]+://", "", url)))
  if (file.exists(dest) && is.null(verify_file(dest, expected))) return(dest)

  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  tmp <- paste0(dest, ".part")
  on.exit(unlink(tmp), add = TRUE)
  res <- curl::curl_fetch_disk(url, tmp)
  check_status(res$status_code, url)
  problem <- verify_file(tmp, expected)
  if (!is.null(problem)) stop(problem, " for ", url, "; download discarded", call. = FALSE)
  file.rename(tmp, dest)
  dest
}

# Expected bytes and sha256 of `url` from the release indexes; NULL if unlisted.
expected_file <- function(rel, url) {
  prefix <- paste0(rel$url, "/")
  if (!startsWith(url, prefix)) {
    gf <- genefamily_files(rel)
    hit <- gf[!is.na(gf$url) & gf$url == url, ]
    return(if (!is.null(hit) && nrow(hit)) list(bytes = hit$bytes[1], sha256 = NULL))
  }
  path <- substring(url, nchar(prefix) + 1L)
  ducklake <- rel$manifest$artifacts$ducklake
  if (identical(path, ducklake$location)) {
    return(list(bytes = ducklake$size, sha256 = ducklake$sha256))
  }
  files <- if (startsWith(path, "tables/")) {
    cmgd_files(rel, strsplit(path, "/", fixed = TRUE)[[1]][2])
  } else if (startsWith(path, "studies/")) {
    study_index_files(rel)
  }
  hit <- files[files$path == path, ]
  if (!is.null(hit) && nrow(hit)) list(bytes = hit$bytes[1], sha256 = hit$sha256[1])
}

# NULL if `file` matches `expected`, else a description of the mismatch.
verify_file <- function(file, expected) {
  if (is.null(expected)) return(NULL)
  size <- file.size(file)
  if (!is.null(expected$bytes) && size != expected$bytes) {
    return(sprintf("size mismatch (expected %.0f bytes, got %.0f)", expected$bytes, size))
  }
  if (!is.null(expected$sha256)) {
    got <- digest::digest(file = file, algo = "sha256")
    if (got != expected$sha256) {
      return(sprintf("sha256 mismatch (expected %s, got %s)", expected$sha256, got))
    }
  }
  NULL
}
