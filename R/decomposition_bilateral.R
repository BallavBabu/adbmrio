# R/decomposition_bilateral.R

#' Detailed Bilateral WWZ Decomposition (Micro Analysis)
#'
#' Decomposes the \strong{Domestic Value Added (DVA)} content of bilateral exports
#' from a source country ($s$) to a reporting country ($r$) using the Wang-Wei-Zhu (WWZ) framework.
#'
#' @details
#' Unlike standard gross export data, this function isolates the value originating strictly
#' from the source country. It calculates:
#' \itemize{
#'   \item \strong{DVA_Fin}: DVA embodied in Final Goods exports ($T_f$).
#'   \item \strong{DVA_Int}: DVA embodied in Intermediate exports absorbed by the importer ($T_i$).
#'   \item \strong{DVA_GVC1}: DVA embodied in re-exported intermediates (GVC trade) ($T_{g1}$).
#' }
#'
#' @param mrio_panel The list object loaded via \code{\link{load_adb_mrio}}.
#' @param year Integer. Year to analyze.
#' @param s_idx Exporter identifier. Can be a numeric index (e.g., \code{8}) or character code (e.g., \code{"PRC"}).
#' @param r_idx Importer identifier. Can be a numeric index (e.g., \code{43}) or character code (e.g., \code{"USA"}).
#'
#' @return A \code{data.table} containing sector-level DVA terms for the specified pair.
#' @import data.table
#' @import Matrix
#' @export
compute_bilateral_wwz <- function(mrio_panel, year, s_idx, r_idx) {
  
  s_idx <- resolve_country(mrio_panel, s_idx)
  r_idx <- resolve_country(mrio_panel, r_idx)
  
  mats <- get_year_objects(mrio_panel, year)
  N <- length(mrio_panel$metadata$sectors)
  S <- length(mrio_panel$metadata$countries)
  FD_c <- 5
  
  sr <- rows_s(s_idx, N); rr <- rows_s(r_idx, N)
  
  A_sr <- mats$A[sr, rr, drop=FALSE]
  L_ss <- mats$L[sr, sr, drop=FALSE]
  L_rr <- mats$L[rr, rr, drop=FALSE]
  Y_sr <- get_Y_sr(mats$Y, s_idx, r_idx, N, FD_c)
  Y_rr <- get_Y_rr(mats$Y, r_idx, N, FD_c)
  
  T_f <- Y_sr
  T_i <- as.numeric(A_sr %*% (L_rr %*% Y_rr))
  
  S_TG1_sum <- numeric(N)
  for(t in setdiff(1:S, r_idx)) {
    rt <- rows_s(t, N)
    B_tr <- mats$B[rt, rr, drop=FALSE]
    A_rt <- mats$A[rr, rt, drop=FALSE]
    if(length(B_tr@x) > 0 && length(A_rt@x) > 0) {
      S_TG1_sum <- S_TG1_sum + as.numeric(A_rt %*% (B_tr %*% Y_rr))
    }
  }
  T_g1 <- as.numeric(A_sr %*% (L_rr %*% S_TG1_sum))
  
  v_s <- mats$VA_coeff[sr]
  data.table(
    s_index = s_idx, s_country = mrio_panel$metadata$countries[s_idx],
    r_index = r_idx, r_country = mrio_panel$metadata$countries[r_idx],
    sector = mrio_panel$metadata$sectors,
    DVA_Fin = v_s * as.numeric(L_ss %*% T_f),
    DVA_Int = v_s * as.numeric(L_ss %*% T_i),
    DVA_GVC1 = v_s * as.numeric(L_ss %*% T_g1)
  )
}