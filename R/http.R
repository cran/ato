# HTTP helpers : httr2 wrapper with local caching

#' @noRd
ato_user_agent <- function() {
  paste0("ato R package/", utils::packageVersion("ato"),
         " (+https://github.com/charlescoverdale/ato)")
}

#' @noRd
ato_request <- function(url, timeout = 120) {
  httr2::request(url) |>
    httr2::req_user_agent(ato_user_agent()) |>
    httr2::req_throttle(rate = 5 / 10) |>
    httr2::req_timeout(timeout) |>
    httr2::req_retry(max_tries = 3) |>
    httr2::req_error(is_error = function(r) FALSE)
}

#' Download a file to the cache and return the local path
#' @noRd
ato_download_cached <- function(url, cache = TRUE) {
  d <- ato_cache_dir()
  ext <- tools::file_ext(url)
  ext <- if (nzchar(ext)) paste0(".", ext) else ""
  file <- file.path(d, paste0(ato_digest_url(url), ext))

  if (cache && file.exists(file)) {
    # Verify SHA sidecar; warn on drift.
    ato_sha_verify(file)
    .ato_manifest_append(url = url, file = file)
    return(file)
  }

  cli::cli_progress_step("Downloading {.url {url}}")

  resp <- tryCatch(
    ato_request(url) |>
      httr2::req_perform(path = file),
    error = function(e) {
      if (file.exists(file)) unlink(file)
      cli::cli_abort(c(
        "Download failed.",
        "x" = conditionMessage(e)
      ))
    }
  )

  if (!is.null(resp) && httr2::resp_status(resp) >= 400L) {
    unlink(file, force = TRUE)
    cli::cli_abort(c(
      "HTTP {httr2::resp_status(resp)} from {.url {url}}."
    ))
  }

  # First download: write SHA sidecar, record in manifest.
  ato_sha_write(file)
  .ato_manifest_append(url = url, file = file)
  file
}

#' @noRd
ato_digest_url <- function(url) {
  tmp <- tempfile()
  on.exit(unlink(tmp))
  con <- file(tmp, open = "wb")
  writeLines(enc2utf8(url), con = con, sep = "")
  close(con)
  unname(tools::md5sum(tmp))
}
