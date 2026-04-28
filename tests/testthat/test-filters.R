# Filter edge cases and ato_find_col tests (all offline)

test_that("ato_find_col returns first matching variant", {
  df <- data.frame(state = "NSW", x = 1)
  expect_equal(ato:::ato_find_col(df, "state"), "state")

  df2 <- data.frame(state_territory = "NSW", x = 1)
  expect_equal(ato:::ato_find_col(df2, "state"), "state_territory")
})

test_that("ato_find_col returns NA and warns when no variant found", {
  df <- data.frame(region = "NSW", x = 1)
  expect_warning(
    result <- ato:::ato_find_col(df, "state"),
    "state"
  )
  expect_true(is.na(result))
})

test_that("ato_find_col returns NA for unknown key", {
  df <- data.frame(a = 1)
  expect_true(is.na(ato:::ato_find_col(df, "nonexistent_key")))
})

test_that("ato_warn_suppression fires when suppression >= 5%", {
  df <- data.frame(income = c(1000, NA, NA, NA, NA, NA))
  expect_warning(
    ato:::ato_warn_suppression(df, context = "test cells"),
    "suppressed"
  )
})

test_that("ato_warn_suppression is silent when suppression < 5%", {
  df <- data.frame(income = c(rep(1000, 99), NA))
  expect_silent(ato:::ato_warn_suppression(df, context = "test cells"))
})

test_that("ato_warn_suppression is silent on empty data frame", {
  df <- data.frame(income = numeric(0))
  expect_silent(ato:::ato_warn_suppression(df, context = "test cells"))
})

test_that("ato_warn_suppression is silent with no numeric columns", {
  df <- data.frame(name = c("a", NA, NA, NA, NA, NA))
  expect_silent(ato:::ato_warn_suppression(df, context = "test cells"))
})

test_that("ATO_COL_VARIANTS has expected keys", {
  keys <- names(ato:::ATO_COL_VARIANTS)
  expect_true("state" %in% keys)
  expect_true("postcode" %in% keys)
  expect_true("sex" %in% keys)
  expect_true("industry" %in% keys)
  expect_true("entity" %in% keys)
  expect_true("occupation" %in% keys)
})

test_that("ATO_PACKAGE_IDS has expected keys", {
  keys <- names(ato:::ATO_PACKAGE_IDS)
  expect_true("tax_gaps" %in% keys)
  expect_true("rdti" %in% keys)
  expect_true("ctt" %in% keys)
  expect_true("sme" %in% keys)
  expect_true("excise" %in% keys)
  expect_true("help" %in% keys)
  expect_true("smsf" %in% keys)
  expect_true("vttc" %in% keys)
})

test_that("ato_stack_years produces year column and stacks rows", {
  # Two functions returning compatible schemas (income col + year added by stack).
  fn_a <- function(year) {
    df <- data.frame(income = c(100, 200))
    ato:::new_ato_tbl(df, source = "https://example.org", title = "t1")
  }
  stacked <- ato:::ato_stack_years(fn_a, c("2021-22", "2022-23"))
  expect_s3_class(stacked, "ato_tbl")
  expect_true("year" %in% names(stacked))
  expect_equal(nrow(stacked), 4L)
  expect_equal(length(unique(stacked$year)), 2L)
})

test_that("live: ato_individuals_occupation multi-year stacks", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  expect_warning(
    panel <- ato_individuals_occupation(
      year       = c("2021-22", "2022-23"),
      occupation = "accountant"
    ),
    "reclassification"
  )
  expect_s3_class(panel, "ato_tbl")
  expect_true("year" %in% names(panel))
  expect_equal(length(unique(panel$year)), 2L)
})

test_that("live: ato_companies multi-year stacks", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  expect_warning(
    panel <- ato_companies(year = c("2021-22", "2022-23")),
    "reclassification"
  )
  expect_s3_class(panel, "ato_tbl")
  expect_true("year" %in% names(panel))
})
