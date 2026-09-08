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
  # Charities are a table family inside Taxation Statistics
  # (Charities Tables 1 to 4), not a standalone package.
  pkg_id <- ato_ts_package_id(year)
  ato_check_staleness(pkg_id)

  res <- ato_ckan_resolve(pkg_id, c("charities01", "charities_01", "charit"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO charity / DGR statistics ", year))
}
