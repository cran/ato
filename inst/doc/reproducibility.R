## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", eval = FALSE)

## -----------------------------------------------------------------------------
# library(ato)
# 
# ato_snapshot("2026-04-24")
# ato_manifest_clear()

## -----------------------------------------------------------------------------
# ind <- ato_individuals_postcode(
#   year = c("2020-21", "2021-22", "2022-23"),
#   state = "NSW"
# )
# 
# companies <- ato_companies(year = "2022-23", table = "industry")
# tax_gap   <- ato_tax_gaps()

## -----------------------------------------------------------------------------
# man <- ato_manifest()
# man[, c("title", "sha256", "retrieved", "snapshot_date")]

## -----------------------------------------------------------------------------
# ato_manifest_write("appendix/ato_manifest.csv")
# ato_manifest_write("appendix/ato_manifest.yaml")

## -----------------------------------------------------------------------------
# dep <- ato_deposit_zenodo(
#   title = "ATO data snapshot for working paper v1",
#   creators = list(list(name = "Author, A.", orcid = "0000-0000-0000-0000")),
#   upload = FALSE  # dry run; inspect payload first
# )
# dep$payload$metadata$title
# 
# # When ready to actually deposit:
# # Sys.setenv(ZENODO_TOKEN = "...your token...")
# # dep <- ato_deposit_zenodo(upload = TRUE)
# # dep$doi_prereserve

## -----------------------------------------------------------------------------
# ato_cite(ind, style = "bibtex", doi = "10.5281/zenodo.XXXXXXXX")

