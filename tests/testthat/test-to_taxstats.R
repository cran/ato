test_that("ato_to_taxstats renames known columns", {
  df <- data.frame(taxable_income = 80000,
                   medicare_levy = 1600,
                   postcode = "2000")
  out <- ato_to_taxstats(df)
  expect_true("Taxable_Income" %in% names(out))
  expect_true("Medicare_levy" %in% names(out))
  expect_true("Postcode" %in% names(out))
})

test_that("ato_to_taxstats leaves unknown columns alone", {
  df <- data.frame(foo = 1, bar = 2)
  out <- ato_to_taxstats(df)
  expect_equal(names(out), c("foo", "bar"))
})

test_that("ato_to_taxstats direction from_taxstats inverts", {
  df <- data.frame(Taxable_Income = 80000, Postcode = "2000")
  out <- ato_to_taxstats(df, direction = "from_taxstats")
  expect_true("taxable_income" %in% names(out))
  expect_true("postcode" %in% names(out))
})

test_that("ato_schema_map returns a data frame with 2 columns", {
  map <- ato_schema_map()
  expect_s3_class(map, "data.frame")
  expect_equal(ncol(map), 2L)
  expect_gt(nrow(map), 10L)
})

# Level 3 invariant: bijective columns roundtrip cleanly.
# Only test columns where the aggregate -> microdata -> aggregate
# map recovers the original name (multi-to-one maps won't invert).
test_that("ato_to_taxstats roundtrip preserves one-to-one columns", {
  bijective <- c("taxable_income", "postcode", "rental_income",
                 "medicare_levy", "salary_wages", "sex")
  df <- as.data.frame(
    stats::setNames(
      replicate(length(bijective), 1, simplify = FALSE),
      bijective
    ),
    stringsAsFactors = FALSE
  )
  forward <- ato_to_taxstats(df, direction = "to_taxstats")
  back    <- ato_to_taxstats(forward, direction = "from_taxstats")
  expect_true(all(bijective %in% names(back)))
})

