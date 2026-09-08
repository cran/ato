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
  # FBT is a table family inside the annual Taxation Statistics
  # release (FBT Tables 1 to 3), not a standalone package. Version
  # 0.1.0 searched for a "fringe-benefits-tax" package that has
  # never existed on data.gov.au.
  pkg_id <- ato_ts_package_id(year)
  ato_check_staleness(pkg_id)

  res <- ato_ckan_resolve(pkg_id, c("fbt01", "fbt_01", "fbt"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO FBT Taxation Statistics ", year))
}
