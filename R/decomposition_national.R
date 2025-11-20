#' National 5-Part GVC Decomposition (Macro Analysis)
#'
#' Performs a national-level decomposition of Gross Output ($X$), Value Added ($VA$), 
#' and CO2 Emissions ($E$) into 5 components based on the framework by Zhang et al. (2017).
#'
#' @details
#' The function decomposes total output for every country-sector into:
#' \itemize{
#'   \item \strong{Dom_Fin}: Production consumed domestically as final goods.
#'   \item \strong{Dom_Int}: Production consumed domestically as intermediate goods.
#'   \item \strong{Exp_Fin}: Exports consumed immediately by the importer (Final Demand).
#'   \item \strong{Exp_Int}: Intermediate exports absorbed by the direct importer.
#'   \item \strong{Exp_GVC}: Intermediate exports involved in complex GVCs (re-exports).
#' }
#'
#' @param mrio_panel The list object loaded via \code{\link{load_adb_mrio}}.
#' @param year Integer. The specific year to analyze (e.g., 2021).
#'
#' @return A \code{data.table} with the following columns...
#' 
#' @examples
#' \dontrun{
#' # Load the built-in toy dataset
#' data(toy_mrio)
#' 
#' # Perform the decomposition for the year 2023
#' results <- decompose_national_5part(toy_mrio, 2023)
#' 
#' # Inspect results for the "Manufacturing" sector
#' library(data.table)
#' print(results[sector == "Manufacturing"])
#' }
#'
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
    
    X_dom_total <- as.numeric(L_ss %*% Y_ss)
    Term1 <- Y_ss
    Term2 <- X_dom_total - Y_ss
    
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
    
    X_Term3 <- as.numeric(L_ss %*% Shock_Exp_Final)
    X_Term4 <- as.numeric(L_ss %*% Shock_Exp_Inter)
    X_Term5 <- as.numeric(L_ss %*% Shock_Exp_GVC)
    
    v <- mats$VA_coeff[sr]; e <- mats$CO2_coeff[sr]
    
    sum5 <- function(a,b,c,d,e) a+b+c+d+e
    x1=clip(Term1); x2=clip(Term2); x3=clip(X_Term3); x4=clip(X_Term4); x5=clip(X_Term5)
    e1=clip(e*Term1); e2=clip(e*Term2); e3=clip(e*X_Term3); e4=clip(e*X_Term4); e5=clip(e*X_Term5)
    v1=clip(v*Term1); v2=clip(v*Term2); v3=clip(v*X_Term3); v4=clip(v*X_Term4); v5=clip(v*X_Term5)
    
    results[[s]] <- data.table(
      year = year, 
      country_index = s,
      country = mrio_panel$metadata$countries[s], 
      sector = mrio_panel$metadata$sectors,
      
      X_Dom_Fin = x1, X_Dom_Int = x2, X_Exp_Fin = x3, X_Exp_Int = x4, X_Exp_GVC = x5,
      X_Total   = sum5(x1,x2,x3,x4,x5),
      
      E_Dom_Fin = e1, E_Dom_Int = e2, E_Exp_Fin = e3, E_Exp_Int = e4, E_Exp_GVC = e5,
      E_Total   = sum5(e1,e2,e3,e4,e5),
      
      VA_Dom_Fin = v1, VA_Dom_Int = v2, VA_Exp_Fin = v3, VA_Exp_Int = v4, VA_Exp_GVC = v5,
      VA_Total   = sum5(v1,v2,v3,v4,v5)
    )
  }
  return(rbindlist(results))
}