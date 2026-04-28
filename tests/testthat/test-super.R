test_that("ato_super_funds validates type arg", {
  expect_error(ato_super_funds(type = "corporate"))
})

test_that("ato_super_funds live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  s <- ato_super_funds(year = "2022-23", type = "apra")
  expect_s3_class(s, "ato_tbl")
})
