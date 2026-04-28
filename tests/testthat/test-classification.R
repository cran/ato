# Classification-break warning tests (all offline)

test_that("ato_warn_classification_break fires for year >= 2022", {
  expect_warning(
    ato:::ato_warn_classification_break("2022-23", "anzsco"),
    "ANZSCO 2021"
  )
  expect_warning(
    ato:::ato_warn_classification_break("2023-24", "anzsco"),
    "ANZSCO 2021"
  )
  expect_warning(
    ato:::ato_warn_classification_break("2022-23", "anzsic"),
    "ANZSIC 2020"
  )
})

test_that("ato_warn_classification_break is silent for year < 2022", {
  expect_silent(ato:::ato_warn_classification_break("2021-22", "anzsco"))
  expect_silent(ato:::ato_warn_classification_break("2019-20", "anzsic"))
})

test_that("ato_warn_classification_span fires when years span the break", {
  expect_warning(
    ato:::ato_warn_classification_span(c("2021-22", "2022-23"), "anzsco"),
    "reclassification"
  )
  expect_warning(
    ato:::ato_warn_classification_span(c("2019-20", "2022-23"), "anzsic"),
    "reclassification"
  )
})

test_that("ato_warn_classification_span is silent when years don't span", {
  expect_silent(
    ato:::ato_warn_classification_span(c("2021-22", "2020-21"), "anzsco")
  )
  expect_silent(
    ato:::ato_warn_classification_span(c("2022-23", "2023-24"), "anzsic")
  )
})

test_that("ATO_CLASSIFICATION_BREAK_YEAR is 2022L", {
  expect_equal(ato:::ATO_CLASSIFICATION_BREAK_YEAR, 2022L)
})
