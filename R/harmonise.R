# Harmonise column names across multi-year ATO releases. Schema
# drifts year to year (column renames, table renumbering); this
# function normalises a stacked panel to a canonical column set
# using ATO_COL_VARIANTS.

#' Harmonise column names in a multi-year ATO panel
#'
#' ATO renames columns across annual releases; a stacked panel
#' from `ato_individuals_postcode(year = c("2020-21", "2021-22"))`
#' may have inconsistent names like `total_income` vs
#' `total_income_or_loss`. `ato_harmonise()` renames columns to
#' the first variant in `ATO_COL_VARIANTS` so panels are join-ready.
#'
#' Unknown columns are left alone. Columns that collide after
#' renaming (because two variants map to the same canonical name)
#' emit a warning; the first column wins.
#'
#' @param df A data frame (typically an `ato_tbl` with `year`
#'   column from a multi-year call).
#'
#' @return A data frame with harmonised names. `ato_tbl` class
#'   and provenance attributes are preserved.
#' @family harmonisation
#' @export
#' @examples
#' df <- data.frame(postcode = "2000",
#'                  total_income_or_loss = 100,
#'                  state_territory = "NSW")
#' ato_harmonise(df)
ato_harmonise <- function(df) {
  stopifnot(is.data.frame(df))
  new_names <- names(df)
  for (canonical in names(ATO_COL_VARIANTS)) {
    variants <- ATO_COL_VARIANTS[[canonical]]
    hits <- which(new_names %in% variants)
    if (length(hits) == 0L) next
    if (length(hits) > 1L) {
      cli::cli_warn(c(
        "Multiple columns map to {.val {canonical}}: \\
         {.val {new_names[hits]}}.",
        "i" = "Keeping first; dropping others."
      ))
      drop <- hits[-1L]
      df <- df[, -drop, drop = FALSE]
      new_names <- names(df)
      hits <- which(new_names %in% variants)
    }
    new_names[hits] <- canonical
  }
  names(df) <- new_names
  df
}
