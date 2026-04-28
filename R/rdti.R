# Research and Development Tax Incentive

#' R&D Tax Incentive claimants
#'
#' Returns the annual "Report of data about Research and
#' Development Tax Incentive entities": claimants, claimed
#' expenditure, refundable and non-refundable tax offsets by
#' industry and company size. Treasury and DISR use this series
#' to evaluate the R&D Tax Incentive programme, which is the
#' largest single element of Australia's business innovation
#' policy (AUD 2 billion+ per year).
#'
#' @param year Income year in `"YYYY-YY"` form (e.g.
#'   `"2022-23"`) or `"latest"`. Current releases cover 2021-22
#'   and 2022-23.
#'
#' @return An `ato_tbl` with one row per entity (or aggregated
#'   cell, depending on the release schema). Monetary values in
#'   nominal AUD.
#'
#' @source Australian Taxation Office Research and Development
#'   Tax Incentive report. Licensed CC BY 2.5 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Income Tax Assessment Act
#'   1997}, Division 355 (Research and Development Tax Incentive).
#'
#' Department of Industry, Science and Resources and Australian
#'   Taxation Office (annual). \emph{R&DTI Transparency Report}.
#'   Jointly administered programme methodology.
#'
#' Ferris, B., Finkel, A. and Fraser, J. (2016). \emph{Review of
#'   the R&D Tax Incentive}. Australian Government review
#'   (the "Three Fs review") informing subsequent programme design.
#'
#' Organisation for Economic Co-operation and Development (annual).
#'   \emph{R&D Tax Incentives Database}. International comparator
#'   data for R&D tax expenditures.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   rdti <- ato_rdti(year = "2022-23")
#'   head(rdti)
#' })
#' options(op)
#' }
ato_rdti <- function(year = "latest") {
  pkg_id <- ATO_PACKAGE_IDS$rdti
  if (identical(year, "latest")) {
    pkg <- ato_ckan_package(pkg_id)
    urls <- vapply(pkg$resources %||% list(),
                   function(r) r$url %||% "", character(1))
    years <- regmatches(urls, regexpr("20[0-9]{2}-[0-9]{2}", urls))
    year <- if (length(years) > 0L) max(years) else "2022-23"
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
              title = paste0("ATO R&D Tax Incentive ", year))
}
