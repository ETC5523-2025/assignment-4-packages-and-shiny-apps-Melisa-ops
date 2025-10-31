#' @import dplyr
#' @import ggplot2
NULL

#' Run the quarantinesim Shiny application
#'
#' This function launches the quarantinesim Shiny app, which lets users
#' explore outbreak probabilities by R0, vaccine effectiveness (VE),
#' and vaccination coverage.
#'
#' @return None. This function runs the Shiny app.
#'
#' @examples
#' if (interactive()) {
#'   run_quarantinesim()
#' }
#'
#' @import shiny
#' @export
run_quarantinesim <- function() {
  app_dir <- system.file("app/app.R", package = "quarantinesim")
  shiny::runApp(app_dir, display.mode = "normal")
}
