# PAYG Withholding

#' PAYG withholding data
#'
#' Returns the ATO's Pay As You Go (PAYG) withholding data:
#' employer counts, total withholding amounts, and employee counts
#' by industry and state. Used by researchers studying labour
#' market taxation, wage growth, and employer compliance.
#'
#' @param year Income year in `"YYYY-YY"` form (e.g. `"2022-23"`)
#'   or `"latest"`.
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD.
#'
#' @source Australian Taxation Office PAYG withholding data
#'   on data.gov.au. Licensed CC BY 2.5 AU.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   payg <- ato_payg(year = "2022-23")
#'   head(payg)
#' })
#' options(op)
#' }
ato_payg <- function(year = "latest") {
  # PAYG withholding is a table family inside Taxation Statistics
  # (PAYG Tables 1 and 2), not a standalone package.
  pkg_id <- ato_ts_package_id(year)
  ato_check_staleness(pkg_id)

  res <- ato_ckan_resolve(pkg_id, c("payg01", "payg_01", "payg"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO PAYG withholding ", year))
}
