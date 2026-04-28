# RBA Commonwealth receipts helper.

#' RBA Commonwealth receipts (H1 statistical table)
#'
#' Pointer to the RBA's H1 series on Commonwealth receipts for
#' long-run time series. RBA compiles since 1959-60, filling gaps
#' in ATO Taxation Statistics which start 1994-95.
#'
#' The RBA publishes H1 as an XLSX with stable URL. This function
#' fetches it and returns a tidy tibble.
#'
#' @param series One of `"receipts"` (default, all Commonwealth
#'   receipts by category) or `"income_tax"` (income tax only).
#'
#' @return An `ato_tbl`.
#'
#' @source Reserve Bank of Australia Statistical Tables H1
#'   <https://www.rba.gov.au/statistics/tables/>.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_rba(series = "receipts"))
#' options(op)
#' }
ato_rba <- function(series = c("receipts", "income_tax")) {
  series <- match.arg(series)
  url <- "https://www.rba.gov.au/statistics/tables/xls/h01hist.xlsx"
  df <- tryCatch(ato_fetch_xlsx(url, sheet = 1),
                 error = function(e) {
                   cli::cli_warn(c(
                     "RBA fetch failed: {conditionMessage(e)}.",
                     "i" = "RBA sometimes rotates URLs; check {.url https://www.rba.gov.au/statistics/tables/}."
                   ))
                   data.frame()
                 })
  new_ato_tbl(df,
              source = url,
              licence = "RBA terms",
              title = paste0("RBA Commonwealth ", series))
}
