# Australian Tax Gaps

#' Australian tax gaps estimates
#'
#' Returns the ATO's annual Tax Gap publication: estimates of
#' the difference between the tax theoretically payable under
#' current law and the tax actually collected, across each tax
#' type and taxpayer population (individuals not in business,
#' small business, large corporate, GST, excise, fuel tax
#' credits, PRRT, superannuation guarantee).
#'
#' The Tax Gap series is used by Treasury (every MYEFO), the
#' Parliamentary Budget Office, and academic researchers as the
#' headline measure of revenue integrity.
#'
#' @param sheet Optional sheet name or index. The workbook
#'   contains separate sheets for each tax-gap population (e.g.
#'   "Large corporate", "Small business", "Individuals"). Pass
#'   the sheet name to extract a specific population. `NULL`
#'   (default) returns sheet 1 (overview).
#'
#' @return An `ato_tbl`. Tax-gap estimates are in nominal AUD
#'   millions of the reporting year and typically accompanied by
#'   a percentage-gap column.
#'
#' @source Australian Taxation Office Tax Gaps publication,
#'   CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Australian tax gaps
#'   -- overview}. Methodology notes on bottom-up, top-down, and
#'   random-inquiry approaches to the tax-gap estimation.
#'
#' HMRC (annual). \emph{Measuring tax gaps}. Sister methodology
#'   paper applied by HM Revenue and Customs in the UK; the ATO
#'   series was partly inspired by this literature.
#'
#' Organisation for Economic Co-operation and Development (2017).
#'   \emph{Shining Light on the Shadow Economy: Opportunities and
#'   Threats}. Paris. Synthesises tax-gap measurement practice
#'   across OECD member countries.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   gaps <- ato_tax_gaps()
#'   head(gaps)
#' })
#' options(op)
#' }
ato_tax_gaps <- function(sheet = 1) {
  ato_check_staleness(ATO_PACKAGE_IDS$tax_gaps)
  res <- ato_ckan_resolve(ATO_PACKAGE_IDS$tax_gaps,
                          "australian-tax-gaps.*publication|tax-gaps")
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = sheet)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO Tax Gaps (sheet: ", sheet, ")"))
}
