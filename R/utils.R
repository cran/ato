# Internal helpers

#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x

#' @noRd
ato_format_bytes <- function(x) {
  if (is.na(x) || x < 1024) return(paste0(x, " B"))
  units <- c("KB", "MB", "GB", "TB")
  for (i in seq_along(units)) {
    x <- x / 1024
    if (x < 1024 || i == length(units)) {
      return(sprintf("%.1f %s", x, units[i]))
    }
  }
}

#' Clean column names to snake_case
#' @noRd
ato_clean_names <- function(x) {
  x <- tolower(x)
  x <- gsub("[^a-z0-9]+", "_", x)
  x <- gsub("^_+|_+$", "", x)
  x <- gsub("_+", "_", x)
  x
}

#' ATO confidentiality suppression tokens
#'
#' The ATO replaces values with one of these tokens when fewer
#' than ten taxpayers (or fewer than 50 returns for postcode
#' data) fall in a cell. Passing them through `na.strings`
#' ensures numeric columns stay numeric. Seen across the
#' Taxation Statistics, Corporate Tax Transparency, Tax Gaps,
#' and Small Business Benchmarks releases.
#' @noRd
ATO_SUPPRESSION_TOKENS <- c(
  "",
  "NA", "N/A", "N.A.", "n/a", "n.a.",
  "np", "n.p.", "N.P.", "Np",
  "-", "--", ".", "..", "...",
  "*", "**",
  "\u2021", "\u2020"  # double dagger, dagger
)

#' Fetch a CSV and return a tidy data frame
#'
#' ATO CSVs use `"np"` (not published), `"*"`, `"‡"`, and other
#' tokens to suppress cells with fewer than ten taxpayers. These
#' are coerced to `NA` so numeric columns stay numeric.
#' @noRd
ato_fetch_csv <- function(url, ...) {
  file <- ato_download_cached(url)
  df <- utils::read.csv(file, stringsAsFactors = FALSE,
                        check.names = FALSE,
                        na.strings = ATO_SUPPRESSION_TOKENS,
                        ...)
  names(df) <- ato_clean_names(names(df))
  df
}

#' Fetch an XLSX and return a data frame
#'
#' ATO XLSX releases use the same confidentiality-suppression
#' tokens as CSV releases; `readxl::read_excel` is passed `na =
#' ATO_SUPPRESSION_TOKENS` so numeric columns are not silently
#' coerced to character when an `np` cell appears.
#'
#' When `skip` is `NULL` (the default), the helper auto-detects
#' the header row by reading up to 15 rows without headers and
#' finding the first row that looks like a header (three or more
#' non-empty string cells). This handles ATO workbooks that lead
#' with a title or narrative block before the data table.
#' @noRd
ato_fetch_xlsx <- function(url, sheet = 1, skip = NULL) {
  if (!requireNamespace("readxl", quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg readxl} package is required to parse XLSX files."
    ))
  }
  file <- ato_download_cached(url)
  if (is.null(skip)) {
    skip <- ato_detect_header_row(file, sheet = sheet)
  }
  df <- as.data.frame(
    readxl::read_excel(file, sheet = sheet, skip = skip,
                       na = ATO_SUPPRESSION_TOKENS,
                       .name_repair = "minimal"),
    stringsAsFactors = FALSE
  )
  names(df) <- ato_clean_names(names(df))
  df
}

#' Auto-detect the first row of an XLSX sheet that looks like a
#' column-header row
#'
#' Heuristic: reads up to 15 rows without treating any row as a
#' header, then finds the first row where at least three cells
#' are non-empty strings that do not contain newlines (newlines
#' typically appear in narrative-block rows, not headers).
#' Returns the number of rows to skip before the header.
#' @noRd
ato_detect_header_row <- function(file, sheet = 1, max_scan = 15L) {
  probe <- tryCatch(
    readxl::read_excel(file, sheet = sheet, col_names = FALSE,
                       n_max = max_scan, .name_repair = "minimal"),
    error = function(e) NULL
  )
  if (is.null(probe) || nrow(probe) == 0L) return(0L)

  is_string_row <- function(row) {
    vals <- unlist(row, use.names = FALSE)
    vals <- vals[!is.na(vals) & nzchar(as.character(vals))]
    if (length(vals) < 3L) return(FALSE)
    chars <- suppressWarnings(as.character(vals))
    # Header rows frequently contain newlines (e.g. "Individuals\nno.")
    # so do not reject on that. Reject rows that are all-numeric.
    looks_numeric <- suppressWarnings(!any(is.na(as.numeric(chars))))
    !looks_numeric
  }

  for (i in seq_len(nrow(probe))) {
    if (is_string_row(probe[i, , drop = FALSE])) {
      return(i - 1L)
    }
  }
  0L
}

#' Find the first matching column for a logical role
#'
#' Uses ATO_COL_VARIANTS to handle cross-year column renames. Returns
#' NA_character_ and emits a warning if no variant is found.
#' @noRd
ato_find_col <- function(df, key) {
  variants <- ATO_COL_VARIANTS[[key]]
  if (is.null(variants)) return(NA_character_)
  hit <- intersect(variants, names(df))
  if (length(hit) == 0L) {
    cli::cli_warn(
      "Could not find {.val {key}} column. Tried: {.val {variants}}."
    )
    return(NA_character_)
  }
  hit[1L]
}

#' Warn if a resolved year is at or after the classification break
#'
#' @param resolved_year Canonical "YYYY-YY" string.
#' @param type "anzsco" (occupation) or "anzsic" (industry).
#' @noRd
ato_warn_classification_break <- function(resolved_year,
                                           type = c("anzsco", "anzsic")) {
  type <- match.arg(type)
  yr <- suppressWarnings(as.integer(sub("-.*", "", resolved_year)))
  if (is.na(yr) || yr < ATO_CLASSIFICATION_BREAK_YEAR) return(invisible(NULL))
  if (type == "anzsco") {
    cli::cli_warn(c(
      "{resolved_year} uses ANZSCO 2021 occupation codes.",
      "i" = "Releases before 2022-23 use ANZSCO 2013.",
      "i" = "Cross-year occupation joins need a concordance recode."
    ))
  } else {
    cli::cli_warn(c(
      "{resolved_year} uses ANZSIC 2020 industry codes.",
      "i" = "Releases before 2022-23 use ANZSIC 2006.",
      "i" = "Cross-year industry joins need a concordance recode."
    ))
  }
  invisible(NULL)
}

#' Warn if a set of resolved years spans the classification break
#' @noRd
ato_warn_classification_span <- function(resolved_years,
                                          type = c("anzsco", "anzsic")) {
  type <- match.arg(type)
  yr_nums <- suppressWarnings(as.integer(sub("-.*", "", resolved_years)))
  spans <- any(yr_nums >= ATO_CLASSIFICATION_BREAK_YEAR, na.rm = TRUE) &&
           any(yr_nums < ATO_CLASSIFICATION_BREAK_YEAR, na.rm = TRUE)
  if (!spans) return(invisible(NULL))
  label <- if (type == "anzsco") "ANZSCO 2013 \u2192 2021 (occupation)" else
                                  "ANZSIC 2006 \u2192 2020 (industry)"
  cli::cli_warn(c(
    "Requested years span the {label} reclassification in 2022-23.",
    "i" = "Cross-year comparisons across this boundary need a concordance recode."
  ))
  invisible(NULL)
}

#' Warn if a high proportion of numeric cells are suppressed
#'
#' Checks the first numeric column in df. Fires when suppression
#' rate >= threshold (default 5%).
#' @noRd
ato_warn_suppression <- function(df, threshold = 0.05,
                                  context = "cells") {
  num_cols <- which(vapply(df, is.numeric, logical(1)))
  if (length(num_cols) == 0L || nrow(df) == 0L) return(invisible(NULL))
  col_name <- names(df)[num_cols[1L]]
  n_na <- sum(is.na(df[[col_name]]))
  pct <- n_na / nrow(df)
  if (pct >= threshold) {
    cli::cli_warn(c(
      "{round(100 * pct)}% of {context} are suppressed (np/NA) \\
       in column {.col {col_name}}.",
      "i" = "The ATO suppresses small cells (<50 returns for postcodes).",
      "i" = "Aggregates will understate totals. Use {.code na.rm = TRUE} when summing."
    ))
  }
  invisible(NULL)
}

#' Stack multi-year calls to a single-year data function
#'
#' fn must accept a year= argument; ... are NOT forwarded (use closures).
#' Returns a new ato_tbl with a year column added.
#' @noRd
ato_stack_years <- function(fn, years, title_prefix = "ATO data") {
  resolved <- vapply(as.list(years), ato_resolve_year, character(1))
  first_src <- NULL
  parts <- lapply(resolved, function(y) {
    df <- fn(year = y)
    if (is.null(first_src)) first_src <<- attr(df, "ato_source")
    df <- as.data.frame(df, stringsAsFactors = FALSE)
    df$year <- y
    df
  })
  common <- Reduce(intersect, lapply(parts, names))
  common <- common[nzchar(common)]
  if (length(common) == 0L) {
    cli::cli_abort(c(
      "No column names are common across the requested years.",
      "i" = "Try fewer years, or inspect each year individually first."
    ))
  }
  stacked <- do.call(
    rbind,
    lapply(parts, function(d) d[, common, drop = FALSE])
  )
  rownames(stacked) <- NULL
  new_ato_tbl(stacked,
              source  = first_src %||% "",
              licence = "CC BY 2.5 AU",
              title   = paste0(title_prefix, " (",
                               min(resolved), " to ", max(resolved), ")"))
}

#' Convert a user-supplied year string to the ATO Taxation Statistics slug
#'
#' Users can pass year in a few forms:
#' - "2022-23"  (canonical)
#' - "2022/23"
#' - "2022-2023"
#' - 2022 (numeric : interpreted as starting year)
#' - "latest" (resolved against the catalogue)
#'
#' Returns the canonical "YYYY-YY" slug used in CKAN package names.
#' @noRd
ato_resolve_year <- function(year) {
  if (is.numeric(year)) {
    start <- as.integer(year)
    return(sprintf("%d-%02d", start, (start + 1L) %% 100L))
  }
  if (identical(year, "latest")) return(year)
  year <- gsub("[/.]", "-", year)
  m <- regmatches(year, regexec("^([0-9]{4})-?([0-9]{2,4})$", year))[[1]]
  if (length(m) == 3L) {
    start <- as.integer(m[2])
    end <- as.integer(m[3]) %% 100L
    return(sprintf("%d-%02d", start, end))
  }
  cli::cli_abort("Could not parse year {.val {year}}. Use format like '2022-23' or 2022.")
}
