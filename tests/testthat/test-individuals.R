test_that("ato_individuals_occupation validates sex", {
  expect_error(ato_individuals_occupation(sex = "x"))
})

test_that("ato_individuals_occupation accepts long and short sex forms", {
  # match.arg succeeds without hitting the network; we only
  # check the arg validation, not the fetch.
  expect_silent(match.arg("male", c("all", "male", "female", "m", "f")))
  expect_silent(match.arg("f",    c("all", "male", "female", "m", "f")))
})

test_that("ato_individuals_postcode live fetch", {
  skip_on_cran()
  skip_if_offline()
  skip_if(Sys.getenv("ATO_LIVE_TESTS") != "true",
          "Live network tests disabled by default.")

  p <- ato_individuals_postcode(year = "2022-23", state = "NSW")
  expect_s3_class(p, "ato_tbl")
})
