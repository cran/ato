# Voluntary Tax Transparency Code

#' Voluntary Tax Transparency Code disclosures
#'
#' Returns the ATO's Voluntary Tax Transparency Code (VTTC)
#' disclosures: large private companies that voluntarily publish
#' tax information beyond the Corporate Tax Transparency mandate.
#' Covers total income, taxable income, tax payable, and effective
#' tax rate for each disclosing entity.
#'
#' The VTTC complements [ato_top_taxpayers()] (which covers
#' mandatory CTT disclosures for entities above AUD 100m total
#' income). VTTC signatories may be below or above the CTT
#' threshold.
#'
#' Licensed under **CC BY 3.0 Australia** (same as CTT data).
#'
#' @param year Income year in `"YYYY-YY"` form (e.g. `"2022-23"`)
#'   or `"latest"`.
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD.
#'
#' @source Australian Taxation Office Voluntary Tax Transparency
#'   Code disclosures on data.gov.au. Licensed CC BY 3.0 AU.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   vttc <- ato_vttc(year = "2022-23")
#'   head(vttc)
#' })
#' options(op)
#' }
ato_vttc <- function(year = "latest") {
  # Try the constant slug first, then search as fallback.
  pkg_id <- tryCatch({
    ato_ckan_package(ATO_PACKAGE_IDS$vttc)
    ATO_PACKAGE_IDS$vttc
  }, error = function(e) {
    result   <- ato_ckan_search(q = "voluntary tax transparency", rows = 10L)
    pkgs     <- result$results
    ids      <- vapply(pkgs, function(p) p$name %||% "", character(1))
    vttc_ids <- ids[grepl("voluntary.tax.transparency|vttc", ids,
                            ignore.case = TRUE)]
    if (length(vttc_ids) == 0L) {
      cli::cli_abort(c(
        "Could not find a Voluntary Tax Transparency Code package.",
        "i" = "Browse: {.url https://data.gov.au/data/organization/australiantaxationoffice}"
      ))
    }
    vttc_ids[1L]
  })

  ato_check_staleness(pkg_id)

  if (identical(year, "latest")) {
    pkg  <- ato_ckan_package(pkg_id)
    urls <- vapply(pkg$resources %||% list(),
                   function(r) r$url %||% "", character(1))
    years <- regmatches(urls, regexpr("20[0-9]{2}-[0-9]{2}", urls))
    year  <- if (length(years) > 0L) max(years) else "2022-23"
  } else {
    year <- ato_resolve_year(year)
  }

  res <- ato_ckan_resolve(pkg_id, year)
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 3.0 AU",
              title   = paste0("ATO VTTC disclosures ", year))
}
