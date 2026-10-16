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
if (requireNamespace("duckdb", quietly = TRUE)) {
    rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
    cmgd_find_runs(rel, c("ERR478962", "ERR1474586"), cache = tempdir())
}
#>          run     study_name                          sample_key
#> 1  ERR478962   ZellerG_2014 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p
#> 2 ERR1474586 LassalleF_2017 RS.03kxtlz2sN5chfT1RCwEeJcKuVWWwe-E
#>                            readset_id                          run_accessions
#> 1 RS.8G5cd1ZeZW4RVHDQitQ1t5PV7IHCue2p ERR478962;ERR478963;ERR480458;ERR480459
#> 2 RS.03kxtlz2sN5chfT1RCwEeJcKuVWWwe-E                              ERR1474586
#>      biosample bioproject pipeline_version
#> 1 SAMEA2466896  PRJEB6070            2.3.0
#> 2         <NA>       <NA>            2.3.0
#>                                 git_commit             completed_at
#> 1 793996bafae99c65ce4f9ff85a08f08b68fa6227 2026-10-10T03:50:09.001Z
#> 2 793996bafae99c65ce4f9ff85a08f08b68fa6227 2026-10-12T22:27:05.493Z
```
