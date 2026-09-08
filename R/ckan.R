# CKAN API wrapper for data.gov.au

#' @noRd
CKAN_BASE <- "https://data.gov.au/data/api/3/action"

#' @noRd
ATO_ORG <- "australiantaxationoffice"

#' Query the CKAN package_search endpoint for ATO packages
#'
#' The org filter and the caller's query terms are joined with a
#' space, not a `+`. `URLencode(reserved = TRUE)` percent-encodes
#' `+` as `%2B`, which Solr reads as a literal character rather
#' than a term separator, so every filtered search returned zero
#' results. A space encodes to `%20` and separates the terms.
#'
#' @param q Additional query string (joined with a space to the org filter).
#' @param rows Max rows to return per page.
#' @return Parsed list with `count` and `results` (list of packages).
#' @noRd
ato_ckan_search_url <- function(q = NULL, rows = 200L) {
  query <- paste0("organization:", ATO_ORG)
  if (!is.null(q) && nzchar(q)) query <- paste0(query, " ", q)
  sprintf("%s/package_search?q=%s&rows=%d",
          CKAN_BASE, utils::URLencode(query, reserved = TRUE), rows)
}

#' @noRd
ato_ckan_search <- function(q = NULL, rows = 200L) {
  url <- ato_ckan_search_url(q = q, rows = rows)
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

#' Resolve a resource in a package by filename regex
#'
#' `pattern` may be a character vector. Patterns are tried in
#' order and the first one that matches any resource wins, so
#' callers can put a precise anchor (e.g. `"individual06"`) ahead
#' of a loose fallback (e.g. `"postcode"`) for older releases that
#' used a different filename convention.
#'
#' Within a single pattern the first matching resource in package
#' order is returned. That ordering is why `exclude` exists: the
#' Snapshot workbooks sit at positions 2 to 8 of a Taxation
#' Statistics package and their filenames carry words like
#' "postcode" and "occupation", so they shadow the detailed
#' Individuals tables at positions 20 to 47.
#'
#' @param package_id CKAN package slug.
#' @param pattern Character vector of regexes, in priority order.
#' @param exclude Optional regex; resources matching it are removed
#'   from consideration before any pattern is tried.
#' @noRd
ato_ckan_resolve <- function(package_id, pattern, exclude = NULL) {
  pkg <- ato_ckan_package(package_id)
  resources <- pkg$resources
  if (is.null(resources) || length(resources) == 0L) {
    cli::cli_abort("Package {.val {package_id}} has no resources.")
  }
  urls <- vapply(resources, function(r) r$url %||% "", character(1))
  names_v <- vapply(resources, function(r) r$name %||% r$url %||% "", character(1))

  eligible <- rep(TRUE, length(resources))
  if (!is.null(exclude) && nzchar(exclude)) {
    eligible <- !(grepl(exclude, urls, ignore.case = TRUE) |
                    grepl(exclude, names_v, ignore.case = TRUE))
  }

  for (p in pattern) {
    hit <- eligible &
      (grepl(p, urls, ignore.case = TRUE) |
         grepl(p, names_v, ignore.case = TRUE))
    if (any(hit)) return(resources[[which(hit)[1L]]])
  }

  cli::cli_abort(c(
    "No resource in {.val {package_id}} matches {.val {pattern}}.",
    "i" = "Available: {.val {names_v}}"
  ))
}
