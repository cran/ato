# International Related Party Dealings

#' International Related Party Dealings (IRPD)
#'
#' Returns the ATO's International Related Party Dealings data,
#' which captures intra-group cross-border payments and
#' receivables reported by Australian corporate taxpayers. Core
#' dataset for BEPS and transfer-pricing research, transfer
#' pricing risk assessment, and multinational tax analysis.
#'
#' The IRPD data is published as a separate CKAN package per
#' income year (2019-20 through 2023-24). Each annual package
#' contains three tables:
#' - **Table 1** : IRPD totals from 2015-16 to the current year
#' - **Table 2** : IRPDs by jurisdiction
#' - **Table 3** : Index of chart data
#'
#' @param year Income year in `"YYYY-YY"` form (e.g.
#'   `"2023-24"`) or `"latest"`.
#' @param table Integer 1, 2, or 3. Default `1`.
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD.
#'
#' @source Australian Taxation Office International Related
#'   Party Dealings release. Licensed CC BY 2.5 AU.
#'
#' @references
#' Organisation for Economic Co-operation and Development (2015).
#'   \emph{Transfer Pricing Documentation and Country-by-Country
#'   Reporting, Action 13: 2015 Final Report}. OECD/G20 Base
#'   Erosion and Profit Shifting Project, Paris.
#'   \doi{10.1787/9789264241480-en}
#'
#' Commonwealth of Australia. \emph{Income Tax Assessment Act
#'   1997}, Subdivision 815-B (Transfer Pricing); \emph{Multinational
#'   Anti-Avoidance Law} (MAAL) and \emph{Diverted Profits Tax}.
#'
#' Australian Taxation Office (annual). \emph{International
#'   Dealings Schedule (IDS) instructions}. Reporting framework
#'   underlying the IRPD dataset.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   by_jurisdiction <- ato_irpd(year = "2023-24", table = 2)
#'   head(by_jurisdiction)
#' })
#' options(op)
#' }
ato_irpd <- function(year = "latest", table = 1L) {
  stopifnot(table %in% c(1L, 2L, 3L))

  if (identical(year, "latest")) {
    # Search all IRPD packages for the most recent year
    result <- ato_ckan_search(q = "international-related-party-dealings",
                              rows = 20L)
    ids <- vapply(result$results,
                  function(p) p$name %||% "", character(1))
    years <- regmatches(ids, regexpr("20[0-9]{2}-[0-9]{2}$", ids))
    year <- if (length(years) > 0L) max(years) else "2023-24"
  } else {
    year <- ato_resolve_year(year)
  }

  # The 2019-20 release uses the bare slug (no suffix); later
  # releases append the year. Try suffixed form first, then bare.
  pkg_id <- paste0(ATO_PACKAGE_IDS$irpd_bare, "-", year)
  ato_check_staleness(pkg_id)
  res <- tryCatch(
    ato_ckan_resolve(pkg_id, sprintf("table[_-]?%d", table)),
    error = function(e) {
      ato_ckan_resolve(ATO_PACKAGE_IDS$irpd_bare,
                       sprintf("table[_-]?%d", table))
    }
  )
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO IRPD ", year, " (Table ", table, ")"))
}
