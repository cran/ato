# Fuel Tax Credits: rates and claimant detail by industry.

#' Fuel Tax Credits by industry and claim period
#'
#' Returns the Fuel Tax Credits scheme data: entitlement rates
#' by fuel type, claim totals by industry. FTC is a major
#' implicit fossil-fuel subsidy and is a key lens for
#' decarbonisation policy cost-benefit analysis.
#'
#' FTC data lives in two different places and this function routes
#' between them. Claim totals by industry are an Excise table
#' inside the annual Taxation Statistics release
#' (`tsNNexcise04ftcbyindustryyear.xlsx`). Entitlement rates are in
#' the separate, more frequently updated Excise Data package
#' (`historical-ftc-rates-*.xlsx`, rates by fuel type back to
#' 2006). Earlier versions looked for both in Excise Data, where
#' the industry table has never been published.
#'
#' @param year `"YYYY-YY"` or `"latest"`. Applies to `by =
#'   "industry"` only; the rates file is a single all-years
#'   workbook.
#' @param by One of `"industry"` (default, claim totals by ANZSIC
#'   division, from Taxation Statistics), `"fuel"` or `"period"`
#'   (both return the historical entitlement-rate schedule by fuel
#'   type, from Excise Data).
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Excise and Fuel Tax Credit
#'   data. Licensed CC BY 3.0 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Fuel Tax Act 2006}; \emph{Fuel
#'   Tax (Consequential and Transitional Provisions) Act 2006}.
#'
#' Denniss, R. and Grudnoff, M. (2021). \emph{Fossil fuel
#'   subsidies in Australia}. The Australia Institute. FTC-as-
#'   subsidy framing used in decarbonisation policy analysis.
#'
#' Intergovernmental Panel on Climate Change (2022). \emph{Climate
#'   Change 2022: Mitigation of Climate Change}. Chapter 13
#'   covers fossil-fuel subsidy reform.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(head(ato_fuel_tax_credits(year = "latest", by = "industry")))
#' options(op)
#' }
ato_fuel_tax_credits <- function(year = "latest",
                                  by = c("industry", "fuel", "period")) {
  by <- match.arg(by)
  if (by == "industry") {
    pkg_id  <- ato_ts_package_id(year)
    pattern <- c("excise04", "ftc.*industry", "fuel.*(credit|ftc).*industry")
  } else {
    pkg_id  <- ATO_PACKAGE_IDS$excise
    pattern <- c("historical.ftc.rates", "ftc.*rate",
                 "fuel.*(credit|ftc).*(rate|period)")
  }
  res <- ato_ckan_resolve(pkg_id, pattern)
  url <- res$url %||% ""
  df <- if (grepl("\\.csv$", url, ignore.case = TRUE)) {
    ato_fetch_csv(url)
  } else {
    ato_fetch_xlsx(url, sheet = 1)
  }
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 3.0 AU",
              title = paste0("ATO fuel tax credits ", year, " (", by, ")"))
}
