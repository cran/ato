test_that("ato_cite handles ato_tbl input in all styles", {
  x <- data.frame(a = 1)
  x <- structure(x,
    ato_source = "https://data.gov.au/data/dataset/example.xlsx",
    ato_licence = "CC BY 2.5 AU",
    ato_retrieved = as.POSIXct("2026-04-23 00:00:00", tz = "UTC"),
    ato_title = "ATO individuals 2022-23",
    class = c("ato_tbl", "data.frame"))

  txt <- ato_cite(x, "text")
  expect_match(txt, "Australian Taxation Office")
  expect_match(txt, "2026-04-23")
  expect_match(txt, "CC BY 2.5 AU")

  bib <- ato_cite(x, "bibtex")
  expect_match(bib, "^@misc\\{ato_")
  expect_match(bib, "Australian Taxation Office")

  apa <- ato_cite(x, "apa")
  expect_match(apa, "^Australian Taxation Office\\. \\(2026\\)")
})

test_that("ato_cite accepts a plain URL", {
  txt <- ato_cite("https://data.gov.au/data/foo.xlsx")
  expect_match(txt, "Australian Taxation Office")
  expect_match(txt, "foo.xlsx")
})

test_that("ato_cite rejects other inputs", {
  expect_error(ato_cite(123))
  expect_error(ato_cite(list()))
})
