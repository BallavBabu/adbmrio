# R/decomposition_national.R

#' 5-Part Decomposition of Gross Output
#' 
#' Decomposes Gross Output, Value Added, and Emissions into 5 parts:
#' 1. Domestic Final
#' 2. Domestic Intermediate
#' 3. Export Final (Embodied)
#' 4. Export Intermediate (Embodied)
#' 5. Export GVC (Embodied)
#'
#' @param mrio_panel MRIO data object.
#' @param year Year to analyze.
#' @return A data.table with decomposition results by sector.
#' @import data.table
#' @import Matrix
#' @export
decompose_national_5part <- function(mrio_panel, year) {
  mats <- get_year_objects(mrio_panel, year)
  S <- length(mrio_panel$metadata$countries)
  N <- length(mrio_panel$metadata$sectors)
  FD_c <- 5
  
  L_rr_list <- vector("list", S)
  Y_rr_list <- vector("list", S)
  for(i in 1:S) {
    idx <- rows_s(i, N)
    L_rr_list[[i]] <- mats$L[idx, idx, drop=FALSE]
    Y_rr_list[[i]] <- get_Y_rr(mats$Y, i, N, FD_c)
  }
  
  results <- vector("list", S)
  clip <- function(x) pmax(x, 0) 
  
  for (s in 1:S) {
    sr <- rows_s(s, N)
    L_ss <- L_rr_list[[s]]
    Y_ss <- get_Y_sr(mats$Y, s, s, N, FD_c)
    
    # DOMESTIC
    X_dom_total <- as.numeric(L_ss %*% Y_ss)
    Term1 <- Y_ss
    Term2 <- X_dom_total - Y_ss
    
    # EXPORTS
    Shock_Exp_Total <- numeric(N)
    Shock_Exp_Final <- numeric(N)
    Shock_Exp_Inter <- numeric(N)
    
    for (r in setdiff(1:S, s)) {
      rr <- rows_s(r, N)
      A_sr <- mats$A[sr, rr, drop=FALSE]
      X_r  <- mats$X[rr]
      Y_sr <- get_Y_sr(mats$Y, s, r, N, FD_c)
      
      Shock_Exp_Total <- Shock_Exp_Total + (as.numeric(A_sr %*% X_r) + Y_sr)
      Shock_Exp_Final <- Shock_Exp_Final + Y_sr
      Shock_Exp_Inter <- Shock_Exp_Inter + as.numeric(A_sr %*% (L_rr_list[[r]] %*% Y_rr_list[[r]]))
    }
    
    Shock_Exp_GVC <- Shock_Exp_Total - Shock_Exp_Final - Shock_Exp_Inter
    
    # EMBODIED
    X_Term3 <- as.numeric(L_ss %*% Shock_Exp_Final)
    X_Term4 <- as.numeric(L_ss %*% Shock_Exp_Inter)
    X_Term5 <- as.numeric(L_ss %*% Shock_Exp_GVC)
    
    v <- mats$VA_coeff[sr]; e <- mats$CO2_coeff[sr]
    
    results[[s]] <- data.table(
      year = year, country = mrio_panel$metadata$countries[s], sector = mrio_panel$metadata$sectors,
      X_Dom_Fin = clip(Term1), X_Dom_Int = clip(Term2), X_Exp_Fin = clip(X_Term3), X_Exp_Int = clip(X_Term4), X_Exp_GVC = clip(X_Term5),
      E_Dom_Fin = clip(e*Term1), E_Dom_Int = clip(e*Term2), E_Exp_Fin = clip(e*X_Term3), E_Exp_Int = clip(e*X_Term4), E_Exp_GVC = clip(e*X_Term5),
      VA_Dom_Fin = clip(v*Term1), VA_Dom_Int = clip(v*Term2), VA_Exp_Fin = clip(v*X_Term3), VA_Exp_Int = clip(v*X_Term4), VA_Exp_GVC = clip(v*X_Term5)
    )
  }
  return(rbindlist(results))
}