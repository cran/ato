test_that("ato_reconcile returns a 1-row diff frame", {
  res <- ato_reconcile(value = 296.658e9,
                       year = "2022-23",
                       measure = "individuals_income_tax_net")
  expect_s3_class(res, "data.frame")
  expect_equal(nrow(res), 1L)
  expect_true(all(c("measure", "year", "value_aud", "reference_aud",
                    "diff_aud", "pct_diff", "source") %in% names(res)))
  # Exact match -> diff = 0
  expect_equal(res$diff_aud, 0)
  expect_equal(res$pct_diff, 0)
})

test_that("ato_reconcile warns on >5% discrepancy", {
  expect_warning(
    ato_reconcile(value = 400e9, year = "2022-23",
                  measure = "individuals_income_tax_net"),
    "Reconciliation diff"
  )
})

test_that("ato_reconcile errors on unknown measure", {
  expect_error(
    ato_reconcile(value = 1e9, year = "2022-23",
                  measure = "not_a_measure"),
    "reference"
  )
})

test_that("ato_reconcile sums a data frame column", {
  df <- data.frame(tax = c(100e9, 196.658e9))
  res <- ato_reconcile(df, year = "2022-23",
                       measure = "individuals_income_tax_net")
  expect_equal(res$value_aud, 296.658e9)
})

# Level 3 invariant: pct_diff sign matches (value - reference).
test_that("ato_reconcile pct_diff sign is consistent with diff", {
  high <- suppressWarnings(ato_reconcile(400e9, "2022-23",
                                          "individuals_income_tax_net"))
  low  <- suppressWarnings(ato_reconcile(200e9, "2022-23",
                                          "individuals_income_tax_net"))
  expect_gt(high$diff_aud, 0)
  expect_gt(high$pct_diff, 0)
  expect_lt(low$diff_aud, 0)
  expect_lt(low$pct_diff, 0)
})

test_that("budget reference totals are read from the Final Budget Outcome", {
  bud <- ato_crosswalk("budget")
  get <- function(fy, m) bud$value_aud_billion[bud$financial_year == fy & bud$measure == m]
  # FBO 2023-24 Table 1.3, Outcome column
  expect_equal(get("2023-24", "company_tax_net"), 141.177)
  expect_equal(get("2023-24", "individuals_income_tax_net"), 331.513)
  expect_equal(get("2023-24", "gst_net"), 85.031)
  expect_true(all(grepl("^Final Budget Outcome", bud$source)))
  expect_false(anyDuplicated(bud[, c("financial_year", "measure")]) > 0)
})
