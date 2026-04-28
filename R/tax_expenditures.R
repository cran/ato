# Treasury Tax Expenditures and Insights Statement (TEIS)

#' Tax Expenditures and Insights Statement (TEIS)
#'
#' Returns the Treasury TEIS annual table of concession-by-concession
#' tax expenditure estimates in AUD millions. TEIS is the
#' authoritative cost-of-concessions dataset used in PBO and Grattan
#' tax reform costings.
#'
#' TEIS is published by Treasury, not ATO; the function attempts a
#' CKAN search on data.gov.au for the TEIS release, and falls back
#' to the Treasury web URL if not indexed.
#'
#' Key concessions covered: CGT main residence exemption, CGT 50%
#' discount, superannuation earnings tax concession, franking credit
#' refundability, work-related deductions, fuel tax credit scheme,
#' R&D tax incentive, GST food exemption, and many more.
#'
#' @param year Reference year for the TEIS release, e.g. `"2024"`
#'   or `"latest"`. Treasury publishes one TEIS per calendar year.
#'
#' @return An `ato_tbl` with one row per tax expenditure: label,
#'   category, estimated revenue forgone in AUD millions by year.
#'
#' @source Treasury Tax Expenditures and Insights Statement
#'   \url{https://treasury.gov.au/publication/p2025-721342}.
#'
#' @references
#' Commonwealth of Australia (annual). \emph{Tax Expenditures
#'   and Insights Statement}. The Treasury, Canberra.
#'   \url{https://treasury.gov.au/publication/p2025-721342}
#'
#' @family specialist
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(head(ato_tax_expenditures("latest")))
#' options(op)
#' }
ato_tax_expenditures <- function(year = "latest") {
  results <- tryCatch(
    ato_ckan_search(q = "tax-expenditure", rows = 20L),
    error = function(e) list(results = list())
  )
  hit <- NULL
  if (!is.null(results$results) && length(results$results) > 0L) {
    for (p in results$results) {
      name <- p$name %||% ""
      if (grepl("tax.expenditure", name, ignore.case = TRUE)) {
        hit <- p
        break
      }
    }
  }
  if (is.null(hit)) {
    cli::cli_abort(c(
      "TEIS not found on data.gov.au.",
      "i" = "Fetch manually from {.url https://treasury.gov.au/publication/p2025-721342}",
      "i" = "then pass the URL to {.code ato_download()}."
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
              licence = "CC BY 4.0",
              title = paste0("Treasury TEIS ", year))
}
