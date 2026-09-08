# International benchmarking via OECD Revenue Statistics.

#' OECD Revenue Statistics comparison
#'
#' Fetches OECD Revenue Statistics for cross-country tax-to-GDP
#' benchmarking. Returns tax revenue as percent of GDP by tax
#' category. Use to contextualise Australian ATO aggregates in
#' cross-country policy arguments (e.g. OECD average corporate
#' tax-to-GDP, international ranks for personal income tax).
#'
#' Thin wrapper pointing users to `readoecd::` for full OECD API
#' access; returns a minimal tax-to-GDP slice here for convenience.
#'
#' **Data vintage.** The bundled headline ratios are hardcoded and
#' currently run to 2023 (Australia reports to the OECD a year
#' behind most members). They are not refreshed automatically. For
#' anything load-bearing use `readoecd::` against the live OECD
#' Data Explorer rather than this convenience slice.
#'
#' @param country Country ISO code or name (default `"AUS"`).
#' @param year Four-digit year or `"latest"`.
#'
#' @return An `ato_tbl` with columns `country`, `year`, `tax`,
#'   `pct_gdp`.
#'
#' @source OECD Revenue Statistics 2025
#'   <https://www.oecd.org/en/publications/revenue-statistics-2025_3a264267-en.html>.
#'   The former `oecd.org/tax/tax-policy/revenue-statistics.htm`
#'   landing page now returns HTTP 410.
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_international(country = "AUS"))
#' options(op)
#' }
ato_international <- function(country = "AUS", year = "latest") {
  cli::cli_inform(c(
    "i" = "For full OECD Revenue Statistics access, install {.pkg readoecd}.",
    "i" = "This wrapper returns bundled headline tax-to-GDP ratios only."
  ))
  # Bundled headline ratios for common years (OECD published values).
  headline <- data.frame(
    country = c("AUS", "AUS", "AUS", "OECD_AVG", "OECD_AVG"),
    year    = c("2021", "2022", "2023", "2022", "2023"),
    tax     = c("total", "total", "total", "total", "total"),
    pct_gdp = c(29.5, 29.4, 29.4, 33.9, 34.0),
    stringsAsFactors = FALSE
  )
  out <- headline[headline$country == country, , drop = FALSE]
  if (year != "latest") {
    out <- out[out$year == year, , drop = FALSE]
  }
  if (nrow(out) == 0L) {
    cli::cli_warn("No OECD data bundled for {.val {country}} {.val {year}}.")
  }
  new_ato_tbl(out,
              source = paste0("https://www.oecd.org/en/publications/",
                              "revenue-statistics-2025_3a264267-en.html"),
              licence = "OECD terms",
              title = paste0("OECD tax-to-GDP ", country, " ", year))
}
