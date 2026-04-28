test_that("ato_digest_url is deterministic and returns MD5 hex", {
  a <- ato:::ato_digest_url("https://data.gov.au/a")
  b <- ato:::ato_digest_url("https://data.gov.au/a")
  d <- ato:::ato_digest_url("https://data.gov.au/b")
  expect_equal(a, b)
  expect_false(identical(a, d))
  expect_match(a, "^[0-9a-f]{32}$")
})

test_that("ato_user_agent includes package version", {
  ua <- ato:::ato_user_agent()
  expect_match(ua, "^ato R package/")
})

test_that("ato_request returns a httr2_request", {
  req <- ato:::ato_request("https://data.gov.au")
  expect_s3_class(req, "httr2_request")
})

test_that("ato_download_cached reuses existing cached file", {
  tmp <- tempfile("ato_cache_")
  op <- options(ato.cache_dir = tmp)
  on.exit(options(op), add = TRUE)
  dir.create(tmp, recursive = TRUE)
  url <- "https://data.gov.au/some.csv"
  hash <- ato:::ato_digest_url(url)
  fake <- file.path(tmp, paste0(hash, ".csv"))
  writeLines("a,b\n1,2", fake)
  got <- ato:::ato_download_cached(url)
  expect_equal(normalizePath(got), normalizePath(fake))
})
