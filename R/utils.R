# R/utils.R

#' @keywords internal
rows_s <- function(s_idx, N) {
  ((s_idx - 1L) * N + 1L):(s_idx * N)
}

#' @keywords internal
rows_r <- function(r_idx, N) {
  rows_s(r_idx, N)
}

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

#' @keywords internal
get_Y_tr <- function(Y, t_idx, r_idx, N, FD_per_country) {
  rt <- rows_s(t_idx, N)
  cr <- ycols_r(r_idx, FD_per_country)
  as.numeric(Matrix::rowSums(Y[rt, cr, drop = FALSE]))
}

#' @keywords internal
get_Y_tu_excl_r <- function(Y, t_idx, r_idx, N, S, FD_per_country) {
  rt <- rows_s(t_idx, N)
  u_indices <- setdiff(1:S, r_idx)
  if (length(u_indices) == 0) return(rep(0, N))
  all_cols <- unlist(lapply(u_indices, function(u) ycols_r(u, FD_per_country)))
  as.numeric(Matrix::rowSums(Y[rt, all_cols, drop = FALSE]))
}

#' @keywords internal
get_year_objects <- function(mrio_panel, year_label) {
  yr_label <- as.character(year_label)
  y <- mrio_panel$years[[yr_label]]
  
  if (is.null(y)) stop(paste0("Year '", yr_label, "' not found."))
  
  list(
    Z = y$core_matrices$Z,
    X = y$core_matrices$X,
    Y = y$core_matrices$Y, 
    VA_raw = y$core_matrices$VA_raw,
    A = y$coefficients$A, 
    A_D = y$coefficients$A_D,
    VA_coeff = y$coefficients$VA_coeff,
    B = y$multipliers$B, 
    L = y$multipliers$L,
    CO2_raw = y$emissions$CO2_raw,
    CO2_coeff = y$emissions$CO2_coeff,
    CO2_diag = y$emissions$CO2_diag
  )
}