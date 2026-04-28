test_that("ato_cache_dir honours the ato.cache_dir option", {
  tmp <- tempfile("ato_cache_")
  op <- options(ato.cache_dir = tmp)
  on.exit(options(op), add = TRUE)

  d <- ato:::ato_cache_dir()
  expect_equal(normalizePath(d), normalizePath(tmp))
  expect_true(dir.exists(d))
})

test_that("ato_cache_info returns empty structure", {
  tmp <- tempfile("ato_cache_")
  op <- options(ato.cache_dir = tmp)
  on.exit(options(op), add = TRUE)

  info <- ato_cache_info()
  expect_type(info, "list")
  expect_setequal(names(info),
                  c("dir", "n_files", "size_bytes", "size_human", "files"))
  expect_equal(info$n_files, 0L)
})

test_that("ato_cache_info counts files", {
  tmp <- tempfile("ato_cache_")
  op <- options(ato.cache_dir = tmp)
  on.exit(options(op), add = TRUE)
  dir.create(tmp, recursive = TRUE)
  writeLines("a", file.path(tmp, "a.csv"))
  writeLines("ab", file.path(tmp, "b.csv"))
  info <- ato_cache_info()
  expect_equal(info$n_files, 2L)
})

test_that("ato_clear_cache removes files", {
  tmp <- tempfile("ato_cache_")
  op <- options(ato.cache_dir = tmp)
  on.exit(options(op), add = TRUE)
  dir.create(tmp, recursive = TRUE)
  writeLines("x", file.path(tmp, "x.csv"))
  expect_invisible(ato_clear_cache())
  expect_false(file.exists(file.path(tmp, "x.csv")))
})

test_that("ato_format_bytes formats thresholds", {
  expect_equal(ato:::ato_format_bytes(0), "0 B")
  expect_match(ato:::ato_format_bytes(1500), "KB$")
  expect_match(ato:::ato_format_bytes(1500000), "MB$")
})
