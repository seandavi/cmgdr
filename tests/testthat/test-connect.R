test_that("cmgd_connect attaches the release catalog over HTTP", {
  skip_if_not_installed("duckdb")
  skip_on_cran()  # installs DuckDB extensions from the internet
  rel <- open_release()
  con <- cmgd_connect(rel)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  tables <- DBI::dbGetQuery(con, "SELECT table_name FROM duckdb_tables() WHERE database_name = 'cmgd'")
  expect_setequal(tables$table_name, cmgd_tables(rel)$name)
  n <- DBI::dbGetQuery(con, "
    SELECT study_name, count(*) AS n FROM qc_metrics GROUP BY study_name ORDER BY study_name")
  expect_equal(n$n, c(3, 2))
  expect_error(DBI::dbExecute(con, "DELETE FROM qc_metrics"))
})

test_that("cmgd_connect works with dplyr", {
  skip_if_not_installed("duckdb")
  skip_if_not_installed("dbplyr")
  skip_on_cran()
  con <- cmgd_connect(open_release())
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE))
  species <- dplyr::tbl(con, "taxonomic_profile_metaphlan") |>
    dplyr::filter(study_name == "ArtachoA_2021", rank == "species",
                  data_type == "full_data", is.na(humann_bundle)) |>
    dplyr::collect()
  expect_equal(nrow(species), 6)
})
