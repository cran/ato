## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", eval = FALSE)

## -----------------------------------------------------------------------------
# library(ato)
# 
# pc <- ato_individuals_postcode(
#   year = c("2018-19", "2019-20", "2020-21",
#            "2021-22", "2022-23", "2023-24"),
#   state = "NSW"
# )
# 
# nrow(pc)
# unique(pc$year)

## -----------------------------------------------------------------------------
# pc <- ato_harmonise(pc)
# names(pc)

## -----------------------------------------------------------------------------
# ind_2223 <- ato_individuals(year = "2022-23")
# total_tax <- sum(ind_2223$tax_payable, na.rm = TRUE)
# 
# ato_reconcile(
#   value   = total_tax,
#   year    = "2022-23",
#   measure = "individuals_income_tax_net"
# )

## -----------------------------------------------------------------------------
# panel_annual <- aggregate(taxable_income ~ year, data = pc, FUN = sum,
#                           na.rm = TRUE)
# panel_annual$real_2022_23 <- ato_deflate(
#   panel_annual$taxable_income,
#   year = panel_annual$year,
#   base = "2022-23"
# )
# panel_annual

## -----------------------------------------------------------------------------
# panel_annual$per_capita <- ato_per_capita(
#   panel_annual$real_2022_23,
#   year = panel_annual$year
# )
# panel_annual

