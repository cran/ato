# Medicare Levy and Medicare Levy Surcharge (MLS)

#' Medicare Levy and Medicare Levy Surcharge
#'
#' Returns Individuals Table 3 (sex by taxable status by age range
#' by taxable income range), which carries the "Medicare levy",
#' "Medicare levy surcharge" and "Total Medicare levy liability"
#' column pairs. The 2% Medicare Levy is on most taxable income;
#' MLS is an additional 1.0 to 1.5% on high-income earners without
#' adequate private hospital cover. Used in private health
#' insurance reform analysis.
#'
#' The ATO does not publish separate levy and surcharge workbooks,
#' so both `component` values return the same table; the argument
#' selects which columns are reported back to you. Version 0.1.0
#' resolved `component = "levy"` to Individuals Table 1, which has
#' no Medicare columns at all.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param component One of `"levy"` (default, standard Medicare
#'   Levy) or `"surcharge"` (MLS). Both return Table 3.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics
#'   Individuals. Licensed CC BY 2.5 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Medicare Levy Act 1986};
#'   \emph{A New Tax System (Medicare Levy Surcharge -- Fringe
#'   Benefits) Act 1999}.
#'
#' Productivity Commission (2015). \emph{Efficiency in Health}.
#'   Analysis of Medicare Levy and MLS distributional effects.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_medicare_levy(year = "2022-23", component = "surcharge"))
#' options(op)
#' }
ato_medicare_levy <- function(year = "latest",
                               component = c("levy", "surcharge")) {
  component <- match.arg(component)
  id <- ato_ts_package_id(year)
  res <- ato_ckan_resolve(id, c("individual03", "individual_03"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL

  wanted <- if (component == "surcharge") {
    "medicare_levy_surcharge"
  } else {
    "^medicare_levy(?!_surcharge)"
  }
  cols <- grep(wanted, names(df), value = TRUE, perl = TRUE)
  if (length(cols) == 0L) {
    cli::cli_warn(c(
      "No {.val {component}} columns found in Individuals Table 3 for {year}.",
      "i" = "Returning the full table; inspect {.code names()} yourself."
    ))
  } else {
    cli::cli_inform(c(
      "i" = "{component} columns in this table: {.val {cols}}."
    ))
  }
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO Medicare ", component, " ", year))
}
