# Session-level manifest: every fetch appends a row recording the
# dataset URL, resource UUID (if known), SHA-256, retrieval time,
# snapshot pin, and any dataset title. ato_manifest() returns the
# full record for attachment to a paper appendix or deposit to
# Zenodo for DOI minting.

#' @noRd
.ato_manifest_append <- function(url, file = NA_character_,
                                  title = NA_character_,
                                  resource_id = NA_character_,
                                  package_id = NA_character_,
                                  licence = NA_character_) {
  sha <- if (!is.na(file) && file.exists(file)) ato_sha256(file) else NA_character_
  size <- if (!is.na(file) && file.exists(file)) {
    as.numeric(file.info(file)$size)
  } else {
    NA_real_
  }
  row <- data.frame(
    url            = url,
    title          = title,
    resource_id    = resource_id,
    package_id     = package_id,
    licence        = licence,
    sha256         = sha,
    size_bytes     = size,
    retrieved      = format(Sys.time(), "%Y-%m-%dT%H:%M:%S%z"),
    snapshot_date  = ato_snapshot_str(),
    r_version      = as.character(getRversion()),
    ato_version    = as.character(utils::packageVersion("ato")),
    stringsAsFactors = FALSE
  )
  key <- url
  existing <- .ato_env$manifest %||% list()
  existing[[key]] <- row
  .ato_env$manifest <- existing
  invisible(row)
}

#' Return the session manifest of fetched ATO datasets
#'
#' Every call to a data function (`ato_individuals()`,
#' `ato_companies()`, etc.) appends one row to the session
#' manifest, recording URL, dataset title, CKAN resource and
#' package IDs where resolvable, SHA-256 of the cached file,
#' size, retrieval timestamp, and the snapshot pin set via
#' [ato_snapshot()]. Duplicate URLs within a session are
#' deduplicated (last fetch wins).
#'
#' Attach the output to your paper's appendix, deposit it to
#' Zenodo with [ato_deposit_zenodo()] to mint a DOI, or export
#' with [ato_manifest_write()] for CI artefacts.
#'
#' @param format One of `"df"` (default, tidy data frame),
#'   `"yaml"`, or `"json"`.
#'
#' @return A data frame, YAML string, or JSON string depending on
#'   `format`.
#' @family reproducibility
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' ato_manifest_clear()
#' ato_snapshot("2026-04-24")
#' try(ato_individuals(year = "2022-23"))
#' ato_manifest()
#' options(op)
#' }
ato_manifest <- function(format = c("df", "yaml", "json")) {
  format <- match.arg(format)
  rows <- .ato_env$manifest %||% list()
  if (length(rows) == 0L) {
    df <- data.frame(
      url = character(0), title = character(0),
      resource_id = character(0), package_id = character(0),
      licence = character(0), sha256 = character(0),
      size_bytes = numeric(0), retrieved = character(0),
      snapshot_date = character(0), r_version = character(0),
      ato_version = character(0),
      stringsAsFactors = FALSE
    )
  } else {
    df <- do.call(rbind, rows)
    rownames(df) <- NULL
  }
  if (format == "df") return(df)
  if (format == "json") {
    return(jsonlite::toJSON(df, pretty = TRUE, auto_unbox = TRUE,
                            na = "null"))
  }
  # YAML path: build by hand (no yaml dep).
  ato_to_yaml(df)
}

#' Clear the session manifest
#'
#' @return Invisibly `NULL`. Useful at the top of a script when
#'   running repeatedly.
#' @family reproducibility
#' @export
#' @examples
#' ato_manifest_clear()
ato_manifest_clear <- function() {
  .ato_env$manifest <- list()
  invisible(NULL)
}

#' Write the session manifest to a file
#'
#' Writes the manifest to a file in the requested format. Call
#' at the end of an analysis script; commit the manifest
#' alongside the paper for full reproducibility.
#'
#' @param path Output file path. Extension determines format if
#'   `format = "auto"`: `.csv` to CSV, `.yaml`/`.yml` to YAML,
#'   `.json` to JSON.
#' @param format One of `"auto"` (infer from extension), `"csv"`,
#'   `"yaml"`, or `"json"`.
#'
#' @return Invisibly, the absolute path to the written file.
#' @family reproducibility
#' @export
#' @examples
#' \donttest{
#' p <- tempfile(fileext = ".csv")
#' ato_manifest_clear()
#' ato_manifest_write(p)
#' }
ato_manifest_write <- function(path,
                                format = c("auto", "csv", "yaml", "json")) {
  format <- match.arg(format)
  if (format == "auto") {
    ext <- tolower(tools::file_ext(path))
    format <- switch(ext,
      csv = "csv",
      yaml = "yaml", yml = "yaml",
      json = "json",
      "csv"
    )
  }
  if (format == "csv") {
    utils::write.csv(ato_manifest("df"), path, row.names = FALSE)
  } else if (format == "yaml") {
    writeLines(ato_manifest("yaml"), path)
  } else {
    writeLines(ato_manifest("json"), path)
  }
  invisible(normalizePath(path, mustWork = FALSE))
}

#' Minimal YAML writer for data frames (avoids a yaml package dep)
#' @noRd
ato_to_yaml <- function(df) {
  if (nrow(df) == 0L) return("# empty manifest\n")
  entries <- vapply(seq_len(nrow(df)), function(i) {
    lines <- vapply(names(df), function(k) {
      v <- df[i, k, drop = TRUE]
      v <- if (is.na(v)) "null" else {
        s <- as.character(v)
        # quote if contains YAML-special chars
        if (grepl("[:#\\-\\[\\]{}!&*]|^ | $", s)) {
          paste0("\"", gsub("\"", "\\\"", s, fixed = TRUE), "\"")
        } else {
          s
        }
      }
      sprintf("  %s: %s", k, v)
    }, character(1))
    paste0("- ", sub("^  ", "", lines[1]), "\n",
           paste(lines[-1], collapse = "\n"))
  }, character(1))
  paste(entries, collapse = "\n")
}
