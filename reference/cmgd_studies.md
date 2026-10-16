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
rel <- cmgd_release("cmgd_mpa4.2-2.3.0", release = "2026-10-16")
head(cmgd_studies(rel))
#>       study_name n_samples
#> 1  AsnicarF_2017        24
#> 2      BaiX_2021        24
#> 3   DavidLA_2015         1
#> 4       HMP_2012         4
#> 5 LassalleF_2017        23
#> 6  WibowoMC_2021        22
```
