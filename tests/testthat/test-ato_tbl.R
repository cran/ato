test_that("new_ato_tbl attaches provenance", {
  df <- data.frame(a = 1:3)
  x <- ato:::new_ato_tbl(df, source = "https://data.gov.au",
                          licence = "CC BY 2.5 AU",
                          title = "Test")
  expect_s3_class(x, "ato_tbl")
  expect_s3_class(x, "data.frame")
  expect_equal(attr(x, "ato_title"), "Test")
})

test_that("new_ato_tbl requires a data frame", {
  expect_error(ato:::new_ato_tbl(list(a = 1)))
})

test_that("print.ato_tbl emits header", {
  df <- data.frame(a = 1)
  x <- ato:::new_ato_tbl(df, title = "Demo",
                          source = "https://example.org",
                          retrieved = as.POSIXct("2026-01-01 00:00:00", tz = "UTC"))
  out <- capture.output(print(x))
  expect_true(any(grepl("ato_tbl: Demo", out, fixed = TRUE)))
  expect_true(any(grepl("example.org", out, fixed = TRUE)))
})

test_that("print.ato_tbl returns x invisibly", {
  df <- data.frame(a = 1)
  x <- ato:::new_ato_tbl(df)
  tf <- tempfile()
  sink(tf)
  wv <- withVisible(print(x))
  sink()
  unlink(tf)
  expect_false(wv$visible)
  expect_identical(wv$value, x)
})
