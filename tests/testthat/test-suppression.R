test_that("ATO_SUPPRESSION_TOKENS covers the main ATO suppression markers", {
  expect_true("np" %in% ato:::ATO_SUPPRESSION_TOKENS)
  expect_true("n.p." %in% ato:::ATO_SUPPRESSION_TOKENS)
  expect_true("*" %in% ato:::ATO_SUPPRESSION_TOKENS)
  expect_true("-" %in% ato:::ATO_SUPPRESSION_TOKENS)
  expect_true("" %in% ato:::ATO_SUPPRESSION_TOKENS)
})

test_that("ato_fetch_csv coerces np to NA, keeping numeric columns numeric", {
  tmp <- tempfile(fileext = ".csv")
  on.exit(unlink(tmp), add = TRUE)
  writeLines(c("Postcode,Tax Payable",
               "2000,1234567",
               "2001,np",
               "2002,890123"), tmp)

  # Fake the cache to point at our tempfile so ato_fetch_csv
  # returns without hitting the network.
  url <- "https://example.com/test.csv"
  cache_dir <- tempfile("ato_cache_")
  dir.create(cache_dir, recursive = TRUE)
  op <- options(ato.cache_dir = cache_dir)
  on.exit(options(op), add = TRUE)
  hash <- ato:::ato_digest_url(url)
  file.copy(tmp, file.path(cache_dir, paste0(hash, ".csv")))

  df <- ato:::ato_fetch_csv(url)
  expect_true(is.numeric(df$tax_payable))
  expect_equal(sum(!is.na(df$tax_payable)), 2L)
  expect_equal(sum(df$tax_payable, na.rm = TRUE), 2124690)
})
