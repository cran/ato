# Citation helper

#' Cite an ato_tbl (or URL) in BibTeX and plain-text form
#'
#' Returns a citation suitable for footnotes, papers, and
#' Treasury-grade briefs. Uses the provenance attributes
#' attached to every `ato_tbl`: source URL, licence, retrieval
#' date, title, snapshot pin, and SHA-256 digest.
#'
#' BibTeX output includes the SHA-256 digest (first 12 hex chars)
#' and snapshot pin (when set via [ato_snapshot()]) in the
#' `note` field, which is what research reviewers need to verify
#' the provenance of a downstream result.
#'
#' @param x Either an `ato_tbl` (as returned by any `ato_*` data
#'   function) or a character URL pointing to an ATO data.gov.au
#'   resource.
#' @param style One of `"text"` (default, plain-text footnote),
#'   `"bibtex"`, or `"apa"`.
#' @param doi Optional DOI (e.g. from [ato_deposit_zenodo()]) to
#'   include in BibTeX output as a `doi` field and APA suffix.
#'
#' @return A character string. For `style = "bibtex"`, a complete
#'   `@misc{}` entry.
#'
#' @family discovery
#' @export
#' @examples
#' x <- data.frame(a = 1)
#' x <- structure(x,
#'   ato_source = "https://data.gov.au/data/dataset/example.xlsx",
#'   ato_licence = "CC BY 2.5 AU",
#'   ato_retrieved = as.POSIXct("2026-04-23 00:00:00", tz = "UTC"),
#'   ato_title = "ATO individuals 2022-23",
#'   ato_sha256 = "abc123def456",
#'   ato_snapshot_date = "2026-04-23",
#'   class = c("ato_tbl", "data.frame"))
#'
#' ato_cite(x)
#' ato_cite(x, style = "bibtex")
#' # DOI style: supply any minted DOI (Zenodo, DataCite, etc.).
#' # The placeholder below is illustrative only.
#' ato_cite(x, style = "apa", doi = "10.5281/zenodo.XXXXXXXX")
ato_cite <- function(x, style = c("text", "bibtex", "apa"),
                      doi = NULL) {
  style <- match.arg(style)

  if (is.character(x) && length(x) == 1L) {
    src <- x
    licence <- "CC BY 2.5 AU"
    retrieved <- Sys.time()
    title <- basename(x)
    sha <- NA_character_
    snap <- NA_character_
  } else if (inherits(x, "ato_tbl")) {
    src <- attr(x, "ato_source") %||% ""
    licence <- attr(x, "ato_licence") %||% "CC BY 2.5 AU"
    retrieved <- attr(x, "ato_retrieved") %||% Sys.time()
    title <- attr(x, "ato_title") %||% "ATO data"
    sha <- attr(x, "ato_sha256") %||% NA_character_
    snap <- attr(x, "ato_snapshot_date") %||% NA_character_
  } else {
    cli::cli_abort(
      "{.arg x} must be an {.cls ato_tbl} or a character URL."
    )
  }

  date_str <- format(as.Date(retrieved), "%Y-%m-%d")
  year <- format(as.Date(retrieved), "%Y")
  sha_str <- if (!is.na(sha) && nzchar(sha)) substr(sha, 1, 12) else ""
  snap_str <- if (!is.na(snap) && nzchar(snap)) snap else ""

  note_parts <- c(
    sprintf("Retrieved %s", date_str),
    sprintf("licensed under %s", licence)
  )
  if (nzchar(snap_str)) note_parts <- c(note_parts,
                                         sprintf("snapshot %s", snap_str))
  if (nzchar(sha_str)) note_parts <- c(note_parts,
                                        sprintf("sha256:%s", sha_str))
  note <- paste(note_parts, collapse = "; ")

  doi_line <- if (!is.null(doi) && nzchar(doi)) {
    sprintf("  doi    = {%s},\n", doi)
  } else {
    ""
  }

  switch(style,
    text = {
      s <- sprintf(
        "Australian Taxation Office. %s. Retrieved %s from %s. Licensed under %s.",
        title, date_str, src, licence
      )
      if (nzchar(snap_str)) s <- paste0(s, " Snapshot: ", snap_str, ".")
      if (nzchar(sha_str)) s <- paste0(s, " SHA-256: ", sha_str, ".")
      if (!is.null(doi) && nzchar(doi)) s <- paste0(s, " DOI: ", doi, ".")
      s
    },
    apa = {
      s <- sprintf(
        "Australian Taxation Office. (%s). %s [Data set]. data.gov.au. %s",
        year, title, src
      )
      if (!is.null(doi) && nzchar(doi)) s <- paste0(s, " https://doi.org/", doi)
      s
    },
    bibtex = sprintf(
      paste0(
        "@misc{ato_%s,\n",
        "  author = {{Australian Taxation Office}},\n",
        "  title  = {{%s}},\n",
        "  year   = {%s},\n",
        "%s",
        "  note   = {%s},\n",
        "  url    = {%s}\n",
        "}"
      ),
      gsub("[^a-z0-9]+", "_", tolower(title)),
      title, year, doi_line, note, src
    )
  )
}
