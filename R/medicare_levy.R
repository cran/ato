# Medicare Levy and Medicare Levy Surcharge (MLS)

#' Medicare Levy and Medicare Levy Surcharge
#'
#' Returns aggregate Medicare Levy and MLS data from Taxation
#' Statistics Individuals. The 2% Medicare Levy is on most
#' taxable income; MLS is an additional 1.0 to 1.5% on high-income
#' earners without adequate private hospital cover. Used in
#' private health insurance reform analysis.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param component One of `"levy"` (default, standard Medicare
#'   Levy) or `"surcharge"` (MLS).
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
  pattern <- if (component == "surcharge") {
    "medicare.levy.surcharge|mls|surcharge"
  } else {
    "medicare.levy|individual(s)?0[12]"
  }
  res <- ato_ckan_resolve(id, pattern)
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO Medicare ", component, " ", year))
}
