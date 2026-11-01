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

test_that("ato_tidy_wide repairs wide-table names and year columns", {
  df <- data.frame(
    a = c("Gross GST payable", "Input tax credits2"),
    b = c("$m", "$m"),
    c = c("134,740", "na"),
    d = c("0800", "2000"),
    stringsAsFactors = FALSE, check.names = FALSE
  )
  names(df) <- c("", "", "2000-01²", "Postcode")
  df$`2000-01²`[2] <- NA
  out <- ato_tidy_wide(df)
  expect_equal(names(out), c("x1", "x2", "2000_01", "postcode"))
  expect_type(out$`2000_01`, "double")
  expect_equal(out$`2000_01`, c(134740, NA))
  # Identifier columns keep their leading zeros
  expect_identical(out$postcode, c("0800", "2000"))
})
