# Studies in a release

From the release's `studies/index.json`.

## Usage

``` r
cmgd_studies(rel)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

## Value

A data.frame with columns `study_name` and `n_samples`.

## Examples

``` r
if (FALSE) { # \dontrun{
cmgd_studies(cmgd_release("cmgd_nextflow-2.2.1"))
} # }
```
