# R/data_loading.R

#' Load ADB MRIO Panel Data
#'
#' Loads the pre-processed Asian Development Bank Multi-Regional Input-Output (ADB MRIO)
#' panel data from a local RDS file. It performs a basic structure validation to ensure
#' the file contains the required metadata and yearly matrix objects.
#'
#' @param file_path Character string. The full path to the \code{.rds} file containing
#'        the harmonized ADB MRIO panel.
#'
#' @return A large list containing:
#' \describe{
#'   \item{metadata}{List of \code{countries} (63 economies) and \code{sectors} (35 industries).}
#'   \item{years}{A list of year-specific objects (e.g., "2021"), each containing:}
#'   \itemize{
#'     \item \code{core_matrices}: Sparse matrices for Z (Intermediate), Y (Final Demand), and vectors for X (Output).
#'     \item \code{coefficients}: A (Technical Coefficients), VA_coeff (Value Added intensities).
#'     \item \code{multipliers}: L (Leontief Inverse), B (Global Leontief Inverse).
#'     \item \code{emissions}: CO2_coeff (Emission intensities), if available.
#'   }
#' }
#'
#' @examples
#' \dontrun{
#' mrio <- load_adb_mrio("data/ADB_MRIO_Merged_Panel_2000_2023.rds")
#' print(mrio$metadata$countries)
#' }
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