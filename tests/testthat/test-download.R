test_that("cmgd_download verifies, caches and skips re-downloads", {
  rel <- open_release()
  cache <- tempfile()
  qc <- cmgd_files(rel, "qc_metrics")
  local <- cmgd_download(rel, qc$path, cache = cache)
  expect_true(file.exists(local))
  expect_equal(digest::digest(file = local, algo = "sha256"), qc$sha256)
  expect_equal(cmgd_download(rel, qc$url, cache = cache), local)

  # A cached copy that still verifies is reused: no request is made.
  mtime <- file.mtime(local)
  Sys.sleep(1.1)
  cmgd_download(rel, qc$path, cache = cache)
  expect_equal(file.mtime(local), mtime)

  # A corrupted cached copy is replaced.
  writeLines("corrupt", local)
  cmgd_download(rel, qc$path, cache = cache)
  expect_equal(digest::digest(file = local, algo = "sha256"), qc$sha256)
})

test_that("cmgd_download refuses a file that does not match its checksum", {
  rel <- open_release()
  path <- "studies/ZellerG_2014/qc.tsv"
  served <- file.path(site$root, "public", legacy, "2026-10-08", path)
  original <- readBin(served, "raw", file.size(served))
  on.exit(writeBin(original, served))
  tampered <- original
  tampered[length(tampered) - 1] <- as.raw(utf8ToInt("X"))
  writeBin(tampered, served)
  cache <- tempfile()
  expect_error(cmgd_download(rel, path, cache = cache), "sha256 mismatch")
  expect_length(list.files(cache, recursive = TRUE), 0)
})

test_that("cmgd_download fetches and verifies the DuckLake catalog", {
  rel <- open_release()
  local <- cmgd_download(rel, "catalog.ducklake", cache = tempfile())
  expect_equal(file.size(local), rel$manifest$artifacts$ducklake$size)
})

test_that("cmgd_download reports missing files", {
  expect_error(cmgd_download(open_release(), "studies/nope/qc.tsv", cache = tempfile()),
               "not found")
})
