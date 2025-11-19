# R/workflow.R

#' @import data.table
#' @export
calculate_full_year_gvc <- function(mrio_panel, year) {
  #' Full GVC Analysis Wrapper
  #'
  #' Executes the complete analytical workflow for a specific year:
  #' 1. Calculates bilateral WWZ decomposition for all country pairs (63x62).
  #' 2. Aggregates results to national level (Forward/Backward linkages).
  #'
  #' @param mrio_panel MRIO data object returned by load_adb_mrio().
  #' @param year Year to analyze (numeric or character).
  #' @return A list containing three data.tables:
  #'   - bilateral: Detailed sector-level trade flows (Large).
  #'   - national_sector: GVC participation by sector.
  #'   - national_totals: GVC participation aggregated by country.
  
  year_label <- as.character(year)
  S <- length(mrio_panel$metadata$countries)
  
  # 1. Run Bilateral Loop
  message(paste0("🚀 Starting full bilateral decomposition for ", year_label, "..."))
  # We call the internal helper function we created earlier
  bilateral_dt <- run_all_bilateral_pairs(mrio_panel, year_label)
  
  # 2. Run National Aggregation
  message("📊 Computing National Level Aggregates...")
  national_res <- compute_national(mrio_panel, bilateral_dt, year_label)
  
  # 3. Package and Return
  message("✅ Analysis Complete.")
  
  return(list(
    bilateral = bilateral_dt,
    national_sector = national_res$national_sector,
    national_totals = national_res$national_totals
  ))
}