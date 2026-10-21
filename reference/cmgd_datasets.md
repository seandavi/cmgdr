# Published cMD datasets

Each pipeline registration (a pipeline version plus its configuration)
is published as its own dataset, named `<workflow_id>-<version>`, for
example `cmgd_nextflow-2.2.1`. The site's root `index.json` lists every
dataset with its latest release. If the site has no root index, a
built-in list of dataset ids is checked instead, with a message.

## Usage

``` r
cmgd_datasets(base = cmgd_public_base)
```

## Arguments

- base:

  Base URL of the public release site.

## Value

A data.frame with columns `dataset`, `workflow_id`, `version` and
`latest` (the latest release id, `NA` when the dataset has no release
yet).

## Examples

``` r
cmgd_datasets()
#>               dataset   workflow_id version     latest
#> 1   cmgd_mpa4.2-2.3.0   cmgd_mpa4.2   2.3.0 2026-10-20
#> 2 cmgd_nextflow-2.2.1 cmgd_nextflow   2.2.1 2026-10-08
```
