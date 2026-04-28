# Company Taxation Statistics

#' Company Taxation Statistics
#'
#' Returns the annual Company Taxation Statistics tables. The
#' Company release ships tables covering entity type, turnover
#' band, industry, taxable status, source of income, and
#' expense deductions. Pick the table that matches your
#' question:
#'
#' - **snapshot** (T1): aggregate counts, total income, net tax
#'   across all companies (~1m entities)
#' - **key_items_by_size** (T2): net tax by company size band
#' - **entity_type** (T3): split by public/private/co-operative
#' - **industry** (T4, default): key items by 2-digit ANZSIC
#'   subdivision
#' - **industry_by_size** (T5): industry x turnover band
#' - **sub_industry** (T6): 4-digit ANZSIC class detail
#' - **taxable_status** (T7): items by taxable status
#' - **source** (T8): source of income
#' - **expenses** (T9): expense and deduction categories
#'
#' **Classification break.** Releases from 2022-23 onwards use
#' ANZSIC 2020; earlier releases use ANZSIC 2006. A warning is
#' emitted when the requested year(s) are at or after this boundary,
#' or when a multi-year request spans it.
#'
#' @param year `"YYYY-YY"`, `"latest"`, or a vector of years for
#'   a multi-year panel. Multi-year requests add a `year` column.
#' @param table One of `"snapshot"`, `"key_items_by_size"`,
#'   `"entity_type"`, `"industry"` (default), `"industry_by_size"`,
#'   `"sub_industry"`, `"taxable_status"`, `"source"`, or
#'   `"expenses"`.
#' @param industry Optional substring filter on industry name
#'   (applied only when the fetched table has an industry column).
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD of the
#'   reporting year.
#'
#' @source Australian Taxation Office Taxation Statistics Company
#'   Tables. Licensed CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Taxation Statistics:
#'   Company tables explanatory notes}. Methodology notes on
#'   lodgement cut-off, entity-type definitions, and turnover-band
#'   thresholds. Accessible from
#'   \url{https://www.ato.gov.au/about-ato/research-and-statistics/in-detail/taxation-statistics/}.
#'
#' Australian Bureau of Statistics (2020). \emph{Australian and
#'   New Zealand Standard Industrial Classification (ANZSIC)},
#'   2006 revision with 2020 update. Catalogue 1292.0.
#'
#' @family companies
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   s <- ato_companies(year = "2022-23", table = "snapshot")
#'   head(s)
#'   m <- ato_companies(year = "2022-23", industry = "mining")
#'   head(m)
#'   # Multi-year industry panel
#'   panel <- ato_companies(year = c("2021-22", "2022-23"))
#' })
#' options(op)
#' }
ato_companies <- function(year = "latest",
                           table = c("industry",
                                     "snapshot",
                                     "key_items_by_size",
                                     "entity_type",
                                     "industry_by_size",
                                     "sub_industry",
                                     "taxable_status",
                                     "source",
                                     "expenses"),
                           industry = NULL) {
  table <- match.arg(table)

  # Multi-year path
  if (length(year) > 1L) {
    resolved <- vapply(as.list(year), ato_resolve_year, character(1))
    if (table %in% c("industry", "industry_by_size", "sub_industry")) {
      ato_warn_classification_span(resolved, "anzsic")
    }
    fn <- function(year) {
      ato_companies(year = year, table = table, industry = industry)
    }
    return(ato_stack_years(fn, resolved,
                           title_prefix = paste0("ATO companies (", table, ")")))
  }

  id <- ato_ts_package_id(year)
  resolved_year <- sub("taxation-statistics-", "", id)

  if (table %in% c("industry", "industry_by_size", "sub_industry")) {
    ato_warn_classification_break(resolved_year, "anzsic")
  }

  pattern <- switch(table,
    snapshot          = "company01|company_01",
    key_items_by_size = "company02|company_02",
    entity_type       = "company03|company_03",
    industry          = "company04|company_04|company.*industry",
    industry_by_size  = "company05|company_05",
    sub_industry      = "company06|company_06",
    taxable_status    = "company07|company_07",
    source            = "company08|company_08",
    expenses          = "company09|company_09"
  )
  res <- ato_ckan_resolve(id, pattern)
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)

  ind_col <- ato_find_col(df, "industry")
  if (!is.null(industry) && !is.na(ind_col)) {
    ind_pattern <- paste(tolower(industry), collapse = "|")
    df <- df[grepl(ind_pattern, tolower(df[[ind_col]])), , drop = FALSE]
  }
  if (!is.null(industry) && nrow(df) == 0L) {
    cli::cli_warn("No industry rows matched {.val {industry}}.")
  }

  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO companies ", year, " (", table, ")"))
}
