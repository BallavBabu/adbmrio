# R/national.R

#' @import data.table
#' @import Matrix
#' @export
compute_national <- function(mrio_panel, bilateral_dt, year) {
  #' National Output and Emissions Decomposition
  #'
  #' Aggregates bilateral decomposition results to compute national Gross Output (X),
  #' Embodied Emissions (E), and Embodied Value-Added (VA), decomposed by the four
  #' final demand drivers (Domestic, Final Exports, Traditional Intermediates, GVC).
  #'
  #' @param mrio_panel MRIO data object returned by load_adb_mrio().
  #' @param bilateral_dt data.table output from compute_bilateral() for ALL necessary pairs or years.
  #' @param year Year (character or numeric) corresponding to the data used in bilateral_dt.
  #' @return A list containing two data.tables: 'national_sector' (N x S rows) and 'national_totals' (1 x S rows).
  #' @examples
  #' # national_results <- compute_national(mrio, full_bilateral_panel, year = 2020)
  
  # 1. Setup and Validation
  year_label <- as.character(year)
  
  countries <- mrio_panel$metadata$countries
  sectors <- mrio_panel$metadata$sectors
  S <- length(countries)
  N <- length(sectors)
  FD_per_country <- 5
  
  # Get required matrices and vectors for the year
  mats <- get_year_objects(mrio_panel, year_label)
  Y <- mats$Y; L <- mats$L; X <- mats$X
  v_coeff <- mats$VA_coeff; e_coeff <- mats$CO2_coeff
  
  # 2. Aggregate Bilateral Results to Exporter Totals (Sectors x N)
  exporter_totals <- bilateral_dt[year == year_label, .(
    Tf_total = sum(Tf, na.rm = TRUE),
    Ti_total = sum(Ti, na.rm = TRUE),
    Tg_total = sum(Tg, na.rm = TRUE),
    EX_total = sum(EX_direct, na.rm = TRUE) 
  ), by = .(s_index, s_country, sector_ix, sector)]
  
  # 3. National Decomposition Loop (Equations 4, 5, 5a)
  national_sector_list <- vector("list", S)
  national_totals_list <- vector("list", S)
  
  if (N != 35 || S != 63) {
    stop("Dimensions mismatch. Check utils.R and input data.")
  }
  
  for (s in 1:S) {
    sr <- rows_s(s, N)
    L_ss <- L[sr, sr, drop = FALSE]
    Y_ss <- get_Y_rr(Y, s, N, FD_per_country) 
    
    # FIX: Use as.numeric() and remove [, 1] to handle vector inputs
    X_s <- as.numeric(X[sr])
    e_s <- as.numeric(e_coeff[sr])
    v_s <- as.numeric(v_coeff[sr])
    
    # Extract exporter s totals
    s_data <- exporter_totals[s_index == s]
    
    if (nrow(s_data) == N) {
      Tf_s <- s_data$Tf_total
      Ti_s <- s_data$Ti_total
      Tg_s <- s_data$Tg_total
    } else if (nrow(s_data) == 0) {
      Tf_s <- Ti_s <- Tg_s <- rep(0, N)
    } else {
      stop(paste("Incomplete sector data for national calculation for country index", s, "."))
    }
    
    clip_vector <- function(x) pmax(x, 0)
    Tf_s <- clip_vector(Tf_s)
    Ti_s <- clip_vector(Ti_s)
    Tg_s <- clip_vector(Tg_s)
    
    # --- Gross Output Decomposition (X) ---
    X_domestic <- as.numeric(L_ss %*% Y_ss)     
    X_Tf <- as.numeric(L_ss %*% Tf_s)        
    X_Ti <- as.numeric(L_ss %*% Ti_s)        
    X_Tg <- as.numeric(L_ss %*% Tg_s)        
    X_total_calc <- X_domestic + X_Tf + X_Ti + X_Tg 
    
    # --- Emissions Decomposition (E) ---
    E_domestic <- e_s * X_domestic
    E_Tf <- e_s * X_Tf
    E_Ti <- e_s * X_Ti
    E_Tg <- e_s * X_Tg
    E_total_calc <- E_domestic + E_Tf + E_Ti + E_Tg
    E_direct <- e_s * X_s
    
    # --- Value-added Decomposition (VA) ---
    VA_domestic <- v_s * X_domestic
    VA_Tf <- v_s * X_Tf
    VA_Ti <- v_s * X_Ti
    VA_Tg <- v_s * X_Tg
    VA_total_calc <- VA_domestic + VA_Tf + VA_Ti + VA_Tg
    VA_direct <- v_s * X_s
    
    # --- Sector-level results ---
    national_sector_list[[s]] <- data.table(
      year = as.integer(year_label),
      s_index = s, s_country = countries[s],
      sector_ix = 1:N, sector = sectors,
      
      Tf_total = Tf_s, Ti_total = Ti_s, Tg_total = Tg_s,
      EX_total = Tf_s + Ti_s + Tg_s,
      
      X_domestic = X_domestic, X_Tf = X_Tf, X_Ti = X_Ti, X_Tg = X_Tg,
      X_total_calc = X_total_calc, X_direct = X_s,
      
      E_domestic = E_domestic, E_Tf = E_Tf, E_Ti = E_Ti, E_Tg = E_Tg,
      E_total_calc = E_total_calc, E_direct = E_direct,
      
      VA_domestic = VA_domestic, VA_Tf = VA_Tf, VA_Ti = VA_Ti, VA_Tg = VA_Tg,
      VA_total_calc = VA_total_calc, VA_direct = VA_direct
    )
    
    # --- Country-level totals ---
    national_totals_list[[s]] <- data.table(
      year = as.integer(year_label),
      s_index = s, s_country = countries[s],
      
      X_domestic = sum(X_domestic), X_export = sum(X_Tf + X_Ti + X_Tg),
      X_total_calc = sum(X_total_calc), X_direct = sum(X_s),
      
      E_domestic = sum(E_domestic), E_export = sum(E_Tf + E_Ti + E_Tg),
      E_total_calc = sum(E_total_calc), E_direct = sum(E_direct),
      
      VA_domestic = sum(VA_domestic), VA_export = sum(VA_Tf + VA_Ti + VA_Tg),
      VA_total_calc = sum(VA_total_calc), VA_direct = sum(VA_direct)
    )
  }
  
  national_sector <- rbindlist(national_sector_list, use.names = TRUE, fill = TRUE)
  national_totals <- rbindlist(national_totals_list, use.names = TRUE, fill = TRUE)
  
  national_sector[, c("X_diff", "E_diff", "VA_diff") := list(
    X_direct - X_total_calc,
    E_direct - E_total_calc,
    VA_direct - VA_total_calc
  )]
  
  national_totals[, c("X_diff", "E_diff", "VA_diff") := list(
    X_direct - X_total_calc,
    E_direct - E_total_calc,
    VA_direct - VA_total_calc
  )]
  
  return(list(national_sector = national_sector, national_totals = national_totals))
}