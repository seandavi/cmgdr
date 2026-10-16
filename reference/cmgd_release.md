# Open a release

Reads the release's `manifest.json` and returns a handle that every
other cmgdr function takes. Errors if the manifest uses a publication
spec major version this version of cmgdr does not understand.

## Usage

``` r
cmgd_release(
  dataset,
  release = "latest",
  base = cmgd_public_base,
  raw_base = NULL
)
```

## Arguments

- dataset:

  Dataset id, for example `"cmgd_nextflow-2.2.1"`; see
  [`cmgd_datasets()`](https://seandavi.github.io/cmgdr/reference/cmgd_datasets.md).

- release:

  Release id, or `"latest"` for the newest release.

- base:

  Base URL of the public release site.

- raw_base:

  Base URL to download gene-family files from, overriding the URLs in
  `genefamilies/index.json`. `NULL` uses the index's URLs.

## Value

A `cmgd_release` object: a list with `dataset`, `release`, `url` (the
release's base URL), `base`, `raw_base` and `manifest`.

## Examples

``` r
if (FALSE) { # \dontrun{
rel <- cmgd_release("cmgd_nextflow-2.2.1")
rel
} # }
```
