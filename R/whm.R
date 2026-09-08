# Working Holiday Maker (WHM) tax aggregates

#' Working Holiday Maker tax data (not available)
#'
#' **Defunct.** The ATO does not publish Working
#' Holiday Maker aggregates as open data. No resource matching
#' working holiday makers, WHM or backpackers exists in any ATO
#' package on data.gov.au, in the current Taxation Statistics
#' release or in the archived ones. This function was shipped in
#' 0.1.0 on the assumption that such a table existed; it never
#' returned WHM data.
#'
#' It now aborts with a pointer to the published source rather
#' than resolving to an unrelated table. It will be removed in a
#' future release.
#'
#' @param year `"YYYY-YY"` or `"latest"`. Ignored.
#'
#' @return Never returns; always aborts.
#'
#' @source Australian Taxation Office Taxation Statistics.
#'   Licensed CC BY 2.5 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Migration Act 1958}, visa
#'   subclasses 417 and 462; \emph{Working Holiday Maker
#'   Reform Act 2016}. Establishes the 15 per cent flat
#'   tax rate from the first dollar of WHM earnings.
#'
#' Productivity Commission (2016). \emph{Migrant Intake into
#'   Australia}. Includes WHM labour-market analysis.
#'
#' @family specialist
#' @export
#' @examples
#' try(ato_whm())
ato_whm <- function(year = "latest") {
  cli::cli_abort(c(
    "Working Holiday Maker aggregates are not published as open data.",
    "i" = "No ATO package on data.gov.au contains a WHM resource.",
    "i" = "See {.url https://www.ato.gov.au/about-ato/research-and-statistics/}",
    "i" = "Use {.code ato_individuals(year)} for all-individuals aggregates."
  ))
}
