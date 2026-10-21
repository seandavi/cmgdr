metadata_tables <- c(
    harmonized = "sample_metadata_harmonized",
    cmd = "sample_metadata_cmd",
    olm = "sample_metadata_olm"
)
# The `metadata_sources` each table draws on (harmonized mixes both).
metadata_table_sources <- list(
    harmonized = c("cmd", "olm"),
    cmd = "cmd",
    olm = "olm"
)

#' Sample metadata tables
#'
#' Reads one of the release's published sample-metadata tables (releases since
#' `cmgd_mpa4.2-2.3.0` / `2026-10-16`), downloaded via
#' [cmgd_download()] (so cached and verified) and read
#' with duckdb:
#'
#' * `harmonized`: one value per sample and harmonized field, with the
#'   source it came from (CC-BY-4.0: it mixes in Olm-derived values).
#' * `cmd`: curatedMetagenomicData curation, one row per field (CC0-1.0).
#' * `olm`: the Olm lab Microbiome Repo, one row per field, with Olm's
#'   route and confidence (CC-BY-4.0).
#'
#' For a CC-BY table a message gives the licence and the source DOI to cite;
#' silence it with [suppressMessages()].
#'
#' To pick samples, filter the wide table, for example
#' `cmgd_sample_metadata(rel, wide = TRUE) |> dplyr::filter(...)`, and pass
#' the result to [cmgd_samples_tse()] for their species profiles with this
#' metadata as `colData`.
#'
#' @inheritParams cmgd_read_study
#' @param source Which metadata table to read.
#' @param study Optional `study_name` values to keep.
#' @param wide `FALSE` for the published long table as is. `TRUE` for one
#'   row per sample in the `samples` table: `study_name`,
#'   `sample_key`, `biosample`, `bioproject`, `run_accessions`,
#'   then one character column per `field` (`NA` where a sample has no
#'   value; a sample with more than one distinct value for a field gets them
#'   `;`-joined).
#' @return A data.frame with attributes `license` (the table's licence from the
#'   manifest) and `sources` (the pinned rows of `metadata_sources` the
#'   table draws on: source, release, DOI, licence). Errors with class
#'   `cmgdr_no_metadata` if the release has no sample-metadata tables.
#' @usage
#' cmgd_sample_metadata(rel, source = names(metadata_tables), study = NULL,
#'     wide = FALSE, cache = cmgd_cache_dir())
#' @export
#' @examples
#' if (requireNamespace("duckdb", quietly = TRUE)) {
#'     rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
#'     meta <- cmgd_sample_metadata(rel, "cmd",
#'         study = "ZellerG_2014", wide = TRUE, cache = tempdir()
#'     )
#'     meta[1:3, 1:6]
#'     attr(meta, "sources")
#'     # Pick samples by their metadata.
#'     if (requireNamespace("dplyr", quietly = TRUE)) {
#'         dplyr::filter(meta, health_condition == "case")$sample_key
#'     }
#' }
# styler: off
# (styler indents a wrapped signature by 2 whatever `indent_by` is;
# Bioconductor style wants multiples of 4.)
cmgd_sample_metadata <- function(
    rel, source = names(metadata_tables), study = NULL, wide = FALSE,
    cache = cmgd_cache_dir()) {
    # styler: on
    source <- match.arg(source)
    table <- metadata_tables[[source]]
    tables <- rel$manifest$tables
    missing <- setdiff(c("samples", table, "metadata_sources"), tables$name)
    if (length(missing)) {
        cmgdr_abort(
            "cmgdr_no_metadata",
            rel$dataset, "/", rel$release,
            " has no sample metadata (missing tables: ",
            paste(missing, collapse = ", "), ")"
        )
    }
    long <- read_table(rel, table, cache)
    samples <- read_table(rel, "samples", cache)
    if (!is.null(study)) {
        unknown <- setdiff(study, samples$study_name)
        if (length(unknown)) {
            stop(
                "no study ",
                paste(unknown, collapse = ", "),
                " in ",
                rel$dataset,
                "/",
                rel$release,
                " (see cmgd_studies())",
                call. = FALSE
            )
        }
        samples <- samples[samples$study_name %in% study, ]
        long <- long[long$study_name %in% study, ]
    }
    license <- tables$license[tables$name == table]
    sources <- cite_sources(rel, source, table, license, cache)
    out <- if (wide) widen(samples, long) else long
    rownames(out) <- NULL
    structure(out, license = license, sources = `rownames<-`(sources, NULL))
}

#' Species profiles of any samples as a TreeSummarizedExperiment
#'
#' Builds a species x samples `TreeSummarizedExperiment` for an arbitrary set
#' of samples, possibly from several studies, with their sample metadata as
#' `colData`. Pick the samples by filtering
#' `cmgd_sample_metadata(rel, wide = TRUE)`, for example with
#' `dplyr::filter()`.
#'
#' Each sample's study comes from the release's `samples` table. The
#' `relative_abundance` assay (sparse, percent) is built from each study's
#' `metaphlan_species.tsv.gz` as in [cmgd_species_tse()]: rows are the union
#' of the studies' species, `0` where a species is absent. `colData` is the
#' study's `qc.tsv` row followed by the wide metadata columns from `source`
#' (`NA` where a sample has no value).
#'
#' @inheritParams cmgd_sample_metadata
#' @param samples `sample_key` values, or a data.frame with a `sample_key`
#'   column such as a filtered `cmgd_sample_metadata(rel, wide = TRUE)`.
#'   Columns are in this order.
#' @return A `TreeSummarizedExperiment`. `metadata()` has `license` and
#'   `sources` of the metadata table, as for [cmgd_sample_metadata()], which
#'   also gives the attribution message for a CC-BY table. Errors naming any
#'   `samples` not in the release, and with class `cmgdr_no_metadata` if the
#'   release has no sample-metadata tables.
#' @usage
#' cmgd_samples_tse(rel, samples, source = names(metadata_tables),
#'     cache = cmgd_cache_dir())
#' @export
#' @examples
#' if (requireNamespace("duckdb", quietly = TRUE)) {
#'     rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
#'     meta <- cmgd_sample_metadata(rel, wide = TRUE, cache = tempdir())
#'     # Female cases, across studies
#'     picked <- meta[meta$health_condition %in% "case", ]
#'     picked <- picked[picked$sex %in% "female", ]
#'     tse <- cmgd_samples_tse(rel, picked, cache = tempdir())
#'     tse
#'     table(tse$study_name)
#' }
cmgd_samples_tse <- function(rel, samples, source = names(metadata_tables),
                             cache = cmgd_cache_dir()) {
    source <- match.arg(source)
    if (is.data.frame(samples)) {
        samples <- samples$sample_key
    }
    if (!length(samples)) {
        stop("no samples given", call. = FALSE)
    }
    meta <- cmgd_sample_metadata(rel, source, wide = TRUE, cache = cache)
    unknown <- setdiff(samples, meta$sample_key)
    if (length(unknown)) {
        stop(
            "no sample ",
            paste(unknown, collapse = ", "),
            " in ",
            rel$dataset,
            "/",
            rel$release,
            call. = FALSE
        )
    }
    info <- list(
        license = attr(meta, "license"),
        sources = attr(meta, "sources")
    )
    meta <- meta[match(samples, meta$sample_key), ]
    parts <- lapply(
        unique(meta$study_name),
        function(study) study_species(rel, study, cache)
    )
    species <- unique(unlist(lapply(parts, function(p) rownames(p$abundance))))
    # Each study's matrix on the shared species rows, then columns in order.
    padded <- lapply(parts, function(p) {
        t <- Matrix::mat2triplet(p$abundance)
        Matrix::sparseMatrix(
            i = match(rownames(p$abundance), species)[t$i],
            j = t$j,
            x = t$x,
            dims = c(length(species), ncol(p$abundance)),
            dimnames = list(species, colnames(p$abundance))
        )
    })
    abundance <- do.call(cbind, padded)[, samples, drop = FALSE]
    qc <- do.call(rbind, lapply(parts, function(p) p$qc))
    qc <- qc[match(samples, qc$sample_key), ]
    col_data <- cbind(qc, meta[setdiff(names(meta), names(qc))])
    TreeSummarizedExperiment::TreeSummarizedExperiment(
        assays = list(relative_abundance = abundance),
        colData = S4Vectors::DataFrame(
            col_data,
            row.names = samples,
            check.names = FALSE
        ),
        metadata = info
    )
}

# The pinned `metadata_sources` rows that `source` draws on. For a CC-BY
# `table`, a message gives the licence and the DOIs to cite.
cite_sources <- function(rel, source, table, license, cache) {
    sources <- read_table(rel, "metadata_sources", cache)
    sources <- sources[
        sources$pinned & sources$source %in% metadata_table_sources[[source]],
    ]
    if (startsWith(license, "CC-BY")) {
        dois <- unique(sources$doi[!is.na(sources$doi)])
        message(
            table,
            " is licensed ",
            license,
            "; attribution required: cite ",
            paste0("doi:", dois, collapse = ", ")
        )
    }
    sources
}

# One row per sample, one character column per field of `long`.
widen <- function(samples, long) {
    out <- samples[c(
        "study_name",
        "sample_key",
        "biosample",
        "bioproject",
        "run_accessions"
    )]
    for (f in sort(unique(long$field))) {
        hit <- long[long$field == f & !is.na(long$value), ]
        values <- tapply(hit$value, hit$sample_key, function(v) {
            paste(unique(v), collapse = ";")
        })
        out[[f]] <- as.character(values[out$sample_key])
    }
    out
}

# A whole release table, from its files.json, downloaded and read with duckdb.
read_table <- function(rel, table, cache) {
    files <- cmgd_files(rel, table)
    do.call(
        rbind,
        lapply(files$path, function(p) {
            read_parquet(cmgd_download(rel, p, cache = cache))
        })
    )
}

#' Find samples by run accession
#'
#' Looks up SRA/ENA run accessions (`SRR...`, `ERR...`, `DRR...`) in
#' the release's `samples` table, where a sample's runs are `;`-joined in
#' `run_accessions`.
#'
#' @inheritParams cmgd_read_study
#' @param run Run accessions.
#' @return A data.frame with one row per `run`, in order: `run`, then the
#'   matching `samples` row (`study_name`, `sample_key`, ...); all
#'   `NA` for a run not in the release. Errors with class
#'   `cmgdr_no_metadata` if the release has no `samples` table.
#' @export
#' @examples
#' if (requireNamespace("duckdb", quietly = TRUE)) {
#'     rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
#'     cmgd_find_runs(rel, c("ERR478962", "ERR1474586"), cache = tempdir())
#' }
cmgd_find_runs <- function(rel, run, cache = cmgd_cache_dir()) {
    if (!"samples" %in% rel$manifest$tables$name) {
        cmgdr_abort(
            "cmgdr_no_metadata",
            rel$dataset, "/", rel$release, " has no samples table"
        )
    }
    samples <- read_table(rel, "samples", cache)
    runs <- strsplit(samples$run_accessions, ";", fixed = TRUE)
    row <- rep(seq_len(nrow(samples)), lengths(runs))
    hit <- row[match(run, trimws(unlist(runs)))]
    out <- cbind(run = run, samples[hit, , drop = FALSE])
    rownames(out) <- NULL
    out
}
