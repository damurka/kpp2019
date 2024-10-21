test_that("Check the data dimensions", {

  expect_equal(NCOL(pop1), 5)
  expect_equal(NROW(pop1), 41424)

  expect_equal(NCOL(pop5), 5)
  expect_equal(NROW(pop5), 15552)

  expect_equal(NCOL(components), 4)
  expect_equal(NROW(components), 1920)

})
