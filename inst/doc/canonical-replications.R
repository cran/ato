## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", eval = FALSE)

## -----------------------------------------------------------------------------
# library(ato)
# ato_snapshot("2026-04-24")
# 
# pc_panel <- ato_individuals_postcode(
#   year = c("2015-16", "2016-17", "2017-18", "2018-19",
#            "2019-20", "2020-21", "2021-22", "2022-23",
#            "2023-24")
# )
# pc_panel <- ato_harmonise(pc_panel)
# 
# # For each year, rank postcodes by mean taxable income per return,
# # take top 1% of returns, compute their share of total income.
# top1 <- function(df) {
#   df <- df[order(-df$taxable_income / df$number_of_individuals), ]
#   cum_returns <- cumsum(df$number_of_individuals)
#   total_returns <- sum(df$number_of_individuals, na.rm = TRUE)
#   cutoff <- which(cum_returns >= 0.01 * total_returns)[1]
#   sum(df$taxable_income[seq_len(cutoff)], na.rm = TRUE) /
#     sum(df$taxable_income, na.rm = TRUE)
# }
# 
# shares <- by(pc_panel, pc_panel$year, top1)
# shares

## -----------------------------------------------------------------------------
# ctt <- ato_top_taxpayers(year = "2022-23")
# 
# # Effective tax rate = tax payable / taxable income, for entities
# # with positive taxable income. Drop zero-taxable rows (they bias
# # the ratio; rely on loss-makers analysis separately).
# ctt <- ctt[!is.na(ctt$taxable_income) & ctt$taxable_income > 0, ]
# ctt$etr <- ctt$tax_payable / ctt$taxable_income
# 
# by_industry <- aggregate(etr ~ entity_type, data = ctt, FUN = median)
# by_industry[order(-by_industry$etr), ]

## -----------------------------------------------------------------------------
# tg <- ato_tax_gaps()
# 
# library(ggplot2)
# ggplot(tg, aes(x = year, y = tax_gap_estimate,
#                colour = tax_gap_type)) +
#   geom_line() +
#   labs(title = "ATO estimated tax gaps over time",
#        x = NULL, y = "Estimated tax gap (AUD million)",
#        colour = "Gap type",
#        caption = "Source: ATO Taxation Statistics. Retrieved via ato package.") +
#   theme_minimal()

## -----------------------------------------------------------------------------
# help_data <- ato_help()
# 
# # Bucketed by age range; real-terms deflation to 2022-23
# help_data$real <- ato_deflate(help_data$total_debt,
#                                year = help_data$year,
#                                base = "2022-23")
# head(help_data)

