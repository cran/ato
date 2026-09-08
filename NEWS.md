# ato 0.1.1

Bug-fix release. Version 0.1.0 could not reach the current ATO
release, and several functions returned the wrong table without
saying so. Everything below is a fix; no user-facing arguments
changed except where noted.

## Examples now fail gracefully when Zenodo is unreachable

Every `\donttest{}` example that reaches Zenodo is wrapped in `try()`.
1 block was affected. CRAN runs these in its additional-issues
donttest check, on build machines the upstream host routinely refuses or
rate-limits, and an example that could not reach it was an ERROR rather
than a printed condition. The `options(op)` cache restore stays outside the
`try()` so it runs either way.

This is the CRAN Repository Policy requirement that a package using an
internet resource fail gracefully when the resource is unavailable. It is
the rule obr was archived under on 2026-08-22.

## Data currency

* The ATO published Taxation Statistics 2023-24 in June 2026.
  `year = "latest"` now resolves to it. Documentation that named
  2022-23 as the newest release has been updated, and the
  "latest" wording no longer hardcodes a year.

## Resolution fixes

* `ato_ckan_search()` joined the organisation filter and the
  query terms with a `+`, which `URLencode(reserved = TRUE)`
  escaped to `%2B`. Solr read that as a literal character, so
  every filtered catalogue search returned zero results. This
  broke `year = "latest"`, the default argument on 27 exported
  functions, for every one of them. The terms are now joined
  with a space.

* `ato_fetch_xlsx()` read sheet 1 of each workbook. Nearly every
  ATO workbook opens with a "Notes" or "Information" sheet and
  puts the table on the second, so most functions returned front
  matter rather than data. Front-matter sheets are now detected
  by name and skipped. `ato_individuals()` returns 846 rows
  instead of 17; `ato_individuals_occupation()` 3,771 instead of
  16; `ato_tax_gaps()` 1,187 instead of 16.

* `ato_ckan_resolve()` returned the first resource matching a
  single regex, in package order. The Snapshot workbooks sit at
  positions 2 to 8 of a Taxation Statistics package and their
  filenames contain "postcode" and "occupation", so they shadowed
  the detailed Individuals tables at positions 20 to 47. It now
  accepts a priority vector of patterns plus an `exclude` regex.
  Affected functions and the tables they were returning:

  | Function | Was | Now |
  |---|---|---|
  | `ato_individuals()` | Snapshot 1 (historical tax rates) | Individuals 1 |
  | `ato_individuals_postcode()` | Snapshot 7 (49 rows) | Individuals 6 (5,254 rows) |
  | `ato_individuals_occupation()` | Snapshot 7 | Individuals 14 |
  | `ato_individuals_sex()` | Individuals 2 (matched "...method**sex**...") | Individuals 3 |
  | `ato_individuals_state()` | Snapshot 7 | Individuals 4 |
  | `ato_medicare_levy()` | Individuals 1 (no Medicare columns) | Individuals 3 |

## Column matching

* `ato_find_col()` matched column names exactly, so ATO footnote
  markers defeated it: the postcode table's state column is
  `state_territory1`, not `state_territory`. Filters therefore
  did nothing and returned unfiltered data with only a warning.
  Matching now also accepts a trailing footnote digit
  (`broad_industry2`) and the variant as a leading token
  (`occupation_unit_group1`). `ato_individuals_postcode(state =
  "NSW")` returns 1,250 rows rather than all 5,254.

* Column lookups now happen only when a filter is actually
  requested, and a requested filter that cannot be applied warns
  that the data is being returned unfiltered rather than
  reporting a missing column and continuing quietly.

## Datasets that moved

* `ato_fbt()`, `ato_payg()` and `ato_charities()` searched for
  standalone packages that have never existed on data.gov.au.
  All three are table families inside Taxation Statistics and
  now resolve there.

* `ato_fuel_tax_credits(by = "industry")` looked in the Excise
  Data package, which has never carried the industry table. It
  now reads Excise Table 4 of Taxation Statistics. `by = "fuel"`
  and `by = "period"` read the historical FTC rate schedule from
  Excise Data.

* `ato_vttc()` looked for a resource named after the year. The
  ATO has replaced the per-year workbooks with a single dated
  notifications register covering all signatories and years,
  which is now returned, with a message when a requested year
  cannot be honoured.

## Functions that never had a data source

These aborted or returned an unrelated table. They now abort
with an accurate explanation and a pointer to the real source,
and are candidates for removal in a later release.

* `ato_whm()`: no Working Holiday Maker resource exists in any
  ATO package on data.gov.au, current or archived.
* `ato_division293()`: Division 293 is not published as a
  labelled series. 0.1.0 fell back to Individuals Table 3 and
  titled the result "ATO Division 293".
* `ato_compliance()`: the ATO annual report is a PDF on
  ato.gov.au, not open data.

## Back catalogue

* The front-matter sheet test matched the whole sheet name, so it
  caught "Notes" (28 workbooks) but not "Title & notes" (6) or
  "Individuals Tax Title & Notes" (2). Every release up to 2015-16
  was therefore still parsing its title page instead of the data.
  Now matched as whole words anywhere in the name, which leaves
  genuine data sheets alone (the pre-2010 GST workbooks open on a
  sheet named for the income year, e.g. "2000-01").
  `ato_individuals_postcode(year = "2011-12")` returns 5,067 rows
  instead of 14.

* `ato_super_funds()` matched `fund0[1-4]` only. Releases up to
  2012-13 used a single unpadded digit
  (`taxstats2012fund1apraselecteditemsbyyear.xls`), so those two
  years errored. Both now return ~200 rows.

* Net effect: all six core series now resolve across every release
  from 2011-12 to 2023-24, verified year by year.

## Corporate Tax Transparency

* `ato_top_taxpayers()` ignored its `year` argument when reading
  the workbook. Each CTT release carries late amendments for
  earlier income years alongside the headline year, so the
  2023-24 request returned 4,198 rows spanning 2023-24, 2022-23
  and 2021-22. It now filters on `income_year` and returns the
  4,110 rows the ATO published for 2023-24, reporting how many
  amendment rows were dropped.

## DESCRIPTION

* The package Description advertised Division 293, compliance, and
  Working Holiday Maker aggregates. Those are exactly the three series
  with no data source behind them, and they now abort. Removed from the
  Description, which had been promising data the package cannot supply.

## Metadata and links

* `Language` in DESCRIPTION was `en-US` while the prose is British
  English throughout. Set to `en-GB`, which clears 53 spurious
  spell-check hits (behaviour, catalogue, harmonisation, licence,
  modelling, organisation and similar). `inst/WORDLIST` refreshed
  against the remaining acronyms, surnames and package names;
  `spelling::spell_check_package()` is now clean.

* `ato_international()` cited
  `oecd.org/tax/tax-policy/revenue-statistics.htm`, which OECD has
  since deleted (HTTP 410). Repointed at Revenue Statistics 2025.
  The 410 was invisible to automated URL checking because
  oecd.org returns 403 to every request from a non-browser client,
  valid path or not.

## README

* Every code example is now executed against live data before
  release. The postcode example referenced
  `number_of_individuals` and `taxable_income_average`, neither of
  which exists in Individuals Table 6, so it could never have run;
  it now uses the real columns and derives the mean.
* Dataset count corrected from 42 to 43.
* Coverage corrected from "1994-95 - present" to "2011-12 -
  present". The 2009-10 and 2010-11 packages ship only a PDF, an
  index and a ZIP, and 1994-95 to 2008-09 is a separate legacy
  bundle, so the detailed-table functions cannot reach any of them.

## Tests

* Added `test-resolution.R`. Most of it is offline: query
  encoding, resource-resolution priority and exclusion against a
  mocked package, and column matching. One live test asserts
  that `year = "latest"` resolves to a well-formed, current
  release slug. It is deliberately not behind `ATO_LIVE_TESTS`,
  because every existing live test pinned an explicit year and
  sat behind that opt-in gate, which is why none of them noticed
  that the default argument was broken.

# ato 0.1.0

Initial CRAN submission. First public release. Provides R
access to Australian Taxation Office public datasets via the
data.gov.au Comprehensive Knowledge Archive Network (CKAN) API,
with reproducibility, harmonisation, and interop tooling.

## Data-access functions

### Discovery

* `ato_catalog()`: list all ATO datasets on data.gov.au with
  their resources, licences, and modification dates.
* `ato_download()`: generic resource downloader with local
  cache.

### Individuals

* `ato_individuals()`: Taxation Statistics Individual snapshot
  (Table 1).
* `ato_individuals_postcode()`: individual tax return items by
  postcode and state (Individuals Table 6). Accepts a vector of
  years (e.g. `year = 2018:2022`) and returns a stacked panel
  with a `year` column.
* `ato_individuals_occupation()`: individual tax return items
  by occupation (ANZSCO), sex, and income range.
* `ato_individuals_age()`, `ato_individuals_sex()`,
  `ato_individuals_state()`: demographic cuts.

### Companies and superannuation

* `ato_companies()`: Company Taxation Statistics across all
  nine Company Tables via `table = ...`: snapshot,
  key_items_by_size, entity_type, industry (default),
  industry_by_size, sub_industry, taxable_status, source,
  expenses.
* `ato_super_funds()`: APRA-regulated superannuation fund and
  Self-Managed Superannuation Fund (SMSF) aggregates.

### Other entities, transparency, and aggregates

* `ato_top_taxpayers()`: Corporate Tax Transparency release with
  sheet switch between `income_tax` and `prrt` (Petroleum
  Resource Rent Tax filers).
* `ato_gst()`: Goods and Services Tax tables and Activity
  Statement Ratios.
* `ato_industry()`: industry-level aggregates derived from
  Individual and Company tables.

### Integrity, incentives, and international

* `ato_tax_gaps()`: annual Tax Gap estimates across tax heads
  (individuals, small business, large corporate, GST, excise,
  PRRT, superannuation guarantee). Treasury cites this series
  in every MYEFO.
* `ato_rdti()`: Research and Development Tax Incentive
  claimants, expenditure, and offset data.
* `ato_irpd()`: International Related Party Dealings across
  annual packages from 2019-20 (Table 1 totals, Table 2 by
  jurisdiction, Table 3 chart-data index). Core BEPS and
  transfer-pricing dataset.

### Excise, small business, and education loans

* `ato_excise()`: excise rate schedule, Fuel Tax Credit rates,
  beer clearances, and spirits and other excisable beverages.
* `ato_sme_benchmarks()`: Small Business Benchmarks
  (industry-specific cost-to-turnover and related ratios).
* `ato_help()`: Study and Training Support Loan statistics
  covering HELP, AASL (Australian Apprenticeship Support
  Loans), and VSL (VET Student Loans).

### Extended coverage

* `ato_tax_expenditures()`: Treasury Tax Expenditures and
  Insights Statement (TEIS).
* `ato_fuel_tax_credits()`: FTC claims and rates.
* `ato_division293()`: Division 293 additional contributions
  tax data.
* `ato_prrt()`: Petroleum Resource Rent Tax aggregates.
* `ato_compliance()`: ATO compliance activity statistics.
* `ato_medicare_levy()`: Medicare Levy Surcharge aggregates.
* `ato_whm()`: Working Holiday Maker tax filings.

### Sibling helpers

* `ato_state_tax()`: ABS 5506.0 state and territory taxation.
* `ato_international()`: OECD Revenue Statistics.
* `ato_rba()`: RBA H1 Commonwealth Government Receipts.

## Reproducibility spine

* `ato_snapshot()`: pin a session snapshot date, recorded in
  every `ato_tbl` provenance header, manifest entry, and
  citation.
* `ato_sha256()`: SHA-256 digest of a file or in-memory object.
  Cached downloads carry a sidecar hash verified on every
  cache hit; drift warns with both hash prefixes.
* `ato_manifest()`, `ato_manifest_clear()`,
  `ato_manifest_write()`: session registry of every fetch
  (URL, CKAN IDs, SHA-256, size, timestamp, snapshot pin, R
  and ato versions). Output as data frame, YAML, JSON, or CSV
  for paper appendices.
* `ato_deposit_zenodo()`: stage a Zenodo deposit payload for
  the session manifest. Dry run by default; call with
  `upload = TRUE` and a `ZENODO_TOKEN` to mint a DOI.
* `ato_cite()`: citation helper producing plain text, BibTeX,
  or APA output from an `ato_tbl` or URL, with optional
  SHA-256 digest, snapshot date, and `doi =` argument.

## Harmonisation and reconciliation

* `ato_crosswalk()`: bundled classification and reference
  tables (ANZSIC 2006 to 2020, ANZSCO 2013 to 2021,
  postcode-state anchors, ABS CPI annual, ABS ERP annual,
  Final Budget Outcome reference totals).
* `ato_harmonise()`: rename columns to canonical names across
  multi-year panels using `ATO_COL_VARIANTS`.
* `ato_reconcile()`: compare an aggregate against the
  published Final Budget Outcome figure for the same year and
  measure; warns on gaps above 5 per cent.
* `ato_deflate()`: nominal AUD to real AUD in a base year
  using bundled ABS CPI.
* `ato_per_capita()`: divide by ABS ERP.

## Microdata bridge

* `ato_to_taxstats()`: rename columns between ATO aggregate
  schema and the `taxstats` 2 per cent microdata sample
  schema, in either direction.
* `ato_schema_map()`: return the full column-name mapping.

## Utilities

* `ato_cache_info()`, `ato_clear_cache()`: cache management.

## Data handling

* ATO confidentiality-suppression tokens (`np`, `n.p.`, `*`,
  and others) are coerced to `NA` by `ato_fetch_csv()` and
  `ato_fetch_xlsx()` so numeric columns stay numeric.
* XLSX header auto-detection: scans up to 15 rows to find the
  column-header row, handling ATO workbooks that lead with a
  title, narrative, or Notes sheet.
* Every returned `ato_tbl` carries provenance attributes
  (source URL, CC licence, retrieval time, title) exposed
  via `print()` and `ato_cite()`.

## Vignettes

* Reproducibility workflow (snapshot, manifest, SHA-256,
  Zenodo deposit).
* Panels, harmonisation, reconciliation, real terms, per
  capita.
* Interop with `grattan` and `taxstats`: costing a
  hypothetical reform.
* Canonical replications: top 1 per cent income share,
  corporate ETR by industry, tax gap trend, HELP debt by age
  cohort.

## Data source

Data is published by the Australian Taxation Office on
data.gov.au and ato.gov.au. Most Taxation Statistics datasets
are licensed under Creative Commons Attribution 2.5
Australia; Corporate Tax Transparency and the Voluntary Tax
Transparency Code are licensed under Creative Commons
Attribution 3.0 Australia. All downloads are cached locally
on first use.
