# Error path tests (all offline)

test_that("new_ato_tbl rejects non-data-frame input", {
  expect_error(ato:::new_ato_tbl(list(a = 1)))
  expect_error(ato:::new_ato_tbl(1:3))
})

test_that("ato_irpd rejects table outside 1-3", {
  expect_error(ato_irpd(table = 4L))
  expect_error(ato_irpd(table = 0L))
  expect_error(ato_irpd(table = 5L))
})

test_that("ato_excise rejects unknown table", {
  expect_error(ato_excise(table = "wine"))
  expect_error(ato_excise(table = "gst"))
})

test_that("ato_help rejects unknown scheme", {
  expect_error(ato_help(scheme = "hecs"))
  expect_error(ato_help(scheme = "austudy"))
})

test_that("ato_companies rejects unknown table", {
  expect_error(ato_companies(table = "revenue"))
  expect_error(ato_companies(table = "profit"))
})

test_that("ato_super_funds rejects unknown type", {
  expect_error(ato_super_funds(type = "industry"))
})

test_that("ato_gst rejects unknown table", {
  expect_error(ato_gst(table = "income"))
})

test_that("ato_top_taxpayers rejects unknown entity_type", {
  expect_error(ato_top_taxpayers(entity_type = "partnership"))
})

test_that("ato_top_taxpayers rejects unknown sheet", {
  expect_error(ato_top_taxpayers(sheet = "gst"))
})

test_that("ato_individuals_occupation rejects bad sex argument", {
  expect_error(ato_individuals_occupation(sex = "nonbinary"))
})

test_that("ato_resolve_year errors on nonsense input", {
  expect_error(ato:::ato_resolve_year("not-a-year"))
  expect_error(ato:::ato_resolve_year("20"))
  expect_error(ato:::ato_resolve_year("abc"))
})

test_that("ato_cite rejects non-tbl non-string input", {
  expect_error(ato_cite(123))
  expect_error(ato_cite(list(a = 1)))
})

test_that("ato_meta rejects non-tbl non-string input", {
  expect_error(ato_meta(42))
  expect_error(ato_meta(list()))
})

test_that("ato_download errors on unknown parse value", {
  expect_error(ato_download("any-id", parse = "json"))
})
