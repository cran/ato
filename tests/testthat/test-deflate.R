test_that("ato_deflate returns base-year values unchanged", {
  out <- ato_deflate(100, year = "2022-23", base = "2022-23")
  expect_equal(out, 100)
})

test_that("ato_deflate scales older values up", {
  # 2012-13 CPI = 101.7, 2022-23 CPI = 132.9
  # 100 in 2012-13 AUD should be about 130.7 in 2022-23 AUD
  out <- ato_deflate(100, year = "2012-13", base = "2022-23")
  expect_gt(out, 125)
  expect_lt(out, 135)
})

test_that("ato_deflate handles vector input", {
  out <- ato_deflate(c(100, 100, 100),
                     year = c("2012-13", "2017-18", "2022-23"),
                     base = "2022-23")
  expect_length(out, 3L)
  expect_equal(out[3], 100)
  expect_gt(out[1], out[2])
  expect_gt(out[2], out[3])
})

test_that("ato_deflate warns on missing CPI year", {
  expect_warning(
    ato_deflate(100, year = "1850-51", base = "2022-23"),
    "CPI missing"
  )
})

test_that("ato_per_capita divides by ERP correctly", {
  # AUD 316.4 billion / ~27 million = around AUD 12,000 per person
  out <- ato_per_capita(316.4e9, "2022-23")
  expect_gt(out, 10000)
  expect_lt(out, 15000)
})

test_that("ato_per_capita vector input", {
  out <- ato_per_capita(c(100e9, 200e9),
                        year = c("2020-21", "2022-23"))
  expect_length(out, 2L)
})
