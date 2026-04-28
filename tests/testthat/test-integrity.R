test_that("ato_sha256 returns a hex string for a real file", {
  f <- tempfile()
  writeLines("hello, world", f)
  sha <- ato_sha256(f)
  expect_type(sha, "character")
  expect_true(nzchar(sha))
})

test_that("ato_sha256 returns NA for missing file", {
  expect_true(is.na(ato_sha256(tempfile())))
})

test_that("sha write/read roundtrip via internal helpers", {
  f <- tempfile()
  writeLines("abc", f)
  ato_ns <- asNamespace("ato")
  ato_ns$ato_sha_write(f)
  expect_true(file.exists(ato_ns$ato_sha_sidecar(f)))
  sha_read <- ato_ns$ato_sha_read(f)
  sha_direct <- ato_sha256(f)
  expect_equal(sha_read, sha_direct)
})

test_that("ato_sha_verify fires a warning on mismatch", {
  f <- tempfile()
  writeLines("original", f)
  ato_ns <- asNamespace("ato")
  ato_ns$ato_sha_write(f)
  writeLines("changed", f)
  expect_warning(ato_ns$ato_sha_verify(f), "SHA-256 mismatch")
})

# Level 2: known-value test against a published SHA-256 vector.
# SHA-256 of the empty string is defined in NIST FIPS 180-4 as
# e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855.
test_that("ato_sha256 matches NIST FIPS 180-4 empty-string vector", {
  skip_if_not_installed("digest")
  f <- tempfile()
  file.create(f)
  expect_equal(
    ato_sha256(f),
    "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
  )
})

# Level 4: cross-implementation against the openssl package.
test_that("ato_sha256 agrees with openssl::sha256", {
  skip_if_not_installed("openssl")
  skip_if_not_installed("digest")
  f <- tempfile()
  writeLines("reproducibility audit", f)
  ours   <- ato_sha256(f)
  theirs <- paste(as.character(openssl::sha256(file(f))), collapse = "")
  expect_equal(tolower(ours), tolower(theirs))
})
