# GST + industry aggregates

#' GST and activity statement ratios
#'
#' Returns the Taxation Statistics GST tables (T1-T5) or the
#' Activity Statement Ratios (A1-A5) for the requested year.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param table One of `"overview"` (default, GST T1), `"state"`
#'   (GST by state), `"industry"` (GST by ANZSIC), or
#'   `"ratios"` (Activity Statement Ratios).
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics.
#'   Licensed CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Taxation Statistics:
#'   GST and Activity Statement Ratios explanatory notes}.
#'
#' Commonwealth of Australia. \emph{A New Tax System (Goods and
#'   Services Tax) Act 1999}. Enabling legislation for the 10 per
#'   cent value-added tax introduced 1 July 2000.
#'
#' Productivity Commission (2018). \emph{Horizontal Fiscal
#'   Equalisation}. Background reference on the GST distribution
#'   formula across states.
#'
#' @family gst
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   g <- ato_gst(year = "2022-23", table = "industry")
#'   head(g)
#' })
#' options(op)
#' }
ato_gst <- function(year = "latest",
                    table = c("overview", "state", "industry", "ratios")) {
  table <- match.arg(table)
  id <- ato_ts_package_id(year)
  pattern <- switch(table,
    overview = "gst0?1|gst_01",
    state    = "gst0?[23]|gst_02|gst_03",
    industry = "gst0?[45]|gst_04|gst_05",
    ratios   = "activity.statement|ratio"
  )
  res <- ato_ckan_resolve(id, pattern)
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO GST ", year, " (", table, ")"))
}

#' Industry aggregates across entity types
#'
#' Derived helper that returns an ANZSIC industry breakdown based
#' on either individual, company, or all entities for the year.
#'
#' @param year `"YYYY-YY"` or `"latest"`.
#' @param entity One of `"individual"`, `"company"` (default), or
#'   `"all"`.
#' @param anzsic Optional substring filter on industry name.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics.
#'   Licensed CC BY 2.5 AU.
#'
#' @family gst
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   i <- ato_industry(year = "2022-23", entity = "company",
#'                     anzsic = "manufacturing")
#'   head(i)
#' })
#' options(op)
#' }
ato_industry <- function(year = "latest",
                          entity = c("company", "individual", "all"),
                          anzsic = NULL) {
  entity <- match.arg(entity)
  id <- ato_ts_package_id(year)

  fetch_one <- function(p) {
    res <- ato_ckan_resolve(id, p)
    url <- res$url %||% ""
    df <- ato_fetch_xlsx(url, sheet = 1)
    df$entity <- entity
    df
  }

  df <- switch(entity,
    company    = fetch_one("company04|company_04"),
    individual = fetch_one("individual(s)?05|individual_05"),
    all        = {
      c1 <- fetch_one("company04|company_04")
      i1 <- fetch_one("individual(s)?05|individual_05")
      common <- intersect(names(c1), names(i1))
      rbind(c1[, common, drop = FALSE], i1[, common, drop = FALSE])
    }
  )

  if (!is.null(anzsic)) {
    ind_col <- ato_find_col(df, "industry")
    if (!is.na(ind_col)) {
      ind_pattern <- paste(tolower(anzsic), collapse = "|")
      df <- df[grepl(ind_pattern, tolower(df[[ind_col]])), , drop = FALSE]
    }
  }
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = "https://data.gov.au/data/organization/australiantaxationoffice",
              licence = "CC BY 2.5 AU",
              title = paste0("ATO industry ", year, " (", entity, ")"))
}
