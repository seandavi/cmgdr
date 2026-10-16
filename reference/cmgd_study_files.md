# Per-study download files

Per-study download files

## Usage

``` r
cmgd_study_files(rel, study)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

- study:

  Study name, for example `"ZellerG_2014"`.

## Value

A data.frame with columns `name`, `path` (relative to the release URL),
`url`, `size` (bytes), `sha256` and `description`.

## Examples

``` r
if (FALSE) { # \dontrun{
cmgd_study_files(cmgd_release("cmgd_nextflow-2.2.1"), "ZellerG_2014")
} # }
```
