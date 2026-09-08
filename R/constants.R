# Package-level constants

# Central registry of ATO CKAN package IDs.
# If one breaks, ato_ckan_package() errors with the slug so the fix is obvious.
#' @noRd
ATO_PACKAGE_IDS <- list(
  tax_gaps  = "australian-tax-gaps",
  rdti      = "research-and-development-tax-incentive",
  irpd_bare = "international-related-party-dealings",
  excise    = "excise-data",
  sme       = "small-business-benchmarks",
  help      = "higher-education-loan-program-help",
  smsf      = "self-managed-superannuation-funds",
  ctt       = "corporate-transparency",
  vttc      = "voluntary-tax-transparency-code"
)

# Column name variants per logical role. ATO renames columns across years;
# each vector lists all known names in priority order.
# Use ato_find_col(df, "key") to pick the first matching variant.
#
# Variants are the base name only. ato_find_col() also matches a
# trailing footnote digit (state_territory1, broad_industry2) and
# the variant as a leading token (occupation_unit_group1), so do
# not enumerate those forms here.
#' @noRd
ATO_COL_VARIANTS <- list(
  state      = c("state", "state_territory"),
  postcode   = c("postcode", "post_code"),
  sex        = c("sex", "gender"),
  industry   = c("industry", "industry_description",
                 "broad_industry", "fine_industry", "anzsic_industry"),
  entity     = c("entity_type", "tax_entity_type", "company_type"),
  occupation = c("occupation", "occupation_description")
)

# Start year (as integer) of the ANZSCO 2013 -> 2021 and ANZSIC 2006 -> 2020
# reclassification, applied across the 2022-23 Taxation Statistics release.
#' @noRd
ATO_CLASSIFICATION_BREAK_YEAR <- 2022L
