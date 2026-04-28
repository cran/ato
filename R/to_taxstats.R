# Microdata bridge: remap ATO aggregate column names to the
# `taxstats` / `taxstats2` DRAT package schema, so analyses can
# move between aggregate and 2%-sample microdata views with
# consistent variable definitions.

#' Schema map: ATO aggregate columns -> taxstats microdata columns
#' @noRd
ATO_TAXSTATS_SCHEMA_MAP <- list(
  # Aggregate -> microdata canonical name
  total_income_or_loss      = "Tot_inc_amt",
  total_income              = "Tot_inc_amt",
  taxable_income            = "Taxable_Income",
  net_tax                   = "Tax_free_threshold_amt",
  tax_payable               = "Tax_assessed_amt",
  medicare_levy             = "Medicare_levy",
  salary_wages              = "Sw_amt",
  allowances                = "All_amt",
  deductions_total          = "Total_deductions_amt",
  work_related_car          = "WRE_car_amt",
  work_related_travel       = "WRE_travel_amt",
  work_related_clothing     = "WRE_uniform_amt",
  donations                 = "Gifts_amt",
  rental_income             = "Rent_inc_amt",
  rental_interest           = "Rent_int_ded_amt",
  franking_credits          = "Franking_credits_amt",
  interest_income           = "Total_IT_amt",
  dividends                 = "Div_unfranked_amt",
  cgt_net                   = "Net_CG_amt",
  hecs_repayment            = "HELP_repay_amt",
  postcode                  = "Postcode",
  age_range                 = "age_range",
  sex                       = "Gender",
  state                     = "State"
)

#' Remap an ato_tbl to the taxstats microdata column schema
#'
#' Takes an `ato_tbl` with aggregate column names (produced by any
#' `ato_*` function) and renames columns to match the `taxstats`
#' (or `taxstats2`) 2% microdata sample schema used by Hugh
#' Parsonage's DRAT package. Enables consistent variable
#' definitions when moving between aggregate views and microdata
#' prototyping.
#'
#' @details
#' The bundled schema map (\code{ato_schema_map()}) mirrors the
#' column names from Parsonage's `taxstats` and `taxstats2`
#' packages, which in turn use the ATO Individual Sample File
#' variable names. Because `taxstats` is DRAT-distributed and not
#' on CRAN, this function imposes the mapping as a static table
#' rather than programmatically introspecting the `taxstats`
#' namespace. Re-check the bundled map against the `taxstats`
#' NAMESPACE when the ATO publishes a revised Sample File schema.
#'
#' Unknown columns pass through unchanged. Use
#' \code{\link{ato_harmonise}} first if the input panel has drift
#' in source column names.
#'
#' @param df An `ato_tbl` or data frame.
#' @param direction `"to_taxstats"` (default, aggregate -> microdata)
#'   or `"from_taxstats"` (microdata -> aggregate).
#'
#' @return A data frame with renamed columns. `ato_tbl` class and
#'   provenance attributes preserved.
#'
#' @references
#' Parsonage, H. (2019). \emph{taxstats: 2 per cent Individual
#'   Sample File from the Australian Taxation Office}. R package
#'   (DRAT).
#'   \url{https://github.com/HughParsonage/taxstats}
#'
#' Parsonage, H. (2024). \emph{grattan: Perform Common Quantitative
#'   Tasks for Australian Analysts}. R package version 2026.1.1.
#'   \url{https://cran.r-project.org/package=grattan}
#'
#' Australian Taxation Office (2024). \emph{Taxation Statistics:
#'   Individual Sample File documentation}.
#'
#' @family harmonisation
#' @export
#' @examples
#' df <- data.frame(postcode = "2000", taxable_income = 80000,
#'                  medicare_levy = 1600)
#' ato_to_taxstats(df)
ato_to_taxstats <- function(df,
                             direction = c("to_taxstats",
                                           "from_taxstats")) {
  direction <- match.arg(direction)
  map <- ATO_TAXSTATS_SCHEMA_MAP
  if (direction == "from_taxstats") {
    # Invert; for many-to-one mappings, the first aggregate name wins.
    inv <- list()
    for (k in names(map)) {
      v <- map[[k]]
      if (is.null(inv[[v]])) inv[[v]] <- k
    }
    map <- inv
  }
  nm <- names(df)
  for (i in seq_along(nm)) {
    if (!is.null(map[[nm[i]]])) nm[i] <- map[[nm[i]]]
  }
  names(df) <- nm
  df
}

#' Print the ATO -> taxstats schema map
#'
#' Convenience accessor for the bundled column-name mapping.
#'
#' @return A data frame with columns `ato_aggregate` and
#'   `taxstats_microdata`.
#' @family harmonisation
#' @export
#' @examples
#' head(ato_schema_map())
ato_schema_map <- function() {
  data.frame(
    ato_aggregate       = names(ATO_TAXSTATS_SCHEMA_MAP),
    taxstats_microdata  = unlist(ATO_TAXSTATS_SCHEMA_MAP, use.names = FALSE),
    stringsAsFactors = FALSE
  )
}
