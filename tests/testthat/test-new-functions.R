# Tier 4 new functions : live tests only

test_that("live: ato_fbt fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_fbt()
  expect_s3_class(x, "ato_tbl")
  expect_gt(nrow(x), 0L)
})

test_that("live: ato_payg fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_payg()
  expect_s3_class(x, "ato_tbl")
  expect_gt(nrow(x), 0L)
})

test_that("live: ato_charities fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_charities()
  expect_s3_class(x, "ato_tbl")
  expect_gt(nrow(x), 0L)
})

test_that("live: ato_vttc fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_vttc()
  expect_s3_class(x, "ato_tbl")
  expect_gt(nrow(x), 0L)
})
