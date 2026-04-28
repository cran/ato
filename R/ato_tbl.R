# ato_tbl S3 class with provenance header

#' @noRd
new_ato_tbl <- function(df, source = NULL, licence = "CC BY 2.5 AU",
                        retrieved = Sys.time(), title = NULL,
                        sha256 = NA_character_,
                        snapshot_date = ato_snapshot_str()) {
  stopifnot(is.data.frame(df))
  # If source is a URL already in cache, lift the sha256 sidecar for free.
  if (is.na(sha256) && !is.null(source) && nzchar(source)) {
    d <- tryCatch(ato_cache_dir(), error = function(e) NULL)
    if (!is.null(d)) {
      ext <- tools::file_ext(source)
      ext <- if (nzchar(ext)) paste0(".", ext) else ""
      f <- file.path(d, paste0(ato_digest_url(source), ext))
      if (file.exists(f)) sha256 <- ato_sha_read(f)
    }
  }
  attr(df, "ato_source") <- source
  attr(df, "ato_licence") <- licence
  attr(df, "ato_retrieved") <- retrieved
  attr(df, "ato_title") <- title
  attr(df, "ato_sha256") <- sha256
  attr(df, "ato_snapshot_date") <- snapshot_date
  class(df) <- c("ato_tbl", class(df))
  df
}

#' Print an ato_tbl
#'
#' Prints a provenance header (title, source, licence, retrieval
#' time, dimensions) followed by the data frame.
#'
#' @param x An `ato_tbl` object.
#' @param ... Passed to the next print method.
#' @return Invisibly returns `x`.
#' @export
#' @examples
#' x <- data.frame(postcode = "2000", taxable_income = 82000)
#' x <- structure(x, ato_title = "Demo", ato_source = "https://data.gov.au",
#'                ato_licence = "CC BY 2.5 AU", ato_retrieved = Sys.time(),
#'                class = c("ato_tbl", "data.frame"))
#' print(x)
print.ato_tbl <- function(x, ...) {
  title <- attr(x, "ato_title") %||% "ATO data"
  source <- attr(x, "ato_source") %||% "https://data.gov.au"
  licence <- attr(x, "ato_licence") %||% "CC BY 2.5 AU"
  retrieved <- attr(x, "ato_retrieved")
  retrieved_str <- if (!is.null(retrieved)) {
    format(retrieved, "%Y-%m-%d %H:%M %Z")
  } else {
    "-"
  }

  sha <- attr(x, "ato_sha256")
  snap <- attr(x, "ato_snapshot_date")
  cat("# ato_tbl: ", title, "\n", sep = "")
  cat("# Source:   ", source, "\n", sep = "")
  cat("# Licence:  ", licence, "\n", sep = "")
  cat("# Retrieved:", retrieved_str, "\n")
  if (!is.null(snap) && !is.na(snap)) {
    cat("# Snapshot: ", snap, "\n", sep = "")
  }
  if (!is.null(sha) && !is.na(sha) && nzchar(sha)) {
    cat("# SHA-256:  ", substr(sha, 1, 16), "...\n", sep = "")
  }
  cat("# Rows: ", formatC(nrow(x), big.mark = ",", format = "d"),
      "  Cols: ", ncol(x), "\n", sep = "")
  cat("\n")

  y <- x
  class(y) <- setdiff(class(y), "ato_tbl")
  print(y, ...)
  invisible(x)
}
