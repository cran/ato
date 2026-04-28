# Zenodo deposit: mint a DOI for the session manifest so a paper
# can cite "ATO data snapshot, Zenodo DOI 10.5281/zenodo.XXXX".
# This is the gold-standard reproducibility hook.

#' Prepare a Zenodo deposit payload for the session manifest
#'
#' Builds the JSON metadata payload Zenodo expects for a data
#' deposit, using the current `ato_manifest()` and the snapshot
#' pin set via [ato_snapshot()]. The function does NOT upload by
#' default; it returns the payload and saved manifest path so
#' you can inspect before calling with `upload = TRUE`.
#'
#' To upload, supply a Zenodo personal access token via the
#' `ZENODO_TOKEN` environment variable (or the `token` argument).
#' Tokens can be generated at
#' <https://zenodo.org/account/settings/applications/>.
#'
#' @param title Deposit title. Defaults to "ATO data snapshot
#'   YYYY-MM-DD" using the current snapshot pin.
#' @param description Free-text description. Defaults to a short
#'   auto-generated note listing the datasets fetched.
#' @param creators List of creator records. Each should be a list
#'   with `name`, optional `affiliation`, `orcid`. Defaults to a
#'   single anonymous entry; override for published work.
#' @param keywords Character vector of keywords. Defaults to
#'   `c("ATO", "taxation", "Australia", "reproducibility")`.
#' @param upload Logical; if `TRUE`, POSTs the deposit to Zenodo
#'   and uploads the manifest CSV. Default `FALSE` (dry run).
#' @param sandbox Logical; if `TRUE`, uses Zenodo Sandbox
#'   (sandbox.zenodo.org) for testing. Default `FALSE`.
#' @param token Zenodo personal access token. Defaults to
#'   `Sys.getenv("ZENODO_TOKEN")`.
#'
#' @return A list with `payload` (the JSON metadata), `manifest_path`
#'   (where the CSV manifest was staged), and if `upload = TRUE`,
#'   `deposit_id`, `doi_prereserve`, and `url`.
#'
#' @family reproducibility
#' @export
#' @examples
#' \donttest{
#' ato_snapshot("2026-04-24")
#' ato_deposit_zenodo(
#'   title = "ATO data snapshot for working paper v1",
#'   creators = list(list(name = "Coverdale, Charles")),
#'   upload = FALSE
#' )
#' }
ato_deposit_zenodo <- function(title = NULL,
                                description = NULL,
                                creators = list(list(name = "Anonymous")),
                                keywords = c("ATO", "taxation",
                                             "Australia",
                                             "reproducibility"),
                                upload = FALSE,
                                sandbox = FALSE,
                                token = Sys.getenv("ZENODO_TOKEN")) {
  man <- ato_manifest("df")
  if (nrow(man) == 0L) {
    cli::cli_warn(c(
      "Session manifest is empty.",
      "i" = "Fetch some datasets (e.g. {.code ato_individuals()}) first."
    ))
  }

  snap <- ato_snapshot_str()
  if (is.null(title) || is.na(title)) {
    title <- sprintf(
      "ATO data snapshot %s",
      if (!is.na(snap)) snap else format(Sys.Date(), "%Y-%m-%d")
    )
  }
  if (is.null(description) || is.na(description)) {
    description <- sprintf(
      paste0("Snapshot of %d Australian Taxation Office dataset(s) ",
             "fetched via the 'ato' R package (v%s). Snapshot date: %s. ",
             "Datasets: %s."),
      nrow(man), utils::packageVersion("ato"),
      if (!is.na(snap)) snap else "unset",
      paste(unique(man$title), collapse = "; ")
    )
  }

  payload <- list(
    metadata = list(
      title = title,
      description = description,
      upload_type = "dataset",
      creators = creators,
      keywords = as.list(keywords),
      license = "cc-by-4.0",
      access_right = "open",
      related_identifiers = lapply(unique(man$url), function(u) {
        list(identifier = u, relation = "isDerivedFrom", scheme = "url")
      })
    )
  )

  manifest_path <- file.path(tempdir(),
                              paste0("ato_manifest_",
                                     format(Sys.time(), "%Y%m%d_%H%M%S"),
                                     ".csv"))
  ato_manifest_write(manifest_path, format = "csv")

  result <- list(payload = payload, manifest_path = manifest_path)

  if (!isTRUE(upload)) {
    cli::cli_inform(c(
      "v" = "Dry run: payload built, manifest staged at {.path {manifest_path}}.",
      "i" = "Call with {.code upload = TRUE} to deposit to Zenodo."
    ))
    return(invisible(result))
  }

  if (!nzchar(token)) {
    cli::cli_abort(c(
      "No Zenodo token.",
      "i" = "Set {.envvar ZENODO_TOKEN} or pass {.arg token}."
    ))
  }

  base <- if (isTRUE(sandbox)) {
    "https://sandbox.zenodo.org/api"
  } else {
    "https://zenodo.org/api"
  }

  create_url <- sprintf("%s/deposit/depositions", base)
  resp <- httr2::request(create_url) |>
    httr2::req_headers(Authorization = paste("Bearer", token)) |>
    httr2::req_body_json(payload) |>
    httr2::req_method("POST") |>
    httr2::req_error(is_error = function(r) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(resp) >= 400L) {
    cli::cli_abort(c(
      "Zenodo returned HTTP {httr2::resp_status(resp)}.",
      "x" = httr2::resp_body_string(resp)
    ))
  }

  deposit <- jsonlite::fromJSON(httr2::resp_body_string(resp),
                                 simplifyVector = FALSE)
  upload_url <- deposit$links$bucket %||%
                sprintf("%s/files", deposit$links$self)

  file_resp <- httr2::request(sprintf("%s/%s", upload_url,
                                       basename(manifest_path))) |>
    httr2::req_headers(Authorization = paste("Bearer", token)) |>
    httr2::req_method("PUT") |>
    httr2::req_body_file(manifest_path) |>
    httr2::req_perform()

  if (httr2::resp_status(file_resp) >= 400L) {
    cli::cli_warn(c(
      "Manifest upload returned HTTP {httr2::resp_status(file_resp)}.",
      "i" = "Deposit created but file upload failed. Complete manually."
    ))
  }

  cli::cli_inform(c(
    "v" = "Zenodo deposit created.",
    "i" = "DOI (pre-reserved): {.val {deposit$metadata$prereserve_doi$doi}}",
    "i" = "Review and publish at {.url {deposit$links$html}}"
  ))

  result$deposit_id <- deposit$id
  result$doi_prereserve <- deposit$metadata$prereserve_doi$doi
  result$url <- deposit$links$html
  invisible(result)
}
