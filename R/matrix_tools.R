# R/matrix_tools.R

#' @import Matrix
#' @export
get_sector_to_sector_matrix <- function(mrio_panel, year, exporter, importer) {
  #' Extract Sector-to-Sector Trade Matrix (Input-Output)
  #'
  #' Returns the N x N matrix of intermediate flows (Z) from the Exporter's sectors
  #' to the Importer's sectors.
  #'
  #' @param mrio_panel MRIO data object returned by load_adb_mrio().
  #' @param year Year to analyze (numeric or character).
  #' @param exporter Exporter country INDEX (1-63).
  #' @param importer Importer country INDEX (1-63).
  #' @return A 35x35 matrix (standard R matrix) with sector names.
  
  # 1. Validation
  year_label <- as.character(year)
  s_idx <- as.integer(exporter)
  r_idx <- as.integer(importer)
  
  if (is.null(mrio_panel$years[[year_label]])) {
    stop(paste("Year", year_label, "not found in MRIO panel."))
  }
  
  S <- length(mrio_panel$metadata$countries)
  N <- length(mrio_panel$metadata$sectors)
  
  if (s_idx < 1 || s_idx > S || r_idx < 1 || r_idx > S) {
    stop("Country index out of bounds.")
  }
  
  # 2. Get the Master Z Matrix
  Z_sparse <- mrio_panel$years[[year_label]]$core_matrices$Z
  
  # 3. Calculate Indices
  # Exporter Rows
  row_start <- (s_idx - 1) * N + 1
  row_end   <- s_idx * N
  
  # Importer Columns
  col_start <- (r_idx - 1) * N + 1
  col_end   <- r_idx * N
  
  # 4. Slice and Convert
  # We convert to a dense matrix because 35x35 is small and easier for users to read/save
  sector_block <- as.matrix(Z_sparse[row_start:row_end, col_start:col_end])
  
  # 5. Add Names
  sectors <- mrio_panel$metadata$sectors
  s_name <- mrio_panel$metadata$countries[s_idx]
  r_name <- mrio_panel$metadata$countries[r_idx]
  
  rownames(sector_block) <- paste0(s_name, "_", sectors) # e.g., PRC_Agriculture
  colnames(sector_block) <- paste0(r_name, "_", sectors) # e.g., USA_Agriculture
  
  return(sector_block)
}