# R/bilateral.R

#' @import data.table
#' @import Matrix
#' @keywords internal
clip_negatives <- function(x) pmax(x, 0)

#' @export
compute_bilateral <- function(mrio_panel, year, exporter, importer) {
  #' Bilateral Trade Decomposition (Sector Level)
  #'
  #' Performs the bilateral trade decomposition from exporter (s) to importer (r)
  #' using the Wang-Wei-Zhu (WWZ) framework, calculating embodied CO2 emissions and value-added.
  #'
  #' @param mrio_panel MRIO data object returned by load_adb_mrio().
  #' @param year Year (character or numeric, e.g., "2020").
  #' @param exporter Exporter country INDEX (1-63, e.g., 8 for PRC).
  #' @param importer Importer country INDEX (1-63, e.g., 43 for USA).
  #' @return A data.table with bilateral decomposition results by sector.
  #' @examples
  #' # result <- compute_bilateral(mrio, year = 2020, exporter = 8, importer = 43)
  
  # 1. Setup and Validation
  s_idx <- as.integer(exporter)
  r_idx <- as.integer(importer)
  
  if (s_idx == r_idx) stop("Exporter and Importer indices must be different (s != r).")
  
  countries <- mrio_panel$metadata$countries
  sectors <- mrio_panel$metadata$sectors
  S <- length(countries)
  N <- length(sectors)
  FD_per_country <- 5
  
  if (s_idx < 1 || s_idx > S || r_idx < 1 || r_idx > S) {
    stop(paste0("Exporter (", s_idx, ") or Importer (", r_idx, ") index out of bounds (1-", S, ")."))
  }
  
  # Get required matrices and vectors for the year
  mats <- get_year_objects(mrio_panel, year)
  Y <- mats$Y; A <- mats$A; B <- mats$B; L <- mats$L; X <- mats$X
  v_coeff <- mats$VA_coeff; e_coeff <- mats$CO2_coeff
  
  # --- Indexing ---
  all_idx <- 1:S
  sr <- rows_s(s_idx, N) # Exporter s space (N rows)
  rr <- rows_r(r_idx, N) # Importer r space (N rows)
  
  # FIX: Use as.numeric() and remove [, 1] to handle vector inputs
  vs <- as.numeric(v_coeff[sr]) 
  es <- as.numeric(e_coeff[sr]) 
  
  # 2. R-Space Caching (Importer-specific terms for TG components)
  
  L_rr <- L[rr, rr, drop = FALSE] # Domestic Leontief for r (N x N)
  Y_rr_vec <- get_Y_rr(Y, r_idx, N, FD_per_country) # N x 1 domestic final demand in r
  
  # TG1 Inner Sum: L_rr * SUM_{t!=r} [ A_rt * B_tr * Y_rr ]
  S_TG1_sum_t <- Matrix(0, nrow = N, ncol = 1, sparse = TRUE)
  
  Y_rr_GN <- Matrix(0, nrow = S * N, ncol = 1, sparse = TRUE)
  Y_rr_GN[rr] <- Y_rr_vec
  
  for (t_idx in setdiff(all_idx, r_idx)) {
    rt <- rows_r(t_idx, N)
    A_rt <- A[rr, rt, drop = FALSE] 
    B_tr <- B[rt, rr, drop = FALSE] 
    
    A_r_t_GN <- Matrix(0, nrow = S * N, ncol = S * N, sparse = TRUE)
    A_r_t_GN[rr, rt] <- A_rt 
    
    term_r_space <- (A_r_t_GN %*% B %*% Y_rr_GN)[rr, 1]
    S_TG1_sum_t <- S_TG1_sum_t + term_r_space
  }
  S_TG1 <- L_rr %*% S_TG1_sum_t 
  
  # TG2 Inner Sum: SUM_{t!=r} [ B_rt * Y_tr ] (N x 1)
  S_TG2 <- Matrix(0, nrow = N, ncol = 1, sparse = TRUE)
  for (t_idx in setdiff(all_idx, r_idx)) {
    rt <- rows_r(t_idx, N)
    B_rt <- B[rr, rt, drop = FALSE] 
    Y_tr_vec <- get_Y_tr(Y, t_idx, r_idx, N, FD_per_country) 
    S_TG2 <- S_TG2 + B_rt %*% Y_tr_vec
  }
  
  # TG3 Inner Sum: SUM_{t} [ B_rt * Y_tu_excl_r ] (N x 1)
  S_TG3 <- Matrix(0, nrow = N, ncol = 1, sparse = TRUE)
  for (t_idx in all_idx) {
    rt <- rows_r(t_idx, N)
    B_rt <- B[rr, rt, drop = FALSE]
    Y_tu_excl_r_vec <- get_Y_tu_excl_r(Y, t_idx, r_idx, N, S, FD_per_country) 
    S_TG3 <- S_TG3 + B_rt %*% Y_tu_excl_r_vec
  }
  
  # 3. Bilateral Decomposition for s -> r
  
  A_sr <- A[sr, rr, drop = FALSE] 
  Y_sr <- get_Y_sr(Y, s_idx, r_idx, N, FD_per_country) 
  X_r <- as.numeric(X[rr]) # FIX: Ensure vector access for Gross Output
  L_ss <- L[sr, sr, drop = FALSE] 
  
  # Decomposition Components 
  Tf <- Y_sr                                          
  Ti <- as.numeric(A_sr %*% (L_rr %*% Y_rr_vec))      
  TG1 <- as.numeric(A_sr %*% S_TG1)                   
  TG2 <- as.numeric(A_sr %*% S_TG2)                   
  TG3 <- as.numeric(A_sr %*% S_TG3)                   
  
  # Total GVC and exports
  Tg <- TG1 + TG2 + TG3
  EX_decomp <- Tf + Ti + Tg                           
  EX_direct <- Y_sr + as.numeric(A_sr %*% X_r)        
  
  # 4. Embodied Emissions and Value-Added
  
  # Embodied in Export Components (Q = Tf, Ti, Tg, EX_decomp, EX_direct)
  # EEX^Q = e_s * (L_ss * Q)
  
  EEX_Tf <- clip_negatives(es * as.numeric(L_ss %*% Tf))
  EEX_Ti <- clip_negatives(es * as.numeric(L_ss %*% Ti))
  EEX_Tg <- clip_negatives(es * as.numeric(L_ss %*% Tg))
  VAX_Tf <- clip_negatives(vs * as.numeric(L_ss %*% Tf))
  VAX_Ti <- clip_negatives(vs * as.numeric(L_ss %*% Ti))
  VAX_Tg <- clip_negatives(vs * as.numeric(L_ss %*% Tg))
  
  EX_decomp_clipped <- clip_negatives(EX_decomp)
  EX_direct_clipped <- clip_negatives(EX_direct)
  
  EEX_decomp <- clip_negatives(es * as.numeric(L_ss %*% EX_decomp_clipped))
  VAX_decomp <- clip_negatives(vs * as.numeric(L_ss %*% EX_decomp_clipped))
  EEX_direct <- clip_negatives(es * as.numeric(L_ss %*% EX_direct_clipped))
  VAX_direct <- clip_negatives(vs * as.numeric(L_ss %*% EX_direct_clipped))
  
  # 5. Final Output Data Table
  result_dt <- data.table(
    year = as.character(year),
    s_index = s_idx, s_country = countries[s_idx],
    r_index = r_idx, r_country = countries[r_idx],
    sector_ix = 1:N, sector = sectors,
    
    # Trade Decomposition
    Tf = clip_negatives(Tf), Ti = clip_negatives(Ti), 
    TG1 = clip_negatives(TG1), TG2 = clip_negatives(TG2), TG3 = clip_negatives(TG3), 
    Tg = clip_negatives(Tg),
    EX_decomp = EX_decomp_clipped, EX_direct = EX_direct_clipped,
    EX_diff = EX_decomp_clipped - EX_direct_clipped,
    
    # Embodied Emissions
    EEX_Tf = EEX_Tf, EEX_Ti = EEX_Ti, EEX_Tg = EEX_Tg,
    EEX_decomp = EEX_decomp, EEX_direct = EEX_direct,
    EEX_diff = EEX_decomp - EEX_direct,
    
    # Embodied Value-Added
    VAX_Tf = VAX_Tf, VAX_Ti = VAX_Ti, VAX_Tg = VAX_Tg,
    VAX_decomp = VAX_decomp, VAX_direct = VAX_direct,
    VAX_diff = VAX_decomp - VAX_direct
  )
  
  return(result_dt)
}