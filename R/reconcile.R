# Reconcile ATO Taxation Statistics totals against authoritative
# Commonwealth revenue figures (Final Budget Outcome, Budget
# Paper 1). This is the single biggest credibility feature for
# PBO or Grattan-style published work: a one-row diff table
# showing what the ATO data implies vs what Treasury reports.

#' Reconcile an aggregate against Commonwealth budget totals
#'
#' Compares a scalar (or data frame total) against the published
#' Final Budget Outcome figure for the same year and revenue line.
#' Useful as a sanity check on an ATO Taxation Statistics sum
#' before reporting it in a paper or brief.
#'
#' @details
#' Discrepancies between ATO Taxation Statistics aggregates and
#' the Final Budget Outcome (FBO) are expected and meaningful:
#' \itemize{
#'   \item Taxation Statistics are based on assessments made by a
#'     cut-off date (usually October of the following calendar
#'     year) and may exclude late-lodging returns.
#'   \item FBO figures are cash-basis Commonwealth receipts;
#'     Taxation Statistics are accrual-basis tax assessed.
#'   \item GST, excise, and fuel credits have timing and refund
#'     effects that further distort the cash-vs-assessment gap.
#' }
#' A 1-3 per cent gap is consistent with the accrual-to-cash
#' reconciliation Treasury publishes in the FBO statement of
#' revenues; larger gaps warrant investigation. The bundled
#' reference totals in `inst/extdata/budget_reference_totals.csv`
#' are taken from the relevant FBO release, with the precise table
#' cited in the `source` column of each row.
#'
#' @param value Numeric; the figure to check, in AUD (not AUD
#'   billions). An `ato_tbl` can also be passed: pass `sum_column`
#'   to pick which numeric column to sum.
#' @param year Financial year, e.g. `"2022-23"`.
#' @param measure One of the measure codes in `ato_crosswalk("budget")`,
#'   for example `"individuals_income_tax_net"`,
#'   `"company_tax_net"`, `"gst_net"`, `"fuel_excise_net"`.
#' @param sum_column Column name to sum when `value` is a data
#'   frame. Default `NULL` (errors if multiple numeric columns
#'   exist).
#'
#' @return A one-row data frame: `measure`, `year`,
#'   `value_aud`, `reference_aud`, `diff_aud`, `pct_diff`,
#'   `source`. Emits a warning if `abs(pct_diff) > 0.05`.
#'
#' @references
#' Commonwealth of Australia (various years). \emph{Final Budget
#'   Outcome}. The Treasury, Canberra.
#'   \url{https://budget.gov.au/content/fbo/index.htm}
#'
#' Australian Bureau of Statistics (various years).
#'   \emph{Taxation Revenue, Australia}. Catalogue 5506.0.
#'
#' Australian Taxation Office (annual). \emph{Australian tax gaps
#'   -- overview}, methodology notes on accrual-vs-cash
#'   reconciliation.
#'
#' @family harmonisation
#' @export
#' @examples
#' ato_reconcile(value = 316.4e9,
#'               year = "2022-23",
#'               measure = "individuals_income_tax_net")
ato_reconcile <- function(value, year, measure,
                           sum_column = NULL) {
  if (is.data.frame(value)) {
    cols <- names(value)[vapply(value, is.numeric, logical(1))]
    if (is.null(sum_column)) {
      if (length(cols) == 0L) {
        cli::cli_abort("No numeric columns in {.arg value}.")
      }
      if (length(cols) > 1L) {
        cli::cli_abort(c(
          "Multiple numeric columns in {.arg value}.",
          "i" = "Pass {.arg sum_column} to pick one: {.val {cols}}."
        ))
      }
      sum_column <- cols
    }
    v <- sum(value[[sum_column]], na.rm = TRUE)
  } else {
    stopifnot(is.numeric(value), length(value) == 1L)
    v <- value
  }

  ref <- ato_crosswalk("budget")
  hit <- ref[ref$financial_year == year & ref$measure == measure, ]
  if (nrow(hit) == 0L) {
    avail <- unique(ref$measure)
    cli::cli_abort(c(
      "No budget reference for {.val {measure}} in {.val {year}}.",
      "i" = "Available measures: {.val {avail}}.",
      "i" = "Available years: {.val {unique(ref$financial_year)}}."
    ))
  }
  ref_v <- hit$value_aud_billion[1L] * 1e9
  diff <- v - ref_v
  pct <- diff / ref_v

  if (abs(pct) > 0.05) {
    cli::cli_warn(c(
      "Reconciliation diff {round(100*pct, 1)}% for {.val {measure}} \\
       ({.val {year}}).",
      "i" = "ATO data: {.val {format(v, big.mark = ',', scientific = FALSE)}}.",
      "i" = "Reference: {.val {format(ref_v, big.mark = ',', scientific = FALSE)}}.",
      "i" = "Expected 1-3% accrual-vs-cash gap; investigate larger."
    ))
  }

  data.frame(
    measure       = measure,
    year          = year,
    value_aud     = v,
    reference_aud = ref_v,
    diff_aud      = diff,
    pct_diff      = pct,
    source        = hit$source[1L],
    stringsAsFactors = FALSE
  )
}
