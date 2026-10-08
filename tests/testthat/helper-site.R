# The fixture site (data-raw/make_fixture.sh) copied to a temp dir, catalogs
# gunzipped, served over local HTTP with HEAD and single-range GETs (what
# DuckDB's httpfs needs). /public is cmgd-public, /raw stands in for cmgd-raw.
fixture_site <- function() {
  root <- tempfile("site")
  dir.create(root)
  file.copy(test_path("fixtures", "site"), root, recursive = TRUE)
  root <- file.path(root, "site")
  for (gz in list.files(root, "catalog\\.ducklake\\.gz$", recursive = TRUE, full.names = TRUE)) {
    con <- gzfile(gz, "rb")
    writeBin(readBin(con, "raw", 1e8), sub("\\.gz$", "", gz))
    close(con)
    unlink(gz)
  }
  root
}

range_app <- function(root) {
  app <- webfakes::new_app()
  app$locals$root <- root
  handler <- function(req, res) {
    path <- file.path(req$app$locals$root, sub("^/", "", utils::URLdecode(req$path)))
    if (!file.exists(path) || dir.exists(path)) return(res$send_status(404L))
    size <- file.size(path)
    res$set_header("Accept-Ranges", "bytes")
    res$set_type("application/octet-stream")
    if (req$method == "HEAD") {
      res$set_header("Content-Length", size)
      return(res$send_status(200L))
    }
    from <- 0
    to <- size - 1
    range <- req$get_header("Range")
    if (!is.null(range)) {
      bounds <- strsplit(sub("^bytes=", "", range), "-", fixed = TRUE)[[1]]
      if (nzchar(bounds[1])) from <- as.numeric(bounds[1])
      if (length(bounds) > 1 && nzchar(bounds[2])) to <- min(as.numeric(bounds[2]), size - 1)
      res$set_status(206L)
      res$set_header("Content-Range", sprintf("bytes %.0f-%.0f/%.0f", from, to, size))
    }
    con <- file(path, "rb")
    on.exit(close(con))
    seek(con, from)
    res$send(readBin(con, "raw", to - from + 1))
  }
  app$get(webfakes::new_regexp(".*"), handler)
  app$head(webfakes::new_regexp(".*"), handler)
  app
}

# One server for the whole test run.
site <- local({
  root <- fixture_site()
  proc <- webfakes::new_app_process(range_app(root))
  list(root = root, proc = proc, base = proc$url("/public"), raw = proc$url("/raw"))
})

legacy <- "cmgd_nextflow-2.2.1"
humann <- "cmgd_humann3.9-2.3.0"

open_release <- function(dataset = legacy, ...) {
  cmgd_release(dataset, base = site$base, raw_base = site$raw, ...)
}

# Keep downloads out of the user's cache.
Sys.setenv(R_USER_CACHE_DIR = tempfile("cache"))
