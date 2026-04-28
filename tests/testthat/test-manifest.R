test_that("ato_manifest_clear empties the manifest", {
  ato_manifest_clear()
  df <- ato_manifest("df")
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 0L)
})

test_that("ato_manifest df has expected columns", {
  ato_manifest_clear()
  df <- ato_manifest("df")
  expect_true(all(c("url", "title", "resource_id", "package_id",
                    "licence", "sha256", "size_bytes", "retrieved",
                    "snapshot_date", "r_version", "ato_version") %in%
                    names(df)))
})

test_that("ato_manifest json output is valid JSON", {
  ato_manifest_clear()
  j <- ato_manifest("json")
  expect_type(j, "character")
  expect_silent(jsonlite::fromJSON(j))
})

test_that("ato_manifest_write writes to disk", {
  ato_manifest_clear()
  p <- tempfile(fileext = ".csv")
  ato_manifest_write(p)
  expect_true(file.exists(p))
  df <- utils::read.csv(p)
  expect_s3_class(df, "data.frame")
})

test_that("manifest records a fetch when .ato_manifest_append is called", {
  ato_manifest_clear()
  f <- tempfile()
  writeLines("test", f)
  ato_ns <- asNamespace("ato")
  ato_ns$.ato_manifest_append(
    url = "https://example.com/x.csv",
    file = f,
    title = "test dataset"
  )
  df <- ato_manifest("df")
  expect_equal(nrow(df), 1L)
  expect_equal(df$title, "test dataset")
  expect_true(nzchar(df$sha256))
})
