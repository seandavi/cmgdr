# Every test here runs against the fixture site, served by webfakes.
skip_if_not_installed("webfakes")

mpa_release <- function() open_release(mpa, release = "2026-10-16")

# The fixture's Parquet file for `table`, read directly.
fixture_table <- function(table) {
  read_parquet(file.path(site$root, "public", mpa, "2026-10-16", "tables", table,
                         "data", "part-00000.parquet"))
}

meta <- function(...) suppressMessages(cmgd_sample_metadata(mpa_release(), ..., cache = tempfile()))

test_that("harmonized long is the published table", {
  x <- meta()
  published <- fixture_table("sample_metadata_harmonized")
  schema <- jsonlite::fromJSON(file.path(site$root, "public", mpa, "2026-10-16", "tables",
                                         "sample_metadata_harmonized", "schema.json"))
  expect_equal(names(x), schema$columns$name)
  expect_equal(names(x), names(published))
  expect_equal(nrow(x), nrow(published))
  expect_false(anyDuplicated(x[c("sample_key", "field")]) > 0)
})

test_that("cmd and olm return their own tables", {
  cmd <- meta("cmd")
  olm <- meta("olm")
  expect_equal(nrow(cmd), nrow(fixture_table("sample_metadata_cmd")))
  expect_equal(nrow(olm), nrow(fixture_table("sample_metadata_olm")))
  expect_equal(unique(cmd$source), "cmd")
  expect_equal(unique(olm$source), "olm")
  expect_false("evidence_quote" %in% names(olm))
})

test_that("study filters rows and unknown studies are errors", {
  x <- meta(study = "ZellerG_2014")
  expect_equal(unique(x$study_name), "ZellerG_2014")
  all <- meta()
  expect_equal(nrow(x), sum(all$study_name == "ZellerG_2014"))
  expect_error(meta(study = "NoSuchStudy_2099"), "NoSuchStudy_2099")
})

test_that("wide has one row per sample with character field columns", {
  samples <- fixture_table("samples")
  for (study in list(NULL, "LassalleF_2017")) {
    keep <- if (is.null(study)) samples else samples[samples$study_name == study, ]
    for (source in c("harmonized", "cmd", "olm")) {
      w <- meta(source, study = study, wide = TRUE)
      expect_equal(nrow(w), nrow(keep))
      expect_false(anyDuplicated(w$sample_key) > 0)
      expect_setequal(w$sample_key, keep$sample_key)
      expect_equal(names(w)[1:5], c("study_name", "sample_key", "biosample", "bioproject",
                                    "run_accessions"))
      expect_true(all(vapply(w[-(1:5)], is.character, logical(1))))
    }
  }
  # LassalleF_2017 has no Olm metadata: its samples are rows of NAs.
  olm <- meta("olm", wide = TRUE)
  lassalle <- olm[olm$study_name == "LassalleF_2017", -(1:5)]
  expect_equal(nrow(lassalle), sum(samples$study_name == "LassalleF_2017"))
  expect_true(all(is.na(lassalle)))
  # A known value matches the long table.
  long <- meta()
  w <- meta(wide = TRUE)
  row <- long[long$field == "sex", ][1, ]
  expect_equal(w$sex[w$sample_key == row$sample_key], row$value)
})

test_that("licence, attribution and sources are attached", {
  doi <- "10.5281/zenodo.23087712"
  rel <- mpa_release()
  expect_message(h <- cmgd_sample_metadata(rel, cache = tempfile()), doi, fixed = TRUE)
  expect_message(o <- cmgd_sample_metadata(rel, "olm", cache = tempfile()), doi, fixed = TRUE)
  expect_no_message(c <- cmgd_sample_metadata(rel, "cmd", cache = tempfile()))
  expect_equal(attr(h, "license"), "CC-BY-4.0")
  expect_equal(attr(o, "license"), "CC-BY-4.0")
  expect_equal(attr(c, "license"), "CC0-1.0")
  expect_setequal(attr(h, "sources")$source, c("cmd", "olm"))
  expect_equal(attr(o, "sources")$source, "olm")
  expect_equal(attr(o, "sources")$doi, doi)
  expect_equal(attr(c, "sources")$source, "cmd")
})

test_that("a release without metadata is a classed error", {
  err <- expect_error(cmgd_sample_metadata(open_release(), cache = tempfile()),
                      class = "cmgdr_no_metadata")
  expect_match(conditionMessage(err), "cmgd_nextflow-2.2.1/2026-10-08")
  expect_match(conditionMessage(err), "samples, sample_metadata_harmonized, metadata_sources")
})

test_that("a second identical call downloads nothing", {
  rel <- mpa_release()
  cache <- tempfile()
  first <- suppressMessages(cmgd_sample_metadata(rel, wide = TRUE, cache = cache))
  files <- list.files(cache, recursive = TRUE, full.names = TRUE)
  expect_length(files, 3)
  mtime <- file.mtime(files)
  Sys.sleep(1.1)
  second <- suppressMessages(cmgd_sample_metadata(rel, wide = TRUE, cache = cache))
  expect_equal(file.mtime(files), mtime)
  expect_identical(second, first)
})

test_that("live: cmgd_mpa4.2-2.3.0 2026-10-16", {
  skip_on_cran()
  skip_if_offline("cmgd-public.cancerdatasci.org")
  rel <- cmgd_release(mpa, release = "2026-10-16")
  cache <- tempfile()
  expect_equal(nrow(suppressMessages(cmgd_sample_metadata(rel, cache = cache))), 562)
  expect_equal(nrow(suppressMessages(cmgd_sample_metadata(rel, wide = TRUE, cache = cache))), 125)
  expect_equal(nrow(suppressMessages(
    cmgd_sample_metadata(rel, study = "BaiX_2021", wide = TRUE, cache = cache))), 24)
})

test_that("cmgd_find_runs splits run_accessions and keeps input order", {
  rel <- mpa_release()
  x <- cmgd_find_runs(rel, c("ERR480459", "ERR1474586", "SRR0000000", "ERR478962"),
                      cache = tempfile())
  expect_equal(x$run, c("ERR480459", "ERR1474586", "SRR0000000", "ERR478962"))
  expect_equal(x$study_name, c("ZellerG_2014", "LassalleF_2017", NA, "ZellerG_2014"))
  expect_equal(x$sample_key[1], x$sample_key[4])  # two runs of one sample
  expect_true(all(is.na(x[3, -1])))
  expect_error(cmgd_find_runs(open_release(), "ERR1", cache = tempfile()),
               class = "cmgdr_no_metadata")
})
