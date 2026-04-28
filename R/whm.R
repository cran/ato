# Working Holiday Maker (WHM) tax aggregates

#' Working Holiday Maker tax data
#'
#' Returns aggregate Working Holiday Maker tax data: number of
#' backpackers, total earnings, tax paid. Relevant for migration
#' and labour-market policy analysis.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#'
#' @return An `ato_tbl`.
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
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_whm(year = "2022-23"))
#' options(op)
#' }
ato_whm <- function(year = "latest") {
  id <- ato_ts_package_id(year)
  res <- ato_ckan_resolve(id, "working.holiday.maker|whm|backpacker")
  url <- res$url %||% ""
  df <- if (grepl("\\.csv$", url, ignore.case = TRUE)) {
    ato_fetch_csv(url)
  } else {
    ato_fetch_xlsx(url, sheet = 1)
  }
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO Working Holiday Maker ", year))
}
