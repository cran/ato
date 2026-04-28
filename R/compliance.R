# ATO compliance and debt book: audit yield, debt under dispute,
# collectable debt. Key integrity indicators.

#' ATO compliance program outcomes
#'
#' Returns the ATO's annual compliance program outcomes: audit
#' yield (tax raised from audits), settled disputes, collectable
#' debt, and compliance cost recovery. These appear in the ATO
#' annual report and related data.gov.au releases.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param metric One of `"overview"` (default), `"debt"`
#'   (collectable vs insolvency vs disputed), or `"audit"`
#'   (liabilities raised by program area).
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office annual report data.
#'   Licensed CC BY 3.0 AU.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_compliance(year = "2022-23", metric = "debt"))
#' options(op)
#' }
ato_compliance <- function(year = "latest",
                            metric = c("overview", "debt", "audit")) {
  metric <- match.arg(metric)
  results <- tryCatch(
    ato_ckan_search(q = "compliance+OR+annual-report", rows = 50L),
    error = function(e) list(results = list())
  )
  pattern <- switch(metric,
    overview = "compliance.*overview|annual.report",
    debt     = "debt|collectable",
    audit    = "audit|liabilit"
  )
  hit <- NULL
  if (!is.null(results$results)) {
    for (p in results$results) {
      name <- p$name %||% ""
      if (grepl(pattern, name, ignore.case = TRUE)) {
        hit <- p
        break
      }
    }
  }
  if (is.null(hit)) {
    cli::cli_abort(c(
      "No compliance dataset found for metric {.val {metric}}.",
      "i" = "Try {.code ato_catalog()} to browse available datasets."
    ))
  }
  res <- hit$resources[[1L]]
  url <- res$url %||% ""
  df <- if (grepl("\\.csv$", url, ignore.case = TRUE)) {
    ato_fetch_csv(url)
  } else {
    ato_fetch_xlsx(url, sheet = 1)
  }
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 3.0 AU",
              title = paste0("ATO compliance ", year, " (", metric, ")"))
}
