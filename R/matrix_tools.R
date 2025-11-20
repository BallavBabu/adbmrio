# R/matrix_tools.R

#' Extract Sector-to-Sector Trade Matrix (Z)
#'
#' Extracts the specific N x N block of the intermediate transaction matrix ($Z$)
#' representing direct flows from the Exporter to the Importer.
#'
#' @param mrio_panel The MRIO data object.
#' @param year Integer. The year to analyze.
#' @param exporter Source country. Numeric Index (e.g., 8) OR Country Code (e.g., "PRC").
#' @param importer Destination country. Numeric Index (e.g., 43) OR Country Code (e.g., "USA").
#'
#' @return A sparse matrix (35 x 35) with row names formatted as \code{"Country_Sector"}.
#' Values represent flows in millions of USD (constant prices).
#'
#' @import Matrix
#' @export
get_sector_to_sector_matrix <- function(mrio_panel, year, exporter, importer) {
  s_idx <- resolve_country(mrio_panel, exporter)
  r_idx <- resolve_country(mrio_panel, importer)
  
  year_label <- as.character(year)
  if (is.null(mrio_panel$years[[year_label]])) stop("Year not found.")
  
  N <- length(mrio_panel$metadata$sectors)
  Z_sparse <- mrio_panel$years[[year_label]]$core_matrices$Z
  
  rs <- (s_idx - 1) * N + 1; re <- s_idx * N
  cs <- (r_idx - 1) * N + 1; ce <- r_idx * N
  
  block <- as.matrix(Z_sparse[rs:re, cs:ce])
  rownames(block) <- paste0(mrio_panel$metadata$countries[s_idx], "_", mrio_panel$metadata$sectors)
  colnames(block) <- paste0(mrio_panel$metadata$countries[r_idx], "_", mrio_panel$metadata$sectors)
  
  return(block)
}