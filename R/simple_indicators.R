# R/simple_indicators.R

#' Gross Output Identity Check (Validation)
#'
#' Verifies the fundamental Leontief identity \eqn{X = B \times Y}.
#' This function is primarily used for data validation to ensure the inverse matrix ($B$)
#' is consistent with the observed output ($X$).
#'
#' @param mrio_panel MRIO data object.
#' @param year Year to analyze.
#' @return A \code{data.table} comparing calculated vs. observed output, including a \code{diff} column.
#' @import data.table
#' @import Matrix
#' @export
calculate_gross_output_identity <- function(mrio_panel, year) {
  mats <- get_year_objects(mrio_panel, year)
  S <- length(mrio_panel$metadata$countries)
  N <- length(mrio_panel$metadata$sectors)
  
  Y_global <- Matrix::rowSums(mats$Y)
  X_calculated <- as.numeric(mats$B %*% Y_global)
  
  data.table(
    year = year,
    country = rep(mrio_panel$metadata$countries, each = N),
    sector = rep(mrio_panel$metadata$sectors, times = S),
    X_calculated = X_calculated,
    X_observed = mats$X,
    diff = X_calculated - mats$X
  )
}

#' Calculate Total Bilateral Gross Exports
#'
#' Calculates total gross exports from Country S to the world based on the formula:
#' \eqn{EX_{sr} = A_{sr}X_r + Y_{sr}}.
#'
#' @param mrio_panel MRIO data object.
#' @param year Year to analyze.
#' @return A \code{data.table} of total exports by sector.
#' @import data.table
#' @import Matrix
#' @export
calculate_total_exports_eq5 <- function(mrio_panel, year) {
  mats <- get_year_objects(mrio_panel, year)
  countries <- mrio_panel$metadata$countries
  S <- length(countries)
  N <- length(mrio_panel$metadata$sectors)
  FD_c <- 5
  
  results_list <- vector("list", S)
  
  for (s in 1:S) {
    sr <- rows_s(s, N)
    total_export_s <- numeric(N)
    
    for (r in setdiff(1:S, s)) {
      rr <- rows_s(r, N)
      A_sr <- mats$A[sr, rr, drop=FALSE]
      X_r <- mats$X[rr]
      Y_sr <- get_Y_sr(mats$Y, s, r, N, FD_c)
      
      EX_sr <- as.numeric(A_sr %*% X_r) + Y_sr
      total_export_s <- total_export_s + EX_sr
    }
    results_list[[s]] <- data.table(
      country_index = s, country = countries[s],
      sector = mrio_panel$metadata$sectors,
      total_exports_eq5 = total_export_s
    )
  }
  return(rbindlist(results_list))
}