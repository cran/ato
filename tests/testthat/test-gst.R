test_that("ato_gst validates table choice", {
  expect_error(ato_gst(table = "junk"))
})

test_that("ato_industry validates entity arg", {
  expect_error(ato_industry(entity = "trust"))
})

test_that("ato_gst live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  g <- ato_gst(year = "2022-23", table = "industry")
  expect_s3_class(g, "ato_tbl")
})
