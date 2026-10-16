# Find samples by run accession

Looks up SRA/ENA run accessions (`SRR...`, `ERR...`, `DRR...`) in the
release's `samples` table, where a sample's runs are `;`-joined in
`run_accessions`.

## Usage

``` r
cmgd_find_runs(rel, run, cache = cmgd_cache_dir())
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- run:

  Run accessions.

- cache:

  Cache directory.

## Value

A data.frame with one row per `run`, in order: `run`, then the matching
`samples` row (`study_name`, `sample_key`, ...); all `NA` for a run not
in the release. Errors with class `cmgdr_no_metadata` if the release has
no `samples` table.

## Examples

``` r
if (FALSE) { # \dontrun{
rel <- cmgd_release("cmgd_mpa4.2-2.3.0")
cmgd_find_runs(rel, c("ERR478962", "ERR1474586"))
} # }
```
