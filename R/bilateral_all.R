# R/bilateral_all.R

#' @import data.table
#' @keywords internal
run_all_bilateral_pairs <- function(mrio_panel, year) {
  #' Runs compute_bilateral for all s -> r pairs (s != r) in a given year.
  #'
  #' @param mrio_panel MRIO data object.
  #' @param year Year (character or numeric).
  #' @return A single data.table containing the full bilateral decomposition panel for the year.
  
  S <- length(mrio_panel$metadata$countries)
  all_idx <- 1:S
  year_label <- as.character(year)
  
  cat(paste0("Starting full bilateral decomposition for year ", year_label, " (", S * (S - 1), " pairs)...\n"))
  
  bilateral_list <- vector("list", S * (S - 1))
  idx <- 0L
  
  for (s_idx in all_idx) {
    # Skip processing if exporter s is the same as the importer r
    for (r_idx in setdiff(all_idx, s_idx)) {
      
      # Use the core decomposition function
      tryCatch({
        result <- compute_bilateral(mrio_panel, year_label, s_idx, r_idx)
        idx <- idx + 1L
        bilateral_list[[idx]] <- result
      }, error = function(e) {
        warning(paste0("Error computing s=", s_idx, " -> r=", r_idx, " for year ", year_label, ": ", e$message))
      })
    }
  }
  
  # Combine results and remove empty slots if any pairs failed
  full_dt <- rbindlist(bilateral_list[!sapply(bilateral_list, is.null)], use.names = TRUE, fill = TRUE)
  
  cat(paste0("Full bilateral decomposition completed. Result has ", nrow(full_dt), " rows.\n"))
  return(full_dt)
}