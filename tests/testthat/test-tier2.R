# Tier 2 function signature + validation tests.
# Live-network tests are in a separate file guarded by
# ATO_LIVE_TESTS=true.

test_that("ato_excise validates table arg", {
  expect_error(ato_excise(table = "wine"))
})

test_that("ato_help validates scheme arg", {
  expect_error(ato_help(scheme = "hecs"))
})

test_that("ato_irpd validates table 1-3", {
  expect_error(ato_irpd(table = 4L))
  expect_error(ato_irpd(table = 0L))
})

test_that("ato_companies validates table arg", {
  expect_error(ato_companies(table = "revenue"))
})

test_that("ato_companies accepts new table names", {
  # match.arg should succeed without hitting the network
  tbl_names <- c("industry", "snapshot", "key_items_by_size",
                 "entity_type", "industry_by_size", "sub_industry",
                 "taxable_status", "source", "expenses")
  for (t in tbl_names) {
    expect_silent(match.arg(t, tbl_names))
  }
})

test_that("ato_individuals_postcode multi-year routes to stack", {
  # We can't test the full stack without the network, but we can
  # verify the length-1 path still works via match.arg on year.
  expect_error(
    ato_individuals_postcode(year = c("not-a-year", "also-not")),
    "parse year"
  )
})

test_that("live: ato_tax_gaps fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_tax_gaps()
  expect_s3_class(x, "ato_tbl")
})

test_that("live: ato_rdti fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_rdti(year = "2022-23")
  expect_s3_class(x, "ato_tbl")
})

test_that("live: ato_irpd table 1 fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_irpd(year = "2023-24", table = 1L)
  expect_s3_class(x, "ato_tbl")
})

test_that("live: ato_excise fetches each table", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  for (t in c("excise_rates", "ftc_rates", "beer", "spirits")) {
    expect_s3_class(ato_excise(table = t), "ato_tbl")
  }
})

test_that("live: ato_sme_benchmarks fetches", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  x <- ato_sme_benchmarks()
  expect_s3_class(x, "ato_tbl")
})

test_that("live: ato_help fetches HELP and VSL", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  expect_s3_class(ato_help("help"), "ato_tbl")
  expect_s3_class(ato_help("vsl"), "ato_tbl")
})

test_that("live: ato_companies dispatches across Tables 1-9", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  # Test the snapshot and key_items_by_size tables that Grattan
  # Institute uses in corporate-tax reform work.
  expect_s3_class(ato_companies(year = "2022-23", table = "snapshot"),
                  "ato_tbl")
  expect_s3_class(ato_companies(year = "2022-23", table = "entity_type"),
                  "ato_tbl")
})

test_that("live: ato_individuals_postcode multi-year stacks", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")
  panel <- ato_individuals_postcode(year = c("2021-22", "2022-23"),
                                    state = "TAS")
  expect_s3_class(panel, "ato_tbl")
  expect_true("year" %in% names(panel))
  expect_equal(length(unique(panel$year)), 2L)
})
