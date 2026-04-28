test_that("ato_top_taxpayers validates entity_type", {
  expect_error(ato_top_taxpayers(entity_type = "other"))
})

test_that("ato_top_taxpayers live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  t <- ato_top_taxpayers(year = "2023-24")
  expect_s3_class(t, "ato_tbl")
  expect_gt(nrow(t), 1000L)
})
