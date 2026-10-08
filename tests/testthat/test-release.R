test_that("cmgd_datasets reads the site's root index.json", {
  ds <- cmgd_datasets(site$base)
  expect_equal(ds$dataset, c(humann, legacy))
  expect_equal(ds$latest, c("2026-10-08", "2026-10-08"))
  expect_equal(ds$workflow_id[ds$dataset == humann], "cmgd_humann3.9")
  expect_equal(ds$version[ds$dataset == humann], "2.3.0")
})

test_that("cmgd_datasets falls back to the built-in list without a root index", {
  path <- file.path(site$root, "public", "index.json")
  moved <- paste0(path, ".moved")
  file.rename(path, moved)
  on.exit(file.rename(moved, path))
  expect_message(ds <- cmgd_datasets(site$base), "no index.json")
  expect_setequal(ds$dataset, c("cmgd_nextflow-2.2.1", "cmgd_mpa4.2-2.3.0",
                                "cmgd_humann3.9-2.3.0", "cmgd_humann4a1-2.3.0"))
  expect_equal(ds$latest[ds$dataset == legacy], "2026-10-08")
  expect_true(is.na(ds$latest[ds$dataset == "cmgd_mpa4.2-2.3.0"]))
})

test_that("cmgd_datasets refuses an unsupported index spec major version", {
  path <- file.path(site$root, "public", "index.json")
  original <- readLines(path, warn = FALSE)
  on.exit(writeLines(original, path))
  writeLines(sub('"spec_version": "1.0"', '"spec_version": "2.0"', original), path)
  expect_error(cmgd_datasets(site$base), "cmgd index spec version 2.0.*major version 1")
})

test_that("cmgd_releases lists releases.json", {
  rel <- cmgd_releases(legacy, site$base)
  expect_equal(rel$release, "2026-10-08")
  expect_error(cmgd_releases("no_such-1.0", site$base), "not found")
})

test_that("cmgd_release resolves latest and reads the manifest", {
  rel <- open_release()
  expect_s3_class(rel, "cmgd_release")
  expect_equal(rel$release, "2026-10-08")
  expect_equal(rel$url, paste0(site$base, "/", legacy, "/2026-10-08"))
  expect_identical(open_release(release = "2026-10-08")$manifest, rel$manifest)
  expect_output(print(rel), "cmgd_nextflow-2.2.1 2026-10-08")
})

test_that("cmgd_release refuses an unsupported spec major version", {
  path <- file.path(site$root, "public", legacy, "2026-10-08", "manifest.json")
  original <- readLines(path, warn = FALSE)
  on.exit(writeLines(original, path))
  writeLines(sub('"spec_version": "2.0"', '"spec_version": "3.0"', original), path)
  expect_error(open_release(), "publication spec version 3.0.*major version 2")
})

test_that("cmgd_tables and cmgd_files list tables and their files", {
  rel <- open_release()
  tables <- cmgd_tables(rel)
  expect_true("qc_metrics" %in% tables$name)
  expect_false("humann_pathabundance" %in% tables$name)
  expect_equal(tables$row_count[tables$name == "qc_metrics"], 6)

  files <- cmgd_files(rel)
  expect_setequal(files$table, tables$name)
  qc <- cmgd_files(rel, "qc_metrics")
  expect_equal(qc$path, "tables/qc_metrics/data/part-00000.parquet")
  expect_equal(qc$url, paste0(rel$url, "/", qc$path))
  expect_equal(qc$rows, 6)
  expect_match(qc$sha256, "^[0-9a-f]{64}$")
  expect_error(cmgd_files(rel, "nope"), "no table nope")
})
