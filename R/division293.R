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
#' Published as part of the Individuals Taxation Statistics
#' (Table 3b in recent releases).
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#'
#' @return An `ato_tbl`.
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
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_division293(year = "2022-23"))
#' options(op)
#' }
ato_division293 <- function(year = "latest") {
  id <- ato_ts_package_id(year)
  res <- tryCatch(
    ato_ckan_resolve(id, "division.?293|div.?293"),
    error = function(e) NULL
  )
  if (is.null(res)) {
    # Fallback: Table 3b "high-income super" pattern.
    res <- ato_ckan_resolve(id, "individual(s)?03|individual_03")
  }
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO Division 293 ", year))
}
