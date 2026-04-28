test_that("ato_ckan_search hits the network when live tests enabled", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  r <- ato:::ato_ckan_search(rows = 5L)
  expect_type(r, "list")
  expect_gt(length(r$results), 0L)
})

test_that("ato_catalog returns an ato_tbl with expected columns", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  cat <- ato_catalog()
  expect_s3_class(cat, "ato_tbl")
  expect_true(all(c("id", "title", "licence") %in% names(cat)))
  expect_gt(nrow(cat), 20L)
})
