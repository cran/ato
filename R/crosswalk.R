# Classification crosswalks: bundled lookup tables for ANZSIC
# 2006 -> 2020, ANZSCO 2013 -> 2021, and a state-anchor postcode
# file. Full fine-grained crosswalks (4-digit ANZSIC, 6-digit
# ANZSCO, postcode to SA2/LGA/CED) should be fetched from ABS.

#' Load a bundled ATO crosswalk table
#'
#' Returns one of the bundled classification crosswalks. Used
#' internally by [ato_harmonise()] and available for user-level
#' panel work.
#'
#' Bundled crosswalks (at division/major-group level):
#' - `"anzsic"`: ANZSIC 2006 to 2020 (19 divisions, complete)
#' - `"anzsco"`: ANZSCO 2013 to 2021 (8 major groups, complete)
#' - `"postcode"`: postcode first-digit to state anchors
#' - `"cpi"`: ABS CPI annual, base 2011-12 = 1.0
#' - `"erp"`: ABS Estimated Resident Population, June 30 annual
#' - `"budget"`: Final Budget Outcome reference totals
#'
#' For 4-digit ANZSIC, 6-digit ANZSCO, or postcode-to-SA2/LGA/CED
#' crosswalks, fetch the full tables from ABS. The bundled
#' division/major-group level covers cross-year ATO Taxation
#' Statistics joins at the industry headings used in all ATO
#' tables.
#'
#' @param name One of `"anzsic"`, `"anzsco"`, `"postcode"`,
#'   `"cpi"`, `"erp"`, `"budget"`.
#'
#' @return A data frame.
#'
#' @references
#' Australian Bureau of Statistics (2006). \emph{Australian and
#'   New Zealand Standard Industrial Classification (ANZSIC)}.
#'   Catalogue 1292.0.
#'
#' Australian Bureau of Statistics (2020). \emph{ANZSIC 2006
#'   Update}, cat. 1292.0, divisional structure. Used by ATO
#'   Taxation Statistics from 2022-23.
#'
#' Australian Bureau of Statistics (2013). \emph{Australian and
#'   New Zealand Standard Classification of Occupations
#'   (ANZSCO)}. Catalogue 1220.0.
#'
#' Australian Bureau of Statistics (2022). \emph{ANZSCO Revised
#'   Edition}, cat. 1220.0. Used by ATO Taxation Statistics from
#'   2022-23 onward.
#'
#' @family harmonisation
#' @export
#' @examples
#' ato_crosswalk("anzsic")
#' ato_crosswalk("cpi")
ato_crosswalk <- function(name = c("anzsic", "anzsco", "postcode",
                                    "cpi", "erp", "budget")) {
  name <- match.arg(name)
  file <- switch(name,
    anzsic   = "anzsic_2006_2020_crosswalk.csv",
    anzsco   = "anzsco_2013_2021_crosswalk.csv",
    postcode = "postcode_state_crosswalk.csv",
    cpi      = "abs_cpi_annual.csv",
    erp      = "abs_erp_annual.csv",
    budget   = "budget_reference_totals.csv"
  )
  path <- system.file("extdata", file, package = "ato")
  if (!nzchar(path) || !file.exists(path)) {
    cli::cli_abort("Crosswalk file {.file {file}} not installed.")
  }
  utils::read.csv(path, stringsAsFactors = FALSE,
                  na.strings = c("", "NA"), check.names = FALSE)
}
