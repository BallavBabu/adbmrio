#' Toy MRIO Model (4 Countries, 3 Sectors)
#'
#' A simplified Multi-Regional Input-Output (MRIO) dataset for testing and learning.
#' This dataset replicates the structure of the full ADB MRIO panel but with reduced dimensions
#' (4 regions x 3 sectors). It includes data for the year 2023.
#'
#' @details
#' The dataset contains 4 regions: China, India, Japan, and ROW (Rest of World).
#' The 3 sectors are: Primary, Manufacturing, and Service.
#' Note: The Final Demand (Y) matrix has been structured with 5 columns per country 
#' (20 columns total) to match the package's internal logic, though the toy data
#' aggregates demand into the first column of each country block.
#'
#' @format A list with the standard \code{adbmrio} structure:
#' \describe{
#'   \item{metadata}{List containing \code{countries} and \code{sectors}.}
#'   \item{years}{List containing the "2023" data object:}
#'   \itemize{
#'     \item \strong{core_matrices}: Z (Intermediate 12x12), Y (Final Demand 12x20), X (Output 12x1).
#'     \item \strong{coefficients}: A (Technical), VA_coeff (Value Added intensities).
#'     \item \strong{multipliers}: B (Global Leontief), L (Domestic Leontief).
#'     \item \strong{emissions}: CO2_coeff (Emission intensities).
#'   }
#' }
#' @usage data(toy_mrio)
"toy_mrio"