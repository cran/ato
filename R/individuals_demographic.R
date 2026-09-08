# Individuals demographic cuts: age, sex, state.

#' Individual tax data by age range
#'
#' Returns Taxation Statistics Individuals Table 2 (approximately):
#' counts, total income, taxable income, and tax payable by age
#' range and (usually) sex. Age ranges are 5-year bands for most
#' of working life plus wider bands at the tails.
#'
#' @param year `"YYYY-YY"`, `"latest"`, or a vector of years.
#' @param sex One of `"all"` (default), `"male"`, or `"female"`.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics Individuals.
#'   Licensed CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Taxation Statistics:
#'   Individuals explanatory notes}. Age-range breakdowns use the
#'   taxpayer's reported date of birth at lodgement; sex is
#'   self-reported on the return.
#'
#' @family individuals
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_individuals_age(year = "2022-23", sex = "female"))
#' options(op)
#' }
ato_individuals_age <- function(year = "latest",
                                 sex = c("all", "male", "female")) {
  sex <- match.arg(sex)
  if (length(year) > 1L) {
    resolved <- vapply(as.list(year), ato_resolve_year, character(1))
    fn <- function(year) ato_individuals_age(year = year, sex = sex)
    return(ato_stack_years(fn, resolved,
                           title_prefix = "ATO individuals by age"))
  }
  id <- ato_ts_package_id(year)
  res <- ato_ckan_resolve(id, c("individual02", "individual_02", "age"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  if (sex != "all") {
    sex_col <- ato_find_col(df, "sex")
    if (is.na(sex_col)) {
      cli::cli_warn(c("Cannot filter by sex: no sex column found.",
                      "i" = "Returning all rows unfiltered."))
    } else {
      df <- df[tolower(df[[sex_col]]) == sex, , drop = FALSE]
    }
  }
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO individuals by age ", year))
}

#' Individual tax data by sex
#'
#' Returns counts and aggregates split by sex. Thin wrapper around
#' the ATO "Selected items by sex" table.
#'
#' @param year `"YYYY-YY"`, `"latest"`, or a vector of years.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics Individuals.
#'   Licensed CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Taxation Statistics:
#'   Individuals explanatory notes}. Age-range breakdowns use the
#'   taxpayer's reported date of birth at lodgement; sex is
#'   self-reported on the return.
#'
#' @family individuals
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_individuals_sex(year = "2022-23"))
#' options(op)
#' }
ato_individuals_sex <- function(year = "latest") {
  if (length(year) > 1L) {
    resolved <- vapply(as.list(year), ato_resolve_year, character(1))
    fn <- function(year) ato_individuals_sex(year = year)
    return(ato_stack_years(fn, resolved,
                           title_prefix = "ATO individuals by sex"))
  }
  id <- ato_ts_package_id(year)
  # A bare "sex" pattern matches "...lodgmentmethodsex..." (Table 2),
  # so anchor on the table number and never fall back to it.
  res <- ato_ckan_resolve(id, c("individual03", "individual_03"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO individuals by sex ", year))
}

#' Individual tax data by state or territory
#'
#' Returns counts and aggregates by state. Thin wrapper around
#' the ATO "Selected items by state/territory" table.
#'
#' @param year `"YYYY-YY"`, `"latest"`, or a vector of years.
#'
#' @return An `ato_tbl`.
#'
#' @source Australian Taxation Office Taxation Statistics Individuals.
#'   Licensed CC BY 2.5 AU.
#'
#' @references
#' Australian Taxation Office (annual). \emph{Taxation Statistics:
#'   Individuals explanatory notes}. Age-range breakdowns use the
#'   taxpayer's reported date of birth at lodgement; sex is
#'   self-reported on the return.
#'
#' @family individuals
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' try(ato_individuals_state(year = "2022-23"))
#' options(op)
#' }
ato_individuals_state <- function(year = "latest") {
  if (length(year) > 1L) {
    resolved <- vapply(as.list(year), ato_resolve_year, character(1))
    fn <- function(year) ato_individuals_state(year = year)
    return(ato_stack_years(fn, resolved,
                           title_prefix = "ATO individuals by state"))
  }
  id <- ato_ts_package_id(year)
  # "state" and "territory" appear in the filenames of Snapshot 7 and
  # Individuals Tables 2, 5, 6 and 8, all of which precede Table 4.
  res <- ato_ckan_resolve(id, c("individual04", "individual_04"),
                          exclude = "snapshot")
  url <- res$url %||% ""
  df <- ato_fetch_xlsx(url, sheet = 1)
  rownames(df) <- NULL
  new_ato_tbl(df,
              source = url,
              licence = "CC BY 2.5 AU",
              title = paste0("ATO individuals by state ", year))
}
