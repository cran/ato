# Fringe Benefits Tax

#' Fringe Benefits Tax statistics
#'
#' Returns the ATO's annual Fringe Benefits Tax (FBT) Taxation
#' Statistics: employer counts, gross taxable value, FBT payable,
#' and employee benefit counts by benefit type and industry. Used
#' by Treasury, PBO, and researchers evaluating the FBT concession
#' system (electric vehicles, remote area exemptions, novated
#' leases).
#'
#' @param year Income year in `"YYYY-YY"` form (e.g. `"2022-23"`)
#'   or `"latest"`.
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD.
#'
#' @source Australian Taxation Office FBT Taxation Statistics
#'   on data.gov.au. Licensed CC BY 2.5 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Fringe Benefits Tax Assessment
#'   Act 1986}. Substantive FBT law; ATO rulings (TR series)
#'   elaborate taxable-value methodology.
#'
#' Australian Taxation Office (annual). \emph{FBT explanatory
#'   notes}. Definitions of reportable benefits, gross-up factors
#'   (Type 1 and Type 2), and otherwise-deductible rule.
#'
#' Treasury (2022). \emph{Electric Car Discount Bill}.
#'   Explanatory memorandum for the EV FBT exemption introduced
#'   1 July 2022.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   fbt <- ato_fbt(year = "2022-23")
#'   head(fbt)
#' })
#' options(op)
#' }
ato_fbt <- function(year = "latest") {
  # Discover the FBT package by searching the catalogue.
  result  <- ato_ckan_search(q = "fringe-benefits-tax", rows = 10L)
  pkgs    <- result$results
  ids     <- vapply(pkgs, function(p) p$name %||% "", character(1))
  fbt_ids <- ids[grepl("fringe.benefits", ids, ignore.case = TRUE)]

  if (length(fbt_ids) == 0L) {
    cli::cli_abort(c(
      "Could not find a Fringe Benefits Tax package on data.gov.au.",
      "i" = "Browse: {.url https://data.gov.au/data/organization/australiantaxationoffice}"
    ))
  }
  pkg_id <- fbt_ids[1L]
  ato_check_staleness(pkg_id)

  if (identical(year, "latest")) {
    pkg  <- ato_ckan_package(pkg_id)
    urls <- vapply(pkg$resources %||% list(),
                   function(r) r$url %||% "", character(1))
    years <- regmatches(urls, regexpr("20[0-9]{2}-[0-9]{2}", urls))
    year  <- if (length(years) > 0L) max(years) else "2022-23"
  } else {
    year <- ato_resolve_year(year)
  }

  res <- ato_ckan_resolve(pkg_id, year)
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO FBT Taxation Statistics ", year))
}
