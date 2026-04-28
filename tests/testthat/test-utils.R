test_that("ato_clean_names handles punctuation", {
  got <- ato:::ato_clean_names(c("Postcode", "Total Income $",
                                  "Taxable Income (Median)",
                                  "  trailing "))
  expect_equal(got, c("postcode", "total_income",
                      "taxable_income_median", "trailing"))
})

test_that("ato_resolve_year parses canonical forms", {
  expect_equal(ato:::ato_resolve_year("2022-23"), "2022-23")
  expect_equal(ato:::ato_resolve_year("2022/23"), "2022-23")
  expect_equal(ato:::ato_resolve_year("2022-2023"), "2022-23")
  expect_equal(ato:::ato_resolve_year(2022), "2022-23")
  expect_equal(ato:::ato_resolve_year("latest"), "latest")
})

test_that("ato_resolve_year errors on nonsense", {
  expect_error(ato:::ato_resolve_year("not-a-year"))
  expect_error(ato:::ato_resolve_year("20"))
})
