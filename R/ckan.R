# CKAN API wrapper for data.gov.au

#' @noRd
CKAN_BASE <- "https://data.gov.au/data/api/3/action"

#' @noRd
ATO_ORG <- "australiantaxationoffice"

#' Query the CKAN package_search endpoint for ATO packages
#'
#' @param q Additional query string (joined with `+` to the org filter).
#' @param rows Max rows to return per page.
#' @return Parsed list with `count` and `results` (list of packages).
#' @noRd
ato_ckan_search <- function(q = NULL, rows = 200L) {
  query <- paste0("organization:", ATO_ORG)
  if (!is.null(q) && nzchar(q)) query <- paste0(query, "+", q)
  url <- sprintf("%s/package_search?q=%s&rows=%d",
                 CKAN_BASE, utils::URLencode(query, reserved = TRUE), rows)
  resp <- ato_request(url) |>
    httr2::req_perform()
  if (httr2::resp_status(resp) != 200L) {
    cli::cli_abort("CKAN search failed (HTTP {httr2::resp_status(resp)}).")
  }
  body <- httr2::resp_body_string(resp)
  parsed <- jsonlite::fromJSON(body, simplifyVector = FALSE)
  if (!isTRUE(parsed$success)) {
    cli::cli_abort("CKAN search returned success = FALSE.")
  }
  parsed$result
}

#' Fetch a single CKAN package by id (slug).
#' @noRd
ato_ckan_package <- function(id) {
  url <- sprintf("%s/package_show?id=%s",
                 CKAN_BASE, utils::URLencode(id, reserved = TRUE))
  resp <- ato_request(url) |>
    httr2::req_perform()
  if (httr2::resp_status(resp) != 200L) {
    cli::cli_abort("Package not found: {.val {id}}.")
  }
  body <- httr2::resp_body_string(resp)
  parsed <- jsonlite::fromJSON(body, simplifyVector = FALSE)
  if (!isTRUE(parsed$success)) {
    cli::cli_abort("CKAN package_show returned success = FALSE.")
  }
  parsed$result
}

#' Resolve the first resource in a package that matches a filename regex.
#' @noRd
ato_ckan_resolve <- function(package_id, pattern) {
  pkg <- ato_ckan_package(package_id)
  resources <- pkg$resources
  if (is.null(resources) || length(resources) == 0L) {
    cli::cli_abort("Package {.val {package_id}} has no resources.")
  }
  urls <- vapply(resources, function(r) r$url %||% "", character(1))
  names_v <- vapply(resources, function(r) r$name %||% r$url %||% "", character(1))
  hit <- grepl(pattern, urls, ignore.case = TRUE) |
    grepl(pattern, names_v, ignore.case = TRUE)
  if (!any(hit)) {
    cli::cli_abort(c(
      "No resource in {.val {package_id}} matches {.val {pattern}}.",
      "i" = "Available: {.val {names_v}}"
    ))
  }
  resources[[which(hit)[1L]]]
}
