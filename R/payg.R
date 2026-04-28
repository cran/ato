# PAYG Withholding

#' PAYG withholding data
#'
#' Returns the ATO's Pay As You Go (PAYG) withholding data:
#' employer counts, total withholding amounts, and employee counts
#' by industry and state. Used by researchers studying labour
#' market taxation, wage growth, and employer compliance.
#'
#' @param year Income year in `"YYYY-YY"` form (e.g. `"2022-23"`)
#'   or `"latest"`.
#'
#' @return An `ato_tbl`. Monetary values in nominal AUD.
#'
#' @source Australian Taxation Office PAYG withholding data
#'   on data.gov.au. Licensed CC BY 2.5 AU.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   payg <- ato_payg(year = "2022-23")
#'   head(payg)
#' })
#' options(op)
#' }
ato_payg <- function(year = "latest") {
  result   <- ato_ckan_search(q = "pay-as-you-go", rows = 10L)
  pkgs     <- result$results
  ids      <- vapply(pkgs, function(p) p$name %||% "", character(1))
  payg_ids <- ids[grepl("pay.as.you.go|payg.withholding", ids,
                          ignore.case = TRUE)]

  if (length(payg_ids) == 0L) {
    cli::cli_abort(c(
      "Could not find a PAYG withholding package on data.gov.au.",
      "i" = "Browse: {.url https://data.gov.au/data/organization/australiantaxationoffice}"
    ))
  }
  pkg_id <- payg_ids[1L]
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
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO PAYG withholding ", year))
}
