test_that("National decomposition returns correct dimensions and sums", {
  # 1. Load the internal toy data
  data(toy_mrio)
  
  # 2. Run the 5-part decomposition for 2023
  # We expect 12 rows (4 countries * 3 sectors)
  res <- decompose_national_5part(toy_mrio, 2023)
  
  # CHECK A: Are there 12 rows?
  expect_equal(nrow(res), 12)
  
  # CHECK B: Does the math add up?
  # The sum of the 5 components (Dom_Fin + Dom_Int + Exp_Fin + Exp_Int + Exp_GVC)
  # MUST equal the 'X_Total' column.
  
  # Let's check the first row (China - Primary)
  row1 <- res[1]
  sum_5_parts <- row1$X_Dom_Fin + row1$X_Dom_Int + row1$X_Exp_Fin + row1$X_Exp_Int + row1$X_Exp_GVC
  
  # We use tolerance=1e-5 to allow for tiny computer rounding errors
  expect_equal(sum_5_parts, row1$X_Total, tolerance = 1e-5)
})