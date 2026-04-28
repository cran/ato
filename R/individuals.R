# Individuals Taxation Statistics

#' @noRd
ato_ts_package_id <- function(year) {
  if (identical(year, "latest")) {
    result <- ato_ckan_search(q = "taxation-statistics", rows = 50L)
    ids <- vapply(result$results, function(p) p$name %||% "", character(1))
    ids <- ids[grepl("^taxation-statistics-[0-9]{4}-[0-9]{2}$", ids)]
    if (length(ids) == 0L) {
      cli::cli_abort("Could not find any Taxation Statistics packages.")
    }
    ids <- sort(ids, decreasing = TRUE)
    return(ids[1L])
  }
  yr <- ato_resolve_year(year)
  paste0("taxation-statistics-", yr)
}

#' Individual Taxation Statistics snapshot
#'
#' Returns the Individuals Table 1 snapshot: aggregate counts,
#' total income, taxable income, tax payable, and deductions
#' across all individual returns (roughly 14 million per year).
#' The snapshot is the headline table; for finer cuts use the
#' dedicated functions:
#' - [ato_individuals_postcode()] for geographic breakdowns,
#' - [ato_individuals_occupation()] for occupation × sex × income-range
#'   detail, or
#' - [ato_download()] with a custom `pattern` for specific
#'   Tables 2 to 27 (age, sex, state, industry, source of income,
#'   deductions, offsets, CGT, non-residents).
#'
#' Monetary values are nominal AUD of the reporting year. Use
#' `inflateR::inflate()` or the ABS CPI series if you need
#' real-term comparisons.
#'
#' @param year Year in `"YYYY-YY"` form (e.g. `"2022-23"`) or
#'   `"latest"`. `"latest"` resolves to the most recently
#'   published release (currently 2022-23).
#'
#' @return An `ato_tbl` with one row per aggregate line-item and
#'   columns for count and amount in nominal AUD.
#'
#' @source Australian Taxation Office Taxation Statistics
#'   <https://www.ato.gov.au/about-ato/research-and-statistics/>.
#'   Licensed CC BY 2.5 AU.
#'
#' @family individuals
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   ind <- ato_individuals(year = "2022-23")
#'   head(ind)
#' })
#' options(op)
#' }
ato_individuals <- function(year = "latest") {
  id <- ato_ts_package_id(year)
  res <- ato_ckan_resolve(id, "individual(s)?01|individual_01|snapshot")
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO individuals snapshot ", year))
}

#' Individual tax data by postcode
#'
#' Returns the Individuals Table 6 (or standalone postcode
#' dataset): taxable income, tax payable, and return counts by
#' 4-digit postcode. Headline dataset for income-distribution
#' journalism.
#'
#' **Privacy suppression.** The ATO suppresses postcodes with
#' fewer than 50 returns; those cells are returned as `NA` after
#' parsing (the package maps `"np"`, `"*"`, and similar tokens
#' to `NA` so numeric columns stay numeric). Small or remote
#' postcodes will be silently missing from the output.
#'
#' Monetary values are nominal AUD of the reporting year. Use
#' `inflateR::inflate()` for real-term series.
#'
#' @param year `"YYYY-YY"` or `"latest"`. Pass a vector of years
#'   (e.g. `c("2020-21", "2021-22", "2022-23")` or `2018:2022`)
#'   to stack multiple years with a `year` column added to the
#'   output. Useful for time-series analysis.
#' @param state Optional character vector of state codes (e.g.
#'   `"NSW"`, `c("VIC", "QLD")`).
#' @param postcode Optional character vector of 4-digit postcodes.
#'
#' @return An `ato_tbl` with one row per postcode (or per postcode
#'   per year for multi-year queries), including state, return
#'   count, total income, taxable income, and tax payable. Schema
#'   drifts year to year (SA3/SA4 columns present from 2017
#'   onwards).
#'
#' @source Australian Taxation Office Taxation Statistics
#'   postcode release. Licensed CC BY 2.5 AU.
#'
#' @references
#' Atkinson, A.B. and Leigh, A. (2007). "The Distribution of Top
#'   Incomes in Australia." \emph{Economic Record}, 83(262),
#'   247-261. \doi{10.1111/j.1475-4932.2007.00412.x}
#'
#' Burkhauser, R.V., Hahn, M.H. and Wilkins, R. (2015). "Measuring
#'   top incomes using tax record data: a cautionary tale from
#'   Australia." \emph{Journal of Economic Inequality}, 13(2),
#'   181-205. \doi{10.1007/s10888-014-9281-z}
#'
#' @family individuals
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   # Single year
#'   p <- ato_individuals_postcode(year = "2022-23", state = "NSW")
#'   head(p)
#'   # Multi-year stack with year column
#'   panel <- ato_individuals_postcode(year = c("2020-21", "2021-22"),
#'                                     state = "NSW")
#' })
#' options(op)
#' }
ato_individuals_postcode <- function(year = "latest", state = NULL,
                                      postcode = NULL) {
  # Multi-year path: stack results with a year column.
  if (length(year) > 1L) {
    resolved <- vapply(as.list(year), ato_resolve_year, character(1))
    first_src <- NULL
    parts <- lapply(resolved, function(y) {
      df <- ato_individuals_postcode(year = y, state = state,
                                     postcode = postcode)
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
        "i" = "Try fewer years or inspect each year separately first."
      ))
    }
    stacked <- do.call(
      rbind,
      lapply(parts, function(d) d[, common, drop = FALSE])
    )
    rownames(stacked) <- NULL
    return(new_ato_tbl(stacked,
                       source  = first_src %||% "",
                       licence = "CC BY 2.5 AU",
                       title   = paste0("ATO individuals by postcode (",
                                        min(resolved), " to ", max(resolved),
                                        ")")))
  }

  id <- ato_ts_package_id(year)
  res <- ato_ckan_resolve(id, "postcode")
  url <- res$url %||% ""
  cached <- ato_download_cached(url)
  sheets <- tryCatch(readxl::excel_sheets(cached),
                     error = function(e) character(0))
  target_sheet <- if (length(sheets) > 0L &&
                      tolower(sheets[1]) %in% c("notes", "cover",
                                                 "information",
                                                 "contents")) {
    2L
  } else {
    1L
  }
  df <- ato_fetch_xlsx(url, sheet = target_sheet)

  state_col <- ato_find_col(df, "state")
  if (!is.null(state) && !is.na(state_col)) {
    df <- df[toupper(df[[state_col]]) %in% toupper(state), , drop = FALSE]
  }
  pc_col <- ato_find_col(df, "postcode")
  if (!is.null(postcode) && !is.na(pc_col)) {
    df <- df[as.character(df[[pc_col]]) %in% as.character(postcode), ,
             drop = FALSE]
  }
  rownames(df) <- NULL

  ato_warn_suppression(df, context = "postcode cells")

  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO individuals by postcode ", year))
}

#' Individual tax data by occupation
#'
#' Returns the Individuals Table 14 (occupation by sex by taxable
#' income range). Around 1,000 occupations classified by ANZSCO
#' with aggregate counts, total income, taxable income, and tax
#' payable. The ATO migrated from ANZSCO 2013 to ANZSCO 2021
#' across the 2022-23 release; cross-year joins on occupation
#' name or code must account for the recode.
#'
#' **Classification break.** Releases from 2022-23 onwards use
#' ANZSCO 2021; earlier releases use ANZSCO 2013. A warning is
#' emitted when the requested year(s) are at or after this boundary,
#' or when a multi-year request spans it.
#'
#' @param year `"YYYY-YY"`, `"latest"`, or a vector of years for
#'   a multi-year panel (e.g. `c("2020-21", "2021-22", "2022-23")`).
#' @param occupation Optional substring filter (case-insensitive)
#'   applied to the occupation description column.
#' @param sex One of `"all"` (default), `"male"`, or `"female"`.
#'   Rows with sex recorded as `"Not stated"` are dropped when
#'   filtering to male or female. Short forms `"m"`/`"f"` are
#'   accepted.
#'
#' @return An `ato_tbl` with one row per occupation-sex-income
#'   combination. Multi-year queries add a `year` column.
#'   Monetary values in nominal AUD of the reporting year.
#'
#' @source Australian Taxation Office Taxation Statistics.
#'   Licensed CC BY 2.5 AU.
#'
#' @family individuals
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try({
#'   occ <- ato_individuals_occupation(year = "2022-23",
#'                                     occupation = "economist")
#'   head(occ)
#'   # Multi-year panel
#'   panel <- ato_individuals_occupation(year = c("2021-22", "2022-23"),
#'                                       occupation = "nurse")
#' })
#' options(op)
#' }
ato_individuals_occupation <- function(year = "latest", occupation = NULL,
                                        sex = c("all", "male", "female",
                                                 "m", "f")) {
  sex <- match.arg(sex)
  sex <- switch(sex, m = "male", f = "female", sex)

  # Multi-year path
  if (length(year) > 1L) {
    resolved <- vapply(as.list(year), ato_resolve_year, character(1))
    ato_warn_classification_span(resolved, "anzsco")
    fn <- function(year) {
      ato_individuals_occupation(year = year, occupation = occupation, sex = sex)
    }
    return(ato_stack_years(fn, resolved,
                           title_prefix = "ATO individuals by occupation"))
  }

  id  <- ato_ts_package_id(year)
  resolved_year <- sub("taxation-statistics-", "", id)
  ato_warn_classification_break(resolved_year, "anzsco")

  res <- ato_ckan_resolve(id, "occupation|individual(s)?14|individual_14")
  url <- res$url %||% ""
  df  <- ato_fetch_xlsx(url, sheet = 1)

  occ_col <- ato_find_col(df, "occupation")
  if (!is.null(occupation) && !is.na(occ_col)) {
    pattern <- paste(tolower(occupation), collapse = "|")
    df <- df[grepl(pattern, tolower(df[[occ_col]])), , drop = FALSE]
  }
  sex_col <- ato_find_col(df, "sex")
  if (sex != "all" && !is.na(sex_col)) {
    keep <- tolower(df[[sex_col]]) == sex
    df   <- df[keep, , drop = FALSE]
  }

  if (!is.null(occupation) && nrow(df) == 0L) {
    cli::cli_warn("No occupation rows matched {.val {occupation}}.")
  }

  rownames(df) <- NULL
  new_ato_tbl(df,
              source  = url,
              licence = "CC BY 2.5 AU",
              title   = paste0("ATO individuals by occupation ", year))
}
