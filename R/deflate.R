# Deflation: convert nominal AUD to real AUD of a chosen base
# financial year, using ABS CPI All Groups Australia (bundled).

#' Deflate nominal AUD to real AUD
#'
#' Converts a numeric vector of nominal AUD figures indexed by
#' financial year to real AUD of a chosen base year using the
#' bundled ABS CPI series (annual, All Groups Australia,
#' 2011-12 = 1.0). For the user's `inflateR` workflow in
#' non-Australian contexts, bundle a matching CPI series and
#' call this with a custom `cpi =` argument.
#'
#' @details
#' Uses proportional (Laspeyres-style) adjustment:
#' \eqn{real = nominal \times (CPI_{base} / CPI_{source})}. The
#' bundled CPI is the ABS annual All Groups Australia index
#' published in cat. 6401.0, rebased so that 2011-12 = 1.000.
#' This is the standard rebasing used in most Australian
#' time-series work and is consistent with ABS System of National
#' Accounts methodology (cat. 5204.0).
#'
#' The formula is exact for a chain-linked index after 1949 (when
#' the ABS CPI was introduced) and approximate for earlier values
#' that rely on Commonwealth Statistician retail-price series. Use
#' a custom `cpi =` argument if you need a different deflator
#' (e.g. GDP deflator, wage price index, or industry-specific PPI).
#'
#' @param x Numeric vector of nominal AUD values.
#' @param year Character vector of financial years for each entry
#'   in `x`, in `"YYYY-YY"` form. Must be the same length as `x`.
#' @param base Base financial year for real terms (default
#'   `"2022-23"`).
#' @param cpi Optional override: a data frame with columns
#'   `financial_year` and `cpi_all_groups_australia`. Default
#'   uses the bundled ABS series.
#'
#' @return Numeric vector of real AUD values in base-year prices.
#'
#' @references
#' Australian Bureau of Statistics (2024). \emph{Consumer Price
#'   Index, Australia: Concepts, Sources and Methods}. Catalogue
#'   6461.0.
#'
#' Australian Bureau of Statistics (2024). \emph{Consumer Price
#'   Index, Australia}. Catalogue 6401.0.
#'
#' Diewert, W.E. (1998). "Index Number Issues in the Consumer Price
#'   Index." \emph{Journal of Economic Perspectives}, 12(1),
#'   47-58. \doi{10.1257/jep.12.1.47}
#'
#' @family harmonisation
#' @export
#' @examples
#' ato_deflate(c(100, 100, 100),
#'             year = c("2012-13", "2017-18", "2022-23"),
#'             base = "2022-23")
ato_deflate <- function(x, year, base = "2022-23", cpi = NULL) {
  stopifnot(is.numeric(x), is.character(year), length(x) == length(year))
  if (is.null(cpi)) cpi <- ato_crosswalk("cpi")
  cpi_vec <- stats::setNames(cpi$cpi_all_groups_australia, cpi$financial_year)
  base_val <- cpi_vec[[base]]
  if (is.null(base_val) || is.na(base_val)) {
    cli::cli_abort(c(
      "Base year {.val {base}} not in CPI series.",
      "i" = "Available: {.val {names(cpi_vec)}}."
    ))
  }
  ratios <- base_val / cpi_vec[year]
  missing <- is.na(ratios)
  if (any(missing)) {
    cli::cli_warn(c(
      "CPI missing for {.val {unique(year[missing])}}; \\
       those entries returned as {.val NA}."
    ))
  }
  unname(x * ratios)
}

#' Express an aggregate per capita using ABS ERP
#'
#' @details
#' Divides the input by Estimated Resident Population at 30 June
#' of the financial year's end (a stock measure). For flow-style
#' measures where a mid-year-average population is preferable,
#' substitute a custom `erp =` argument. ERP is ABS's preferred
#' population-denominator concept for per-capita economic
#' statistics (see cat. 3101.0 methodology).
#'
#' @param x Numeric vector of aggregate values (same length as
#'   `year`).
#' @param year Character vector of financial years.
#' @param erp Optional override: data frame with columns
#'   `financial_year` and `erp_june_australia_thousands`.
#'
#' @return Numeric vector of per-capita values (same units as `x`
#'   per person).
#'
#' @references
#' Australian Bureau of Statistics (2024). \emph{National,
#'   State and Territory Population}. Catalogue 3101.0.
#'
#' @family harmonisation
#' @export
#' @examples
#' # Income tax per person, 2022-23 FBO headline
#' ato_per_capita(316.4e9, "2022-23")
ato_per_capita <- function(x, year, erp = NULL) {
  stopifnot(is.numeric(x), is.character(year), length(x) == length(year))
  if (is.null(erp)) erp <- ato_crosswalk("erp")
  erp_vec <- stats::setNames(erp$erp_june_australia_thousands * 1e3,
                       erp$financial_year)
  pop <- erp_vec[year]
  missing <- is.na(pop)
  if (any(missing)) {
    cli::cli_warn(c(
      "ERP missing for {.val {unique(year[missing])}}; \\
       those entries returned as {.val NA}."
    ))
  }
  unname(x / pop)
}
