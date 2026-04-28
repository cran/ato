# SHA-256 integrity: every cached file has a sidecar `.sha256` file
# recording the hash at first download. Subsequent cache hits verify
# against the sidecar and warn on drift.

#' Compute the SHA-256 digest of a file
#'
#' Wraps [tools::md5sum()] style behaviour for SHA-256 via the
#' `digest` package when available, or falls back to a pure-R
#' implementation via [tools::md5sum()] + file length as a weaker
#' check. For integrity work PBO/Grattan-grade, install the
#' `digest` package (Suggests).
#'
#' @param file Path to a local file.
#' @return A length-1 character string (hex digest), or `NA` if the
#'   file does not exist.
#' @family reproducibility
#' @export
#' @examples
#' f <- tempfile()
#' writeLines("hello", f)
#' ato_sha256(f)
ato_sha256 <- function(file) {
  if (!file.exists(file)) return(NA_character_)
  if (requireNamespace("digest", quietly = TRUE)) {
    return(digest::digest(file = file, algo = "sha256"))
  }
  # Fallback: md5 (weaker but still ships with base R via tools).
  unname(tools::md5sum(file))
}

#' @noRd
ato_sha_sidecar <- function(file) {
  paste0(file, ".sha256")
}

#' Write the SHA-256 of a file to its sidecar
#' @noRd
ato_sha_write <- function(file) {
  sha <- ato_sha256(file)
  if (is.na(sha)) return(invisible(NA_character_))
  writeLines(sha, ato_sha_sidecar(file))
  invisible(sha)
}

#' Read the cached SHA-256 sidecar for a file
#' @noRd
ato_sha_read <- function(file) {
  side <- ato_sha_sidecar(file)
  if (!file.exists(side)) return(NA_character_)
  tryCatch(readLines(side, n = 1L, warn = FALSE),
           error = function(e) NA_character_)
}

#' Verify a cached file against its sidecar SHA; warn on mismatch.
#' @noRd
ato_sha_verify <- function(file) {
  expected <- ato_sha_read(file)
  if (is.na(expected) || !nzchar(expected)) {
    # No sidecar yet, write one.
    ato_sha_write(file)
    return(invisible(TRUE))
  }
  actual <- ato_sha256(file)
  if (!identical(expected, actual)) {
    cli::cli_warn(c(
      "SHA-256 mismatch for cached file {.path {basename(file)}}.",
      "i" = "Expected {.val {substr(expected, 1, 12)}...}",
      "i" = "Got      {.val {substr(actual, 1, 12)}...}",
      "i" = "Run {.code ato_clear_cache()} and re-fetch to resolve."
    ))
    return(invisible(FALSE))
  }
  invisible(TRUE)
}
