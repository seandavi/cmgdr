#' Studies in a release
#'
#' From the release's `studies/index.json`.
#'
#' @inheritParams cmgd_tables
#' @return A data.frame with columns `study_name` and `n_samples`.
#' @export
#' @examples
#' \dontrun{
#' cmgd_studies(cmgd_release("cmgd_nextflow-2.2.1"))
#' }
cmgd_studies <- function(rel) {
  memo_json(rel, "studies/index.json")$studies[c("study_name", "n_samples")]
}

#' Per-study download files
#'
#' @inheritParams cmgd_tables
#' @param study Study name, for example `"ZellerG_2014"`.
#' @return A data.frame with columns `name`, `path` (relative to the release
#'   URL), `url`, `bytes`, `sha256` and `description`.
#' @export
#' @examples
#' \dontrun{
#' cmgd_study_files(cmgd_release("cmgd_nextflow-2.2.1"), "ZellerG_2014")
#' }
cmgd_study_files <- function(rel, study) {
  files <- study_index_files(rel)
  files <- files[files$study_name == study, names(files) != "study_name"]
  if (!nrow(files)) {
    stop("no study ", study, " in ", rel$dataset, "/", rel$release,
         " (see cmgd_studies())", call. = FALSE)
  }
  rownames(files) <- NULL
  files
}

# Every per-study file of the release, one row each, with `study_name`.
study_index_files <- function(rel) {
  index <- memo_json(rel, "studies/index.json")
  files <- do.call(rbind, Map(function(study, f) cbind(study_name = study, f),
                              index$studies$study_name, index$studies$files))
  files$url <- paste0(rel$url, "/", files$path)
  descriptions <- unlist(index$file_descriptions)
  files$description <- unname(descriptions[files$name])
  rownames(files) <- NULL
  files[c("study_name", "name", "path", "url", "bytes", "sha256", "description")]
}

study_file_names <- c(
  metaphlan_species = "metaphlan_species.tsv.gz", metaphlan = "metaphlan.parquet",
  bracken = "bracken.parquet", resistome = "resistome.parquet",
  pathways = "pathways.parquet", qc = "qc.tsv")

#' Read a per-study file
#'
#' Downloads (via [cmgd_download()], so cached and verified) and reads one of a
#' study's ready-made files:
#'
#' * `metaphlan_species`: species x samples relative abundance (percent) from
#'   the main MetaPhlAn pass on all reads; column `clade_name` then one column
#'   per `sample_key`; `0` means not detected.
#' * `metaphlan`, `bracken`, `resistome`, `pathways` (HUMAnN datasets only): the
#'   study's rows of the corresponding release table, in long form. These are
#'   Parquet and need the duckdb package.
#' * `qc`: one row per sample with read counts and `run_ids`.
#'
#' @inheritParams cmgd_study_files
#' @inheritParams cmgd_download
#' @param what Which file to read.
#' @return A data.frame.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_nextflow-2.2.1")
#' qc <- cmgd_read_study(rel, "ZellerG_2014", "qc")
#' }
cmgd_read_study <- function(rel, study, what = names(study_file_names),
                            cache = cmgd_cache_dir()) {
  what <- match.arg(what)
  name <- study_file_names[[what]]
  files <- cmgd_study_files(rel, study)
  if (!name %in% files$name) {
    stop(rel$dataset, " has no ", name, " for ", study, " (files: ",
         paste(files$name, collapse = ", "), ")", call. = FALSE)
  }
  local <- cmgd_download(rel, files$path[files$name == name], cache = cache)
  if (endsWith(name, ".parquet")) return(read_parquet(local))
  utils::read.delim(local, check.names = FALSE, na.strings = "")
}

read_parquet <- function(file) {
  need(c("DBI", "duckdb"), "read Parquet files")
  con <- DBI::dbConnect(duckdb::duckdb())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  DBI::dbGetQuery(con, "SELECT * FROM read_parquet(?)", params = list(file))
}

#' A study's species profile as a TreeSummarizedExperiment
#'
#' Builds a species x samples TreeSummarizedExperiment from the study's
#' `metaphlan_species.tsv.gz` (relative abundance in percent, main MetaPhlAn
#' pass, all reads) with a sparse `relative_abundance` assay and the study's
#' `qc.tsv` as `colData`. Every sample in `qc.tsv` is a column; a sample with
#' no species rows is all zero.
#'
#' Needs the Bioconductor package TreeSummarizedExperiment and Matrix.
#'
#' @inheritParams cmgd_read_study
#' @return A `TreeSummarizedExperiment`.
#' @export
#' @examples
#' \dontrun{
#' rel <- cmgd_release("cmgd_nextflow-2.2.1")
#' tse <- cmgd_species_tse(rel, "ZellerG_2014")
#' }
cmgd_species_tse <- function(rel, study, cache = cmgd_cache_dir()) {
  need(c("TreeSummarizedExperiment", "Matrix", "S4Vectors"), "build a TreeSummarizedExperiment")
  species <- cmgd_read_study(rel, study, "metaphlan_species", cache = cache)
  qc <- cmgd_read_study(rel, study, "qc", cache = cache)
  abundance <- matrix(0, nrow(species), nrow(qc),
                      dimnames = list(species$clade_name, qc$sample_key))
  measured <- intersect(names(species)[-1], qc$sample_key)
  abundance[, measured] <- as.matrix(species[measured])
  TreeSummarizedExperiment::TreeSummarizedExperiment(
    assays = list(relative_abundance = Matrix::Matrix(abundance, sparse = TRUE)),
    colData = S4Vectors::DataFrame(qc, row.names = qc$sample_key, check.names = FALSE))
}

need <- function(pkgs, why) {
  missing <- pkgs[!vapply(pkgs, requireNamespace, logical(1), quietly = TRUE)]
  if (length(missing)) {
    stop("cmgdr needs ", paste(missing, collapse = ", "), " to ", why, ". Install with:\n",
         "  install.packages(\"BiocManager\"); BiocManager::install(c(",
         paste0("\"", missing, "\"", collapse = ", "), "))", call. = FALSE)
  }
}
