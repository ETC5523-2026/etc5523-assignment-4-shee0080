#' Launch Steam Game Finder
#'
#' Open the Shiny app supplied with the installed package.
#'
#' @param ... Arguments passed to [shiny::runApp()], such as
#'   launch.browser = FALSE or a local port number.
#' @return Runs the app until the user stops it.
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @importFrom utils head
#' @export
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function(...) {
  app_dir <- system.file("app", package = "steamfinder", mustWork = TRUE)
  shiny::runApp(app_dir, ...)
}
