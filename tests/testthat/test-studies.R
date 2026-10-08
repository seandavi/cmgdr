test_that("cmgd_studies and cmgd_study_files read studies/index.json", {
  rel <- open_release()
  studies <- cmgd_studies(rel)
  expect_equal(studies$study_name, c("ArtachoA_2021", "ZellerG_2014"))
  expect_equal(studies$n_samples, c(3, 2))

  files <- cmgd_study_files(rel, "ZellerG_2014")
  expect_setequal(files$name, c("bracken.parquet", "metaphlan.parquet",
                                "metaphlan_species.tsv.gz", "qc.tsv", "resistome.parquet"))
  expect_equal(files$url, paste0(rel$url, "/", files$path))
  expect_false(anyNA(files$description))
  expect_error(cmgd_study_files(rel, "nope"), "no study nope")
})

test_that("cmgd_read_study reads TSV files", {
  rel <- open_release()
  qc <- cmgd_read_study(rel, "ArtachoA_2021", "qc")
  expect_equal(nrow(qc), 3)
  expect_true(all(startsWith(qc$run_ids, "ERR")))
  expect_true(all(is.na(qc$bases_raw)))

  species <- cmgd_read_study(rel, "ArtachoA_2021", "metaphlan_species")
  expect_equal(names(species), c("clade_name", qc$sample_key))
  expect_equal(nrow(species), 3)
  expect_equal(sum(species[-1] == 0), 3)
  expect_error(cmgd_read_study(rel, "ArtachoA_2021", "pathways"), "no pathways.parquet")
})

test_that("cmgd_read_study reads Parquet files with duckdb", {
  skip_if_not_installed("duckdb")
  rel <- open_release(humann)
  pw <- cmgd_read_study(rel, "ZellerG_2014", "pathways")
  expect_equal(nrow(pw), 6)
  expect_setequal(pw$pathway, c("UNMAPPED", "PWY-1042"))
  metaphlan <- cmgd_read_study(rel, "ZellerG_2014", "metaphlan")
  expect_true(all(metaphlan$study_name == "ZellerG_2014"))
})

test_that("cmgd_species_tse builds a sparse species x samples TSE", {
  skip_if_not_installed("TreeSummarizedExperiment")
  rel <- open_release()
  tse <- cmgd_species_tse(rel, "ArtachoA_2021")
  expect_s4_class(tse, "TreeSummarizedExperiment")
  expect_equal(dim(tse), c(3L, 3L))
  ab <- SummarizedExperiment::assay(tse, "relative_abundance")
  expect_s4_class(ab, "dgCMatrix")
  expect_equal(colnames(tse), SummarizedExperiment::colData(tse)$sample_key)
  expect_equal(sum(ab == 0), 3)
  expect_equal(sort(unname(colSums(ab > 0))), c(1, 2, 3))
})

test_that("cmgd_genefamilies indexes and downloads gene-family files", {
  rel <- open_release(humann)
  gf <- cmgd_genefamilies(rel)
  expect_equal(nrow(gf), 5)
  expect_true(all(startsWith(gf$url, site$raw)))
  zeller <- cmgd_genefamilies(rel, study = "ZellerG_2014")
  expect_equal(nrow(zeller), 2)
  one <- cmgd_genefamilies(rel, sample = zeller$sample_key[1])
  expect_equal(one$sample_key, zeller$sample_key[1])

  local <- cmgd_download(rel, one$url, cache = tempfile())
  expect_equal(file.size(local), one$bytes)
  expect_match(readLines(local, n = 1), "^# Gene Family")

  # Without a raw_base override the index's own URLs are used.
  public <- cmgd_release(humann, base = site$base)
  expect_true(all(startsWith(cmgd_genefamilies(public)$url,
                             "https://cmgd-raw.cancerdatasci.org/")))
  expect_error(cmgd_genefamilies(open_release()), "has no gene families")
})

test_that("cmgd_download refuses a gene-family file of the wrong size", {
  rel <- open_release(humann)
  one <- cmgd_genefamilies(rel)[1, ]
  served <- file.path(site$root, "raw", one$key)
  original <- readBin(served, "raw", file.size(served))
  on.exit(writeBin(original, served))
  writeBin(c(original, as.raw(0)), served)
  expect_error(cmgd_download(rel, one$url, cache = tempfile()), "size mismatch")
})
