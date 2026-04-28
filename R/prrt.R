# Petroleum Resource Rent Tax (PRRT).

#' Petroleum Resource Rent Tax (PRRT) annual data
#'
#' Returns PRRT revenue and assessments. PRRT is a 40% tax on the
#' profits of offshore petroleum projects; revenues are volatile
#' and project-specific. Key dataset for resource-tax reform
#' analysis.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics Company.
#'   Licensed CC BY 2.5 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Petroleum Resource Rent Tax
#'   Assessment Act 1987}. Enabling legislation for the 40 per
#'   cent rent tax on offshore petroleum projects.
#'
#' Callaghan, M. (2017). \emph{Review of the Petroleum Resource
#'   Rent Tax}. Treasury-commissioned review; reference for
#'   PRRT-reform analysis.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_prrt(year = "2022-23"))
#' options(op)
#' }
ato_prrt <- function(year = "latest") {
  id <- ato_ts_package_id(year)
  res <- ato_ckan_resolve(id, "prrt|petroleum.resource.rent")
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
              title = paste0("ATO PRRT ", year))
}
