test_that("ato_cite includes SHA and snapshot in bibtex", {
  df <- data.frame(a = 1)
  x <- structure(df,
    ato_source = "https://data.gov.au/x.csv",
    ato_licence = "CC BY 2.5 AU",
    ato_retrieved = as.POSIXct("2026-04-24 00:00:00", tz = "UTC"),
    ato_title = "ATO test dataset",
    ato_sha256 = "abc123def456789012345678",
    ato_snapshot_date = "2026-04-24",
    class = c("ato_tbl", "data.frame")
  )
  bib <- ato_cite(x, style = "bibtex")
  expect_match(bib, "snapshot 2026-04-24")
  expect_match(bib, "sha256:abc123def456")
})

test_that("ato_cite includes DOI when provided", {
  df <- data.frame(a = 1)
  x <- structure(df,
    ato_source = "https://data.gov.au/x.csv",
    ato_title = "t",
    ato_retrieved = Sys.time(),
    class = c("ato_tbl", "data.frame")
  )
  bib <- ato_cite(x, style = "bibtex", doi = "10.5281/zenodo.1")
  expect_match(bib, "doi    = \\{10\\.5281/zenodo\\.1\\}")

  apa <- ato_cite(x, style = "apa", doi = "10.5281/zenodo.1")
  expect_match(apa, "https://doi.org/10.5281/zenodo.1")
})

test_that("ato_cite text includes snapshot and SHA", {
  df <- data.frame(a = 1)
  x <- structure(df,
    ato_source = "https://x", ato_title = "t",
    ato_retrieved = as.POSIXct("2026-04-24", tz = "UTC"),
    ato_sha256 = "abcdef123456789",
    ato_snapshot_date = "2026-04-24",
    class = c("ato_tbl", "data.frame")
  )
  txt <- ato_cite(x, style = "text")
  expect_match(txt, "Snapshot: 2026-04-24")
  expect_match(txt, "SHA-256")
})
