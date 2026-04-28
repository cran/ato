# Fuel Tax Credits: rates and claimant detail by industry.

#' Fuel Tax Credits by industry and claim period
#'
#' Returns the Fuel Tax Credits scheme data: entitlement rates
#' by fuel type, claim totals by industry. FTC is a major
#' implicit fossil-fuel subsidy and is a key lens for
#' decarbonisation policy cost-benefit analysis.
#'
#' The ATO publishes FTC data as part of the Excise Data release
#' and in standalone FTC tables.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param by One of `"industry"` (default, by ANZSIC division),
#'   `"fuel"` (by fuel type), or `"period"` (quarterly rates).
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
  pkg <- ato_ckan_package(ATO_PACKAGE_IDS$excise)
  pattern <- switch(by,
    industry = "fuel.*(credit|ftc).*industry|ftc.*industry",
    fuel     = "fuel.*(credit|ftc).*fuel|ftc.*fuel",
    period   = "fuel.*(credit|ftc).*(rate|period)|ftc.*rate"
  )
  res <- ato_ckan_resolve(ATO_PACKAGE_IDS$excise, pattern)
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
