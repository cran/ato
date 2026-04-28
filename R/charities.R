# Charity tax concessions

#' Charity and deductible gift recipient data
#'
#' Returns the ATO's data on income tax-exempt entities and
#' Deductible Gift Recipients (DGRs): entity counts, income,
#' expenditure, and gift deductions by charity subtype and
#' state. Covers public benevolent institutions, health promotion
#' charities, environmental organisations, and other DGR
#' categories.
#'
#' Used by Treasury (charity tax expenditure estimates),
#' researchers studying the non-profit sector, and civil society
#' policy analysts.
#'
#' @param year Income year in `"YYYY-YY"` form (e.g. `"2021-22"`)
#'   or `"latest"`.
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD.
#'
#' @source Australian Taxation Office charity statistics on
#'   data.gov.au. Licensed CC BY 2.5 AU.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   ch <- ato_charities(year = "2021-22")
#'   head(ch)
#' })
#' options(op)
#' }
ato_charities <- function(year = "latest") {
  result    <- ato_ckan_search(q = "charity tax", rows = 10L)
  pkgs      <- result$results
  ids       <- vapply(pkgs, function(p) p$name %||% "", character(1))
  char_ids  <- ids[grepl("charit|deductible.gift|dgr|not.for.profit",
                           ids, ignore.case = TRUE)]

  if (length(char_ids) == 0L) {
    cli::cli_abort(c(
      "Could not find a charity / DGR package on data.gov.au.",
      "i" = "Browse: {.url https://data.gov.au/data/organization/australiantaxationoffice}"
    ))
  }
  pkg_id <- char_ids[1L]
  ato_check_staleness(pkg_id)

  if (identical(year, "latest")) {
    pkg  <- ato_ckan_package(pkg_id)
    urls <- vapply(pkg$resources %||% list(),
                   function(r) r$url %||% "", character(1))
    years <- regmatches(urls, regexpr("20[0-9]{2}-[0-9]{2}", urls))
    year  <- if (length(years) > 0L) max(years) else "2021-22"
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
              title   = paste0("ATO charity / DGR statistics ", year))
}
