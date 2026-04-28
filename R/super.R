# Superannuation Taxation Statistics

#' Superannuation fund aggregates
#'
#' Returns Taxation Statistics Super Funds tables or Self-Managed
#' Superannuation Fund ('SMSF') aggregates, depending on `type`.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param type One of `"apra"` (APRA-regulated funds, default),
#'   `"smsf"` (SMSF statistical overview), or `"all"`.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics Super
#'   Funds tables + SMSF statistical overview. Licensed CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Taxation Statistics:
#'   Super funds and SMSF explanatory notes}. Distinguishes
#'   reporting populations: APRA-regulated large funds, SMSFs,
#'   and Pooled Superannuation Trusts.
#'
#' Australian Prudential Regulation Authority (annual).
#'   \emph{Annual Superannuation Bulletin}. Complementary
#'   APRA-regulated fund statistics.
#'
#' Commonwealth of Australia. \emph{Superannuation Industry
#'   (Supervision) Act 1993} (SIS Act); \emph{Superannuation
#'   Guarantee (Administration) Act 1992} (SGAA).
#'
#' Productivity Commission (2018). \emph{Superannuation:
#'   Assessing Efficiency and Competitiveness}. Inquiry report.
#'
#' @family super
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   s <- ato_super_funds(year = "2022-23", type = "apra")
#'   head(s)
#' })
#' options(op)
#' }
ato_super_funds <- function(year = "latest",
                             type = c("apra", "smsf", "all")) {
  type <- match.arg(type)
  if (type == "smsf") {
    res <- ato_ckan_resolve(ATO_PACKAGE_IDS$smsf,
                            "annual|overview|smsf")
    url <- res$url %||% ""
    df <- ato_fetch_xlsx(url, sheet = 1)
    return(new_ato_tbl(df,
                        source = url,
                        licence = "CC BY 2.5 AU",
                        title = "ATO SMSF annual overview"))
  }

  id <- ato_ts_package_id(year)
  pattern <- if (type == "apra") {
    # Real resource filenames are ts<YY>fund0[1-4]... (e.g. ts23fund01aprasbyyear.xlsx);
    # the display name is "SuperFunds - Table N".
    "fund0[1-4]|superfunds"
  } else {
    "super"
  }
  res <- ato_ckan_resolve(id, pattern)
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO super funds ", year, " (", type, ")"))
}
