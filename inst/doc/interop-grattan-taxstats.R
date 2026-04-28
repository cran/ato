## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", eval = FALSE)

## -----------------------------------------------------------------------------
# library(ato)
# head(ato_schema_map(), 15)

## -----------------------------------------------------------------------------
# library(ato)
# 
# ato_snapshot("2026-04-24")
# 
# mls <- ato_medicare_levy(year = "2022-23", component = "surcharge")
# 
# # Reconcile the published MLS total against FBO where available
# # (MLS does not have a direct FBO line; rolled into individuals
# # income tax net).
# ind_total <- sum(ato_individuals(year = "2022-23")$tax_payable,
#                  na.rm = TRUE)
# ato_reconcile(ind_total, "2022-23", "individuals_income_tax_net")

## -----------------------------------------------------------------------------
# # Rename columns to taxstats schema
# mls_ts <- ato_to_taxstats(mls)
# 
# # Now these columns are consistent with what `taxstats::taxstats1819`
# # uses. You can write analysis code that works on both.
# 
# # Example: use grattan to compute the new regime's tax for the 2% sample
# # library(taxstats)
# # library(grattan)
# # sample_2pc <- taxstats1819
# # sample_2pc$new_tax <- income_tax(
# #   income = sample_2pc$Taxable_Income,
# #   fy.year = "2023-24",
# #   ...
# # )
# # reform_cost <- sum(sample_2pc$new_tax - sample_2pc$Tax_assessed_amt,
# #                    na.rm = TRUE) * 50  # 2% -> 100%

