# Launch Steam Game Finder

Open the Shiny app supplied with the installed package.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Arguments passed to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), such
  as launch.browser = FALSE or a local port number.

## Value

Runs the app until the user stops it.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
