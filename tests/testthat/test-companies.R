test_that("ato_companies live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  c <- ato_companies(year = "2022-23")
  expect_s3_class(c, "ato_tbl")
  expect_gt(nrow(c), 10L)
})
