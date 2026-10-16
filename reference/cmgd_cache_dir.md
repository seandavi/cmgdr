# cmgdr's download cache directory

`tools::R_user_dir("cmgdr", "cache")`. Set the `R_USER_CACHE_DIR`
environment variable to move it. Releases are immutable, so cached files
never go stale; delete the directory to reclaim space.

## Usage

``` r
cmgd_cache_dir()
```

## Value

The cache directory path.

## Examples

``` r
cmgd_cache_dir()
#> [1] "/home/runner/.cache/R/cmgdr"
```
