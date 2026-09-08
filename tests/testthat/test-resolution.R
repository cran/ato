# Regression tests for the two resolution bugs found in 0.1.0:
# the search query encoding, and Snapshot workbooks shadowing the
# detailed Individuals tables.

# --- Query construction (offline) -------------------------------------

test_that("search URL separates org filter and query with %20, not %2B", {
  url <- ato:::ato_ckan_search_url(q = "taxation-statistics", rows = 50L)

  # %2B is a literal plus to Solr, which matched nothing and made
  # every year = "latest" call fail.
  expect_false(grepl("%2B", url, fixed = TRUE))
  expect_match(url, "organization%3Aaustraliantaxationoffice%20taxation-statistics",
               fixed = TRUE)
})

test_that("search URL omits the separator when q is NULL or empty", {
  expect_match(ato:::ato_ckan_search_url(), "q=organization%3Aaustraliantaxationoffice&")
  expect_match(ato:::ato_ckan_search_url(q = ""), "q=organization%3Aaustraliantaxationoffice&")
})

# --- Resource resolution (offline, mocked package) --------------------

fake_ts_package <- function(...) {
  res <- function(name, file) {
    list(name = name,
         url = paste0("https://data.gov.au/data/dataset/x/resource/y/download/", file))
  }
  list(resources = list(
    res("Detailed table Index", "taxstats2024index.xlsx"),
    res("Snapshot - Table 1",  "ts24snapshot01historicalratesofpersonalincometax.xlsx"),
    res("Snapshot – Table 7",
        "ts24snapshot07stateindividualsstatepostcodeoccupationstats.xlsx"),
    res("Individuals - Table 1",  "ts24individual01byyear.xlsx"),
    res("Individuals - Table 6",  "ts24individual06taxablestatusstatesa4postcode.xlsx"),
    res("Individuals - Table 14", "ts24individual14occupationsextaxableincomerange.xlsx")
  ))
}

test_that("exclude keeps Snapshot workbooks from shadowing detailed tables", {
  local_mocked_bindings(ato_ckan_package = fake_ts_package)

  # Bare "postcode" and "occupation" both appear in the Snapshot 7
  # filename, which sits ahead of Individuals 6 and 14.
  expect_match(ato:::ato_ckan_resolve("x", "postcode")$url, "snapshot07")
  expect_match(
    ato:::ato_ckan_resolve("x", "postcode", exclude = "snapshot")$url,
    "individual06"
  )
  expect_match(
    ato:::ato_ckan_resolve("x", "occupation", exclude = "snapshot")$url,
    "individual14"
  )
})

test_that("patterns are tried in priority order", {
  local_mocked_bindings(ato_ckan_package = fake_ts_package)

  # Anchor wins when present.
  expect_match(
    ato:::ato_ckan_resolve("x", c("individual06", "postcode"))$url,
    "individual06"
  )
  # Fallback is used when the anchor misses.
  expect_match(
    ato:::ato_ckan_resolve("x", c("individual99", "occupation"),
                           exclude = "snapshot")$url,
    "individual14"
  )
})

test_that("ato_ckan_resolve errors when no pattern matches", {
  local_mocked_bindings(ato_ckan_package = fake_ts_package)
  expect_error(ato:::ato_ckan_resolve("x", c("nope", "alsonope")),
               "No resource")
})

test_that("the individuals family resolves to its documented tables", {
  local_mocked_bindings(ato_ckan_package = fake_ts_package)

  expect_match(
    ato:::ato_ckan_resolve("x", c("individual01", "individual_01"),
                           exclude = "snapshot")$url,
    "individual01"
  )
})

# --- Column matching (offline) ----------------------------------------

test_that("ato_find_col tolerates ATO footnote digits", {
  df <- data.frame(postcode = 1, state_territory1 = "NSW",
                   check.names = FALSE)
  expect_identical(ato:::ato_find_col(df, "state"), "state_territory1")
  expect_identical(ato:::ato_find_col(df, "postcode"), "postcode")
})

test_that("ato_find_col prefers an exact name over a footnoted one", {
  df <- data.frame(state = "NSW", state_territory1 = "NSW",
                   check.names = FALSE)
  expect_identical(ato:::ato_find_col(df, "state"), "state")
})

test_that("ato_find_col still warns when nothing matches", {
  expect_warning(ato:::ato_find_col(data.frame(a = 1), "state"),
                 "Could not find")
})

# --- Live: the default argument actually resolves ----------------------
# Deliberately NOT behind ATO_LIVE_TESTS. year = "latest" is the
# default on 27 exported functions; in 0.1.0 it errored for every
# one of them and no test noticed, because every live test pinned an
# explicit year and sat behind an opt-in gate.

test_that("year = 'latest' resolves to a well-formed release slug", {
  skip_on_cran()
  skip_if_offline()

  id <- ato:::ato_ts_package_id("latest")
  expect_match(id, "^taxation-statistics-[0-9]{4}-[0-9]{2}$")

  # Must be a real release, not a stale hardcoded fallback.
  start <- as.integer(sub("^taxation-statistics-([0-9]{4})-.*$", "\\1", id))
  expect_gte(start, 2023L)
})
