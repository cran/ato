#' ato: Australian Taxation Office Data
#'
#' Tidy R access to Australian Taxation Office ('ATO') Taxation
#' Statistics and related datasets via the 'data.gov.au' CKAN API.
#'
#' @section Main function families:
#' - [ato_catalog()], [ato_download()]: discovery and generic
#'   resource access.
#' - [ato_individuals()], [ato_individuals_postcode()],
#'   [ato_individuals_occupation()]: individual tax return items.
#'   `ato_individuals_postcode()` accepts a vector of years for
#'   time-series panels.
#' - [ato_companies()]: company tax across Tables 1-9 (snapshot,
#'   by size, by entity type, by industry, by industry-and-size,
#'   by sub-industry, by taxable status, by source, by expenses).
#' - [ato_super_funds()]: APRA-regulated super funds and SMSFs.
#' - [ato_top_taxpayers()]: Corporate Tax Transparency release
#'   (Income tax or PRRT sheet).
#' - [ato_gst()], [ato_industry()]: GST and industry aggregates.
#' - [ato_tax_gaps()]: annual Tax Gap estimates across tax heads.
#' - [ato_rdti()]: Research and Development Tax Incentive
#'   claimants.
#' - [ato_irpd()]: International Related Party Dealings (BEPS /
#'   transfer pricing).
#' - [ato_excise()]: excise rates, fuel tax credits, beer and
#'   spirits clearances.
#' - [ato_sme_benchmarks()]: Small Business Benchmarks.
#' - [ato_help()]: HELP / AASL / VSL student-loan statistics.
#' - [ato_cite()]: citation helper (BibTeX, APA, plain text).
#' - [ato_cache_info()], [ato_clear_cache()]: cache management.
#'
#' @section Caveats for users of ATO data:
#'
#' **Nominal AUD.** All monetary values are in nominal Australian
#' dollars of the reporting year. Use `inflateR::inflate()` or
#' ABS CPI series for real-term comparisons across years.
#'
#' **Fiscal year convention.** `"2022-23"` refers to the
#' Australian income year from 1 July 2022 to 30 June 2023.
#'
#' **Confidentiality suppression.** The ATO replaces values with
#' `"np"` (not published), `"*"`, `"\u2021"`, or similar tokens when
#' fewer than ten taxpayers (or fewer than 50 returns for
#' postcode data) fall in a cell. The package coerces these to
#' `NA` so numeric columns stay numeric. Summing a column with
#' `na.rm = TRUE` is the correct default; be explicit about what
#' you do with suppressed cells in any distributional analysis.
#'
#' **Schema drift.** Column names and table numbering shift
#' year-to-year (e.g. occupation data has been T13, T14, T15 in
#' different years). The package cleans names to snake_case on
#' ingestion but does not normalise schemas across years. A
#' cross-year join requires explicit column mapping.
#'
#' **Classification migration.** ANZSIC 2006 to ANZSIC 2020 and
#' ANZSCO 2013 to ANZSCO 2021 recodes affect industry and
#' occupation series. Users stacking across releases should
#' inspect the classification version used in each release.
#'
#' **Silent revisions.** CKAN `metadata_modified` timestamps
#' change without a version bump when the ATO republishes a
#' corrected file. Run [ato_clear_cache()] to force a refresh.
#'
#' **Microdata is out of scope.** The 2% Individual Sample File
#' is distributed separately through Hugh Parsonage's
#' [taxstats](https://github.com/HughParsonage/taxstats) DRAT
#' repo. ALife (the ATO Longitudinal Information Files) is
#' restricted-access microdata via the ATO DataLab and requires
#' a researcher application; it is not provided by this package.
#'
#' **Citation.** Use [ato_cite()] on any returned `ato_tbl` to
#' produce a Treasury-grade footnote, APA reference, or BibTeX
#' entry with the source URL, licence, retrieval date, and title.
#'
#' @section Data source:
#' Taxation Statistics are published annually by the ATO on
#' <https://www.ato.gov.au/about-ato/research-and-statistics/> and
#' mirrored at <https://data.gov.au/data/organization/australiantaxationoffice>.
#' Most datasets are licensed under Creative Commons Attribution 2.5
#' Australia; Corporate Tax Transparency and the Voluntary Tax
#' Transparency Code are CC BY 3.0 Australia.
#'
#' @keywords internal
#' @concept Australian tax
#' @concept taxation statistics
#' @concept income distribution
"_PACKAGE"
