test_that("ato_harmonise renames canonical columns", {
  df <- data.frame(
    post_code = c("2000", "3000"),
    state_territory = c("NSW", "VIC"),
    gender = c("M", "F"),
    stringsAsFactors = FALSE
  )
  out <- ato_harmonise(df)
  expect_true(all(c("postcode", "state", "sex") %in% names(out)))
  expect_false(any(c("post_code", "state_territory", "gender") %in% names(out)))
})

test_that("ato_harmonise leaves unknown columns alone", {
  df <- data.frame(foo = 1, bar = 2, postcode = "2000")
  out <- ato_harmonise(df)
  expect_true(all(c("foo", "bar", "postcode") %in% names(out)))
})

test_that("ato_harmonise warns on collision", {
  df <- data.frame(postcode = "2000", post_code = "3000")
  expect_warning(ato_harmonise(df), "map to")
})

# Level 3 invariant: harmonise is idempotent.
test_that("ato_harmonise is idempotent", {
  df <- data.frame(
    post_code = c("2000", "3000"),
    state_territory = c("NSW", "VIC"),
    gender = c("M", "F"),
    foo = c(1, 2),
    stringsAsFactors = FALSE
  )
  once  <- ato_harmonise(df)
  twice <- ato_harmonise(once)
  expect_identical(once, twice)
})
