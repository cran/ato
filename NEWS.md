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
