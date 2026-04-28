# Dataset metadata

#' Fetch CKAN metadata for an ATO dataset
#'
#' Returns structured metadata for any ATO dataset on data.gov.au:
#' title, notes, licence, last-modified timestamp, resource count,
#' and all resource URLs. Useful for detecting silent updates before
#' clearing the cache, or for auditing what version of data you have.
#'
#' @param x Either an `ato_tbl` (as returned by any `ato_*` data
#'   function) or a character CKAN package ID / slug (e.g.
#'   `"taxation-statistics-2022-23"`, `"corporate-transparency"`).
#'
#' @return A list with elements:
#'   - `id`: CKAN package slug
#'   - `title`: human-readable title
#'   - `notes`: dataset description (truncated to 400 chars)
#'   - `licence`: licence title
#'   - `metadata_modified`: ISO timestamp of last CKAN update
#'   - `n_resources`: number of downloadable files
#'   - `resource_urls`: character vector of all resource URLs
#'
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   # By package ID
#'   m <- ato_meta("taxation-statistics-2022-23")
#'   m$metadata_modified
#'
#'   # From an ato_tbl
#'   tbl <- ato_individuals(year = "2022-23")
#'   ato_meta(tbl)
#' })
#' options(op)
#' }
ato_meta <- function(x) {
  if (inherits(x, "ato_tbl")) {
    src <- attr(x, "ato_source") %||% ""
    # Extract CKAN package slug from a data.gov.au resource URL.
    # URL form: .../data/dataset/<slug>/resource/<id>/download/...
    m <- regmatches(src, regexpr("dataset/([^/]+)", src))
    if (length(m) == 0L || !nzchar(m)) {
      cli::cli_abort(c(
        "Cannot determine package ID from source URL: {.val {src}}",
        "i" = "Pass the package slug directly instead."
      ))
    }
    pkg_id <- sub("dataset/", "", m, fixed = TRUE)
    pkg <- ato_ckan_package(pkg_id)
  } else if (is.character(x) && length(x) == 1L) {
    pkg <- ato_ckan_package(x)
  } else {
    cli::cli_abort(
      "{.arg x} must be an {.cls ato_tbl} or a character package ID."
    )
  }

  resources <- pkg$resources %||% list()
  urls <- vapply(resources, function(r) r$url %||% "", character(1))
  notes_raw <- pkg$notes %||% ""

  list(
    id                = pkg$name %||% "",
    title             = pkg$title %||% "",
    notes             = substr(notes_raw, 1L, 400L),
    licence           = pkg$license_title %||% pkg$license_id %||% "",
    metadata_modified = pkg$metadata_modified %||% "",
    n_resources       = length(resources),
    resource_urls     = urls
  )
}
