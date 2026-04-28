# Small Business Benchmarks

#' Small Business Benchmarks
#'
#' Returns the ATO's Small Business Benchmarks: industry-specific
#' performance ranges (cost of sales / turnover, total expenses /
#' turnover, labour / turnover, etc.) derived from small-business
#' income tax returns. Used by the ATO to identify outlier
#' taxpayers, by small-business advisors for comparative
#' analysis, and by tax integrity researchers.
#'
#' @param year Income year in `"YYYY-YY"` form (e.g.
#'   `"2023-24"`) or `"latest"`. Releases available from
#'   2016-17 onwards.
#'
#' @return An `ato_tbl` with one row per (industry, turnover
#'   band, ratio) combination. Ratios are percentages.
#'
#' @source Australian Taxation Office Small Business Benchmarks.
#'   Licensed CC BY 2.5 AU.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   bm <- ato_sme_benchmarks(year = "2023-24")
#'   head(bm)
#' })
#' options(op)
#' }
ato_sme_benchmarks <- function(year = "latest") {
  pkg_id <- ATO_PACKAGE_IDS$sme
  if (identical(year, "latest")) {
    pkg <- ato_ckan_package(pkg_id)
    urls <- vapply(pkg$resources %||% list(),
                   function(r) r$url %||% "", character(1))
    years <- regmatches(urls, regexpr("20[0-9]{2}-[0-9]{2}", urls))
    year <- if (length(years) > 0L) max(years) else "2023-24"
  } else {
    year <- ato_resolve_year(year)
  }
  ato_check_staleness(pkg_id)
  res <- ato_ckan_resolve(pkg_id, year)
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO Small Business Benchmarks ", year))
}
