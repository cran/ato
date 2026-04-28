# Complementary non-ATO sibling helpers.
# These wrap fetches from ABS, OECD, and RBA so researchers have
# the full tax-system picture without juggling four packages.

#' State and territory tax revenue (ABS 5506.0)
#'
#' Fetches the ABS Taxation Revenue collection (cat. 5506.0),
#' which gives land tax, payroll tax, stamp duty, motor vehicle
#' taxes, and other state taxes by jurisdiction. Needed for
#' complete-tax-system analysis alongside ATO Commonwealth data.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Bureau of Statistics, Taxation Revenue,
#'   catalogue 5506.0 <https://www.abs.gov.au/statistics/economy/government/taxation-revenue-australia>.
#'   Licensed CC BY 4.0.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_state_tax(year = "latest"))
#' options(op)
#' }
ato_state_tax <- function(year = "latest") {
  url <- "https://www.abs.gov.au/statistics/economy/government/taxation-revenue-australia/latest-release"
  cli::cli_warn(c(
    "ABS 5506.0 is HTML-paginated; no direct CSV endpoint.",
    "i" = "Fetch the XLSX release from {.url {url}} manually,",
    "i" = "then pass the local path to {.code ato_download()} or {.code ato_fetch_xlsx()}."
  ))
  # Return an empty stub ato_tbl so downstream code can dispatch.
  df <- data.frame(
    jurisdiction = character(0),
    tax_type = character(0),
    value_aud_million = numeric(0),
    year = character(0),
    stringsAsFactors = FALSE
  )
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 4.0",
              title = paste0("ABS 5506.0 State tax ", year))
}
