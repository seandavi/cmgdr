test_that("cmgd_studies and cmgd_study_files read studies/index.json", {
  rel <- open_release()
  studies <- cmgd_studies(rel)
  expect_equal(studies$study_name, c("ArtachoA_2021", "ZellerG_2014"))
  expect_equal(studies$n_samples, c(4, 2))

  files <- cmgd_study_files(rel, "ZellerG_2014")
  expect_setequal(files$name, c("bracken.parquet", "metaphlan.parquet",
                                "metaphlan_species.tsv.gz", "qc.tsv", "resistome.parquet"))
  expect_equal(files$url, paste0(rel$url, "/", files$path))
  expect_false(anyNA(files$description))
  expect_error(cmgd_study_files(rel, "nope"), "no study nope")
})

test_that("studies/index.json with an unsupported spec major version is refused", {
  path <- file.path(site$root, "public", legacy, "2026-10-08", "studies", "index.json")
  original <- readLines(path, warn = FALSE)
  on.exit(writeLines(original, path))
  writeLines(sub('"spec_version": "1.0"', '"spec_version": "2.0"', original), path)
  expect_error(cmgd_studies(open_release()), "cmgd index spec version 2.0")
})

test_that("cmgd_read_study reads TSV files", {
  rel <- open_release()
  qc <- cmgd_read_study(rel, "ArtachoA_2021", "qc")
  expect_equal(nrow(qc), 4)
  expect_true(all(startsWith(qc$run_ids, "ERR")))
  expect_true(all(is.na(qc$bases_raw)))

  # every sample is a column; one sample has no species rows: an all-zero column
  species <- cmgd_read_study(rel, "ArtachoA_2021", "metaphlan_species")
  expect_equal(names(species), c("clade_name", qc$sample_key))
  expect_equal(nrow(species), 3)
  expect_equal(sum(species[-1] == 0), 6)
  expect_equal(sum(colSums(species[-1]) == 0), 1)
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
  expect_equal(dim(tse), c(3L, 4L))
  ab <- SummarizedExperiment::assay(tse, "relative_abundance")
  expect_s4_class(ab, "dgCMatrix")
  expect_equal(colnames(tse), SummarizedExperiment::colData(tse)$sample_key)
  expect_equal(sum(ab == 0), 6)
  expect_equal(sort(unname(Matrix::colSums(ab > 0))), c(0, 1, 2, 3))
})

test_that("cmgd_genefamilies lists studies, then one study's files", {
  rel <- open_release(humann)
  studies <- cmgd_genefamilies(rel)
  expect_equal(studies$study_name, c("ArtachoA_2021", "ZellerG_2014"))
  expect_equal(studies$n_files, c(4, 2))
  expect_equal(studies$path, paste0("genefamilies/", studies$study_name, ".json"))
  expect_null(rel$memo[["genefamilies/ZellerG_2014.json"]])  # not fetched yet

  zeller <- cmgd_genefamilies(rel, study = "ZellerG_2014")
  expect_equal(nrow(zeller), 2)
  expect_true(all(zeller$study_name == "ZellerG_2014"))
  expect_true(all(startsWith(zeller$url, site$raw)))
  expect_null(rel$memo[["genefamilies/ArtachoA_2021.json"]])  # only the asked-for study
  expect_equal(nrow(cmgd_genefamilies(rel, study = studies$study_name)), 6)
  one <- cmgd_genefamilies(rel, "ZellerG_2014", sample = zeller$sample_key[1])
  expect_equal(one$sample_key, zeller$sample_key[1])

  local <- cmgd_download(rel, one$url, cache = tempfile())
  expect_equal(file.size(local), one$size)
  expect_equal(digest::digest(file = local, algo = "sha256"), one$sha256)
  expect_match(readLines(local, n = 1), "^# Gene Family")
  tsv <- cmgd_download(rel, "genefamilies/index.tsv", cache = tempfile())
  expect_equal(nrow(utils::read.delim(tsv)), 6)

  # Without a raw_base override the index's own URLs are used.
  public <- cmgd_release(humann, base = site$base)
  expect_true(all(startsWith(cmgd_genefamilies(public, "ZellerG_2014")$url,
                             "https://cmgd-raw.cancerdatasci.org/")))
  expect_error(cmgd_genefamilies(rel, "nope"), "no gene families for study nope")
  expect_error(cmgd_genefamilies(rel, sample = "x"), "give the study")
  expect_error(cmgd_genefamilies(open_release()), "has no gene families")
})

test_that("a tampered study gene-family index is refused", {
  path <- file.path(site$root, "public", humann, "2026-10-08", "genefamilies", "ZellerG_2014.json")
  original <- readBin(path, "raw", file.size(path))
  on.exit(writeBin(original, path))
  writeBin(charToRaw(sub("full_data", "full_dat4", rawToChar(original))), path)
  expect_error(cmgd_genefamilies(open_release(humann), "ZellerG_2014"), "sha256 mismatch")
})

test_that("cmgd_download refuses a gene-family file that does not verify", {
  rel <- open_release(humann)
  one <- cmgd_genefamilies(rel, "ZellerG_2014")[1, ]
  served <- file.path(site$root, "raw", one$key)
  original <- readBin(served, "raw", file.size(served))
  on.exit(writeBin(original, served))
  writeBin(c(original, as.raw(0)), served)
  expect_error(cmgd_download(rel, one$url, cache = tempfile()), "size mismatch")
  tampered <- original
  tampered[length(tampered)] <- as.raw(bitwXor(as.integer(tampered[length(tampered)]), 1L))
  writeBin(tampered, served)
  expect_error(cmgd_download(rel, one$url, cache = tempfile()), "sha256 mismatch")
})
