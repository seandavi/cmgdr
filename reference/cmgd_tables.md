# Tables in a release

Tables in a release

## Usage

``` r
cmgd_tables(rel)
```

## Arguments

- rel:

  A release from
  [`cmgd_release()`](https://seandavi.github.io/cmgdr/reference/cmgd_release.md).

## Value

A data.frame with one row per table: `name`, `description`, `grain`,
`row_count` and `license`.

## Examples

``` r
if (FALSE) { # \dontrun{
cmgd_tables(cmgd_release("cmgd_nextflow-2.2.1"))
} # }
```
