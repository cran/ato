test_that("ato_crosswalk returns a data frame for each type", {
  for (nm in c("anzsic", "anzsco", "postcode", "cpi", "erp", "budget")) {
    cw <- ato_crosswalk(nm)
    expect_s3_class(cw, "data.frame")
    expect_gt(nrow(cw), 0L)
  }
})

test_that("anzsic crosswalk has 19 divisions", {
  cw <- ato_crosswalk("anzsic")
  expect_equal(nrow(cw), 19L)
  expect_true(all(c("anzsic_2006_code", "anzsic_2020_code") %in% names(cw)))
})

test_that("cpi crosswalk has expected structure", {
  cw <- ato_crosswalk("cpi")
  expect_true(all(c("financial_year", "cpi_all_groups_australia") %in%
                  names(cw)))
  expect_true("2022-23" %in% cw$financial_year)
})

test_that("erp crosswalk values are reasonable", {
  cw <- ato_crosswalk("erp")
  erp_2022 <- cw$erp_june_australia_thousands[cw$financial_year == "2022-23"]
  # Australia's population around 26 million
  expect_gt(erp_2022, 25000)
  expect_lt(erp_2022, 28000)
})
