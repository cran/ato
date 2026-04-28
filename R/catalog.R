# Catalogue discovery + generic download

#' ATO dataset catalogue
#'
#' Returns a summary of all datasets published by the Australian
#' Taxation Office on data.gov.au. Each row is a CKAN "package"
#' with an id (slug), title, licence, modification date, and
#' resource count.
#'
#' @param q Optional free-text filter (CKAN Solr query). `NULL`
#'   returns the full ATO catalogue.
#'
#' @return An `ato_tbl` with one row per dataset.
#'
#' @source 'data.gov.au' CKAN endpoint
#'   <https://data.gov.au/data/organization/australiantaxationoffice>.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   cat <- ato_catalog()
#'   head(cat[, c("id", "title", "licence")])
#' })
#' options(op)
#' }
ato_catalog <- function(q = NULL) {
  result <- ato_ckan_search(q = q, rows = 200L)
  pkgs <- result$results
  df <- data.frame(
    id = vapply(pkgs, function(p) p$name %||% "", character(1)),
    title = vapply(pkgs, function(p) p$title %||% "", character(1)),
    notes = vapply(pkgs, function(p) substr(p$notes %||% "", 1L, 200L), character(1)),
    licence = vapply(pkgs, function(p) p$license_title %||% p$license_id %||% "", character(1)),
    n_resources = vapply(pkgs, function(p) length(p$resources %||% list()), integer(1)),
    modified = vapply(pkgs, function(p) p$metadata_modified %||% "", character(1)),
    stringsAsFactors = FALSE
  )
  df <- df[order(df$id), , drop = FALSE]
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = "https://data.gov.au/data/organization/australiantaxationoffice",
              licence = "CC BY 2.5 AU / 3.0 AU",
              title = "ATO data.gov.au catalogue")
}

#' Download a resource from an ATO dataset
#'
#' Low-level helper for arbitrary CKAN resources. Resolves the
#' package by id (slug) and picks the first resource matching
#' `pattern`, or the first resource if `pattern` is `NULL`.
#'
#' @param id CKAN package id (e.g. `"taxation-statistics-2022-23"`
#'   or `"corporate-transparency"`).
#' @param pattern Optional regex applied to the resource filename
#'   and name.
#' @param parse One of `"auto"` (default), `"csv"`, `"xlsx"`, or
#'   `"none"` (returns the cached file path).
#' @param sheet For XLSX resources: sheet index or name.
#'
#' @return Either a file path (`parse = "none"`) or an `ato_tbl`.
#'
#' @family discovery
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   cat <- ato_download("corporate-transparency",
#'                       pattern = "2023",
#'                       parse = "csv")
#' })
#' options(op)
#' }
ato_download <- function(id, pattern = NULL,
                         parse = c("auto", "csv", "xlsx", "none"),
                         sheet = 1) {
  parse <- match.arg(parse)
  res <- if (is.null(pattern)) {
    pkg <- ato_ckan_package(id)
    if (length(pkg$resources) == 0L) {
      cli::cli_abort("Package {.val {id}} has no resources.")
    }
    pkg$resources[[1L]]
  } else {
    ato_ckan_resolve(id, pattern)
  }

  url <- res$url %||% ""
  if (!nzchar(url)) cli::cli_abort("Resource has no URL.")

  format <- if (parse == "auto") {
    ext <- tolower(tools::file_ext(url))
    if (ext %in% c("csv", "tsv")) "csv" else if (ext %in% c("xls", "xlsx", "xlsm")) "xlsx" else "none"
  } else parse

  if (format == "none") return(ato_download_cached(url))

  df <- if (format == "csv") ato_fetch_csv(url) else ato_fetch_xlsx(url, sheet = sheet)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = res$license_id %||% "CC BY 2.5 AU",
              title = res$name %||% id)
}
