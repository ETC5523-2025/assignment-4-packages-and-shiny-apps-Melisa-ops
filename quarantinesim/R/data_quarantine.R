#' Quarantine outbreak simulation dataset
#'
#' This dataset contains simulated epidemiological scenarios representing
#' potential quarantine outbreak conditions based on varying transmission
#' and vaccination parameters. Each row represents a single simulation
#' scenario defined by combinations of R0 (basic reproduction number),
#' vaccine effectiveness (VE), and vaccination coverage.
#'
#' @format A data frame with 320 rows and 8 variables.
#'
#' @details
#' Variables include:
#' - `key`: Unique identifier combining R0, VE, and coverage values
#' - `R0`: Basic reproduction number representing disease transmissibility
#' - `VE`: Vaccine effectiveness (0–1)
#' - `coverage`: Proportion of the population vaccinated (0–1)
#' - `traveller_ob_prob`: Probability of an outbreak initiated by a traveller
#' - `worker_ob_prob`: Probability of an outbreak initiated by a quarantine worker
#' - `chance50`: Iteration when outbreak probability reaches 50%
#' - `chance95`: Iteration when outbreak probability reaches 95%
#'
#' @source Simulated data prepared for the Monash University ETC5532 assignment
#'   on R package development and Shiny application (2025).
"data_quarantine"
