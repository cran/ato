test_that("ato_snapshot gets and sets the snapshot pin", {
  on.exit(ato_snapshot(NULL), add = TRUE)
  ato_snapshot(NULL)
  expect_null(ato_snapshot())

  d <- ato_snapshot("2026-04-24")
  expect_s3_class(d, "Date")
  expect_equal(format(ato_snapshot(), "%Y-%m-%d"), "2026-04-24")
})

test_that("ato_snapshot accepts Date and POSIXct", {
  on.exit(ato_snapshot(NULL), add = TRUE)
  ato_snapshot(as.Date("2026-01-01"))
  expect_equal(format(ato_snapshot(), "%Y-%m-%d"), "2026-01-01")

  ato_snapshot(as.POSIXct("2026-06-01", tz = "UTC"))
  expect_equal(format(ato_snapshot(), "%Y-%m-%d"), "2026-06-01")
})

test_that("ato_snapshot errors on bad input", {
  on.exit(ato_snapshot(NULL), add = TRUE)
  expect_error(ato_snapshot("not-a-date"), "parse")
})

test_that("ato_snapshot(NULL) clears the pin", {
  ato_snapshot("2026-04-24")
  ato_snapshot(NULL)
  expect_null(ato_snapshot())
})
