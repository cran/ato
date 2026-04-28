# Reproducibility: session-level snapshot date pin.
#
# The snapshot_date is an ISO date the user records as the intended
# vintage of the data. Fetchers record it in provenance attributes
# and in the manifest. It does not alter CKAN requests (CKAN does
# not generally serve historical URLs), but gives a human-readable
# pin that pairs with SHA-256 integrity checks.

#' Pin or inspect the session snapshot date
#'
#' Call once at the top of an analysis script to declare the vintage
#' of ATO data you intend to use. Every subsequent `ato_*` fetch
#' records this date in the `ato_tbl` provenance header, in
#' `ato_manifest()` entries, and in `ato_cite()` output. Combined
#' with SHA-256 integrity (see [ato_sha256()] and [ato_manifest()]),
#' this gives a reproducible audit trail acceptable for PBO or
#' Grattan-style published work.
#'
#' If called with no arguments, returns the current pin (or `NULL`
#' if unset).
#'
#' @param date ISO `"YYYY-MM-DD"` character, `Date`, or `POSIXct`.
#'   Pass `NULL` to clear.
#'
#' @return Invisibly, the new pinned date (as `Date`), or `NULL`.
#' @family reproducibility
#' @export
#' @examples
#' ato_snapshot("2026-04-24")
#' ato_snapshot()
#' ato_snapshot(NULL)
ato_snapshot <- function(date) {
  if (missing(date)) {
    return(.ato_env$snapshot_date %||% NULL)
  }
  if (is.null(date)) {
    .ato_env$snapshot_date <- NULL
    return(invisible(NULL))
  }
  d <- tryCatch(as.Date(date), error = function(e) NA)
  if (is.na(d)) {
    cli::cli_abort(
      "Could not parse {.arg date} as a date. Use {.val YYYY-MM-DD}."
    )
  }
  .ato_env$snapshot_date <- d
  invisible(d)
}

#' Get the current snapshot pin as a character string (or NA)
#' @noRd
ato_snapshot_str <- function() {
  d <- .ato_env$snapshot_date %||% NULL
  if (is.null(d)) NA_character_ else format(d, "%Y-%m-%d")
}
