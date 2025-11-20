#' Toy MRIO Model (4 Countries, 3 Sectors)
#'
#' A simplified Multi-Regional Input-Output (MRIO) dataset for testing and learning.
#' This dataset replicates the structure of the full ADB MRIO panel but with reduced dimensions
#' (4 regions x 3 sectors). It includes data for the year 2023.
#'
#' @format A list with the standard \code{adbmrio} structure:
#' \describe{
#'   \item{metadata}{Contains 4 countries ("China", "India", "Japan", "ROW") and 3 sectors ("Primary", "Manufacturing", "Service").}
#'   \item{years}{List containing the 2023 data objects:}
#'   \itemize{
#'     \item \strong{core_matrices}: Z (Intermediate), Y (Final Demand), X (Output).
#'     \item \strong{coefficients}: A (Technical), VA_coeff (Value Added).
#'     \item \strong{multipliers}: B (Leontief), L (Domestic Leontief).
#'     \item \strong{emissions}: CO2_coeff (Emission intensities).
#'   }
#' }
#' @usage data(toy_mrio)
"toy_mrio"