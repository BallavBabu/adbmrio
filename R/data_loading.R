# R/data_loading.R

#' Load ADB MRIO Data
#'
#' Loads the multi-regional input-output panel data from an RDS file
#' and performs a basic structure validation.
#'
#' @param file_path Path to RDS file containing ADB MRIO data.
#' @return List with metadata and yearly matrices.
#' @import data.table
#' @import Matrix
#' @export
load_adb_mrio <- function(file_path) {
  if (!file.exists(file_path)) stop(paste0("File not found: ", file_path))
  
  mrio_panel <- readRDS(file_path)
  
  if (!("metadata" %in% names(mrio_panel) && "years" %in% names(mrio_panel))) {
    stop("Invalid MRIO data structure.")
  }
  
  S <- length(mrio_panel$metadata$countries)
  N <- length(mrio_panel$metadata$sectors)
  years <- names(mrio_panel$years)
  
  message(paste0("ADB MRIO Panel loaded successfully."))
  message(paste0("  - Dimensions: ", S, " Economies x ", N, " Sectors"))
  message(paste0("  - Years: ", head(years, 1), " - ", tail(years, 1)))
  
  return(mrio_panel)
}