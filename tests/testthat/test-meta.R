# ato_meta tests

test_that("ato_meta rejects numeric input", {
  expect_error(ato_meta(42))
})

test_that("ato_meta rejects list input", {
  expect_error(ato_meta(list()))
})

test_that("ato_meta rejects ato_tbl with unparseable source URL", {
  df <- data.frame(a = 1)
  x  <- ato:::new_ato_tbl(df, source = "not-a-real-url", title = "t")
  expect_error(ato_meta(x), "package ID")
})

test_that("live: ato_meta returns expected structure from package ID", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  m <- ato_meta("australian-tax-gaps")
  expect_type(m, "list")
  expect_setequal(names(m), c("id", "title", "notes", "licence",
                               "metadata_modified", "n_resources",
                               "resource_urls"))
  expect_equal(m$id, "australian-tax-gaps")
  expect_gt(m$n_resources, 0L)
  expect_true(is.character(m$resource_urls))
})

test_that("live: ato_meta accepts an ato_tbl", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  tbl <- ato_tax_gaps()
  m   <- ato_meta(tbl)
  expect_type(m, "list")
  expect_true(nzchar(m$id))
})
