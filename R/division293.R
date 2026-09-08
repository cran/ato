# Division 293: extra 15% tax on concessional super contributions
# for high-income earners (over AUD 250k combined income).

#' Division 293 tax assessments (high-income super contributions)
#'
#' Returns Division 293 tax data: number of assessments, average
#' Division 293 liability, and distribution by income band. Division
#' 293 applies an extra 15% tax on concessional super contributions
#' for individuals with combined income plus low-tax super
#' contributions above AUD 250,000. Central to retirement-income
#' reform analysis (e.g. Grattan's "Better Super" proposals).
#'
#' **Defunct.** Division 293 assessments are not published as a
#' labelled series in Taxation Statistics. There is no "Table 3b",
#' and no Division 293 column appears in the Individuals or
#' SuperFunds detailed tables of the current release. Version
#' 0.1.0 fell back to Individuals Table 3 (sex by taxable status
#' by age range by taxable income range) and labelled the result
#' "ATO Division 293", which was wrong.
#'
#' It now aborts rather than mislabelling an unrelated table, and
#' will be removed in a future release.
#'
#' @param year `"YYYY-YY"` or `"latest"`. Ignored.
#'
#' @return Never returns; always aborts.
#'
#' @source Australian Taxation Office Taxation Statistics
#'   Individuals. Licensed CC BY 2.5 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Income Tax Assessment Act
#'   1997}, Division 293. Extra 15 per cent tax on concessional
#'   super contributions for high-income earners.
#'
#' Daley, J., Coates, B. and Wood, D. (2018). \emph{Money in
#'   retirement: more than enough}. Grattan Institute. Uses
#'   Division 293 distributional data in reform analysis.
#'
#' @family specialist
#' @export
#' @examples
#' try(ato_division293())
ato_division293 <- function(year = "latest") {
  cli::cli_abort(c(
    "Division 293 assessments are not published in Taxation Statistics.",
    "i" = "No Division 293 column exists in the Individuals or SuperFunds tables.",
    "i" = "Concessional contributions detail: {.code ato_individuals(year)} \\
           Tables 20 to 24 via {.code ato_download()}.",
    "i" = "See {.url https://www.ato.gov.au/about-ato/research-and-statistics/}"
  ))
}
