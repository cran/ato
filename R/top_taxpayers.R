# Corporate Tax Transparency

#' Corporate Tax Transparency
#'
#' Returns the ATO's annual Corporate Tax Transparency release,
#' mandated by Part 5-25 of the *Taxation Administration Act
#' 1953*. Covers every Australian public company, foreign-owned
#' company, or Australian-owned private company above the
#' AUD 100 million total-income threshold (the private-company
#' threshold was lowered from AUD 200 million to AUD 100 million
#' for the 2022-23 income year onwards, making all three
#' categories uniform). The 2023-24 release was published 1
#' October 2025 and covered 4,110 entities.
#'
#' The underlying XLSX has three sheets:
#' - **Information** (cover/metadata, ~7 rows).
#' - **Income tax details** (the headline dataset, ~4,000
#'   entities: total income, taxable income, tax payable).
#' - **PRRT details** (petroleum resource rent tax filers,
#'   typically 10-20 entities).
#'
#' Licensed under **CC BY 3.0 Australia** (the Corporate Tax
#' Transparency and Voluntary Tax Transparency Code releases use
#' CC BY 3.0 AU; most other Taxation Statistics use CC BY 2.5 AU).
#'
#' @param year `"YYYY-YY"` (e.g. `"2023-24"`) or `"latest"`.
#' @param entity_type One of `"all"` (default), `"public"`,
#'   `"private"`, or `"foreign"`. Matches the CTT `Entity type`
#'   column values `"Australian public"`, `"Australian private"`,
#'   `"Foreign-owned"`.
#' @param sheet One of `"income_tax"` (default, the ~4,000-entity
#'   income-tax sheet) or `"prrt"` (petroleum resource rent tax
#'   filers, typically 10-20 entities).
#'
#' @return An `ato_tbl` with one row per disclosed entity. All
#'   monetary values are nominal AUD of the reporting year.
#'
#' @source Australian Taxation Office Corporate Tax Transparency
#'   release. Licensed CC BY 3.0 AU.
#'
#' @references
#' Commonwealth of Australia. \emph{Taxation Administration Act
#'   1953}, Part 5-25 (Corporate Tax Transparency).
#'
#' Australian Taxation Office (annual). \emph{Report of entity
#'   tax information}. The statutory Corporate Tax Transparency
#'   release.
#'
#' Commonwealth Treasury (2013). \emph{Improving the transparency
#'   of Australia's business tax system: Exposure draft
#'   explanatory memorandum}. Rationale for the Part 5-25 regime.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   top <- ato_top_taxpayers(year = "2023-24")
#'   head(top)
#'   # Petroleum resource rent tax sheet
#'   prrt <- ato_top_taxpayers(year = "2023-24", sheet = "prrt")
#'   head(prrt)
#' })
#' options(op)
#' }
ato_top_taxpayers <- function(year = "latest",
                               entity_type = c("all", "public", "private", "foreign"),
                               sheet = c("income_tax", "prrt")) {
  entity_type <- match.arg(entity_type)
  sheet <- match.arg(sheet)

  pkg_id <- ATO_PACKAGE_IDS$ctt
  if (identical(year, "latest")) {
    pkg <- ato_ckan_package(pkg_id)
    resources <- pkg$resources %||% list()
    urls <- vapply(resources, function(r) r$url %||% "", character(1))
    years <- regmatches(urls, regexpr("20[0-9]{2}-[0-9]{2}", urls))
    year <- if (length(years) > 0L) max(years) else "2023-24"
  } else {
    year <- ato_resolve_year(year)
  }
  ato_check_staleness(pkg_id)
  res <- ato_ckan_resolve(pkg_id, year)
  url <- res$url %||% ""
  ext <- tolower(tools::file_ext(url))
  sheet_name <- switch(sheet,
    income_tax = "Income tax details",
    prrt       = "PRRT details"
  )
  sheet_fallback <- switch(sheet, income_tax = 2, prrt = 3)

  df <- if (ext == "csv") {
    ato_fetch_csv(url)
  } else {
    tryCatch(
      ato_fetch_xlsx(url, sheet = sheet_name),
      error = function(e) ato_fetch_xlsx(url, sheet = sheet_fallback)
    )
  }

  type_col <- ato_find_col(df, "entity")
  if (entity_type != "all" && !is.na(type_col)) {
    # CTT column values: "Australian public", "Australian private",
    # "Foreign-owned". Match the substantive token only.
    etype_pattern <- switch(entity_type,
      public  = "public",
      private = "private",
      foreign = "foreign"
    )
    df <- df[grepl(etype_pattern, tolower(df[[type_col]])), , drop = FALSE]
  }

  ato_warn_suppression(df, context = "CTT entity cells")

  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 3.0 AU",
              title   = paste0("ATO Corporate Tax Transparency ", year,
                               " (", sheet, ")"))
}
