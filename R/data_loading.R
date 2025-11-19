# R/data_loading.R

#' @import data.table
#' @import Matrix
#' @export
load_adb_mrio <- function(file_path) {
  #' Load ADB MRIO Data
  #'
  #' Loads the multi-regional input-output panel data from an RDS file
  #' and performs a basic structure validation.
  #'
  #' @param file_path Path to RDS file containing ADB MRIO data (must include metadata and years structure).
  #' @return List with metadata and yearly matrices (the mrio_panel object).
  #' @examples
  #' # mrio_panel <- load_adb_mrio("path/to/data.rds")
  
  if (!file.exists(file_path)) {
    stop(paste0("File not found: ", file_path))
  }
  
  mrio_panel <- readRDS(file_path)
  
  # Basic Validation of Structure
  if (!("metadata" %in% names(mrio_panel) && "years" %in% names(mrio_panel))) {
    stop("Invalid MRIO data structure: missing 'metadata' or 'years'.")
  }
  if (!("countries" %in% names(mrio_panel$metadata) && "sectors" %in% names(mrio_panel$metadata))) {
    stop("Invalid MRIO metadata: missing 'countries' or 'sectors'.")
  }
  
  # Define key dimensions expected by the decomposition functions
  S <- length(mrio_panel$metadata$countries)
  N <- length(mrio_panel$metadata$sectors)
  GN <- S * N
  FD_per_country <- 5
  num_fd_cols <- S * FD_per_country
  years <- names(mrio_panel$years)
  
  # CRITICAL: Check dimensions match the required 63x35 structure
  if (S != 63 || N != 35) {
    warning(paste0("Expected 63 countries and 35 sectors, found S=", S, " and N=", N, ". Decomposition logic may fail."))
  }
  
  # Validate matrices dimensions for a sample year
  if (length(years) > 0) {
    sample_year_data <- mrio_panel$years[[years[1]]]
    core_mats <- sample_year_data$core_matrices
    coeffs <- sample_year_data$coefficients
    mults <- sample_year_data$multipliers
    emiss <- sample_year_data$emissions
    
    # Check Z, A, B, L dimensions (GN x GN)
    if (any(dim(core_mats$Z) != c(GN, GN))) stop("Z matrix dimension mismatch.")
    if (any(dim(coeffs$A) != c(GN, GN))) stop("A matrix dimension mismatch.")
    
    # FIX APPLIED HERE: Added missing '!='
    if (any(dim(mults$B) != c(GN, GN))) stop("B matrix dimension mismatch.") 
    if (any(dim(mults$L) != c(GN, GN))) stop("L matrix dimension mismatch.") 
    
    # Check Y dimensions (GN x S*FD_per_country)
    if (any(dim(core_mats$Y) != c(GN, num_fd_cols))) stop("Y matrix dimension mismatch.")
    
    # Check vector dimensions (GN x 1)
    if (any(c(length(core_mats$X), length(coeffs$VA_coeff), length(emiss$CO2_coeff)) != GN)) {
      stop("Vector (X, VA_coeff, CO2_coeff) length mismatch.")
    }
  }
  
  # Print summary
  message(paste0("ADB MRIO Panel loaded successfully."))
  message(paste0("  - Countries (S): ", S, " (e.g., ", paste(mrio_panel$metadata$countries[c(8, 22, 43)], collapse=", "), "...)"))
  message(paste0("  - Sectors (N): ", N))
  message(paste0("  - Total Dimensions (GN): ", GN, " x ", GN))
  message(paste0("  - Years: ", paste(years, collapse=", ")))
  
  return(mrio_panel)
}