# R/utils.R

#' @import Matrix
#' @keywords internal
rows_s <- function(s_idx, N) ((s_idx - 1L) * N + 1L):(s_idx * N)

#' @keywords internal
rows_r <- function(r_idx, N) rows_s(r_idx, N) 

#' @keywords internal
ycols_r <- function(r_idx, FD_per_country) {
  ((r_idx - 1L) * FD_per_country + 1L):(r_idx * FD_per_country)
}

#' @keywords internal
get_Y_sr <- function(Y, s_idx, r_idx, N, FD_per_country) {
  rs <- rows_s(s_idx, N)
  cr <- ycols_r(r_idx, FD_per_country)
  as.numeric(Matrix::rowSums(Y[rs, cr, drop = FALSE]))
}

#' @keywords internal
get_Y_rr <- function(Y, r_idx, N, FD_per_country) {
  rr <- rows_r(r_idx, N)
  cr <- ycols_r(r_idx, FD_per_country)
  as.numeric(Matrix::rowSums(Y[rr, cr, drop = FALSE]))
}

#' @import Matrix
#' @keywords internal
get_year_objects <- function(mrio_panel, year_label) {
  y <- mrio_panel$years[[as.character(year_label)]]
  if (is.null(y)) stop(paste0("Year '", year_label, "' not found."))
  
  list(
    Z = y$core_matrices$Z,
    X = as.numeric(y$core_matrices$X),
    Y = y$core_matrices$Y,
    A = y$coefficients$A,
    A_D = y$coefficients$A_D,
    B = y$multipliers$B, 
    L = y$multipliers$L, 
    VA_coeff = as.numeric(y$coefficients$VA_coeff),
    CO2_coeff = as.numeric(y$emissions$CO2_coeff)
  )
}

#' @keywords internal
resolve_country <- function(mrio_panel, input) {
  if (is.numeric(input)) {
    idx <- as.integer(input)
    S <- length(mrio_panel$metadata$countries)
    if (idx < 1 || idx > S) stop(paste("Country index", idx, "out of bounds."))
    return(idx)
  } else if (is.character(input)) {
    idx <- which(mrio_panel$metadata$countries == input)
    if (length(idx) == 0) stop(paste("Country code '", input, "' not found."))
    return(idx)
  } else {
    stop("Country identifier must be numeric index or character code.")
  }
}
