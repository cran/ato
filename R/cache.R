# Cache management

#' @noRd
ato_cache_dir <- function() {
  d <- getOption("ato.cache_dir",
                 default = tools::R_user_dir("ato", "cache"))
  if (!dir.exists(d)) dir.create(d, recursive = TRUE)
  d
}

#' Clear the ato cache
#'
#' Deletes all locally cached files. The next call to any data
#' function will re-download.
#'
#' @return Invisibly returns `NULL`.
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' ato_clear_cache()
#' options(op)
#' }
ato_clear_cache <- function() {
  d <- ato_cache_dir()
  files <- list.files(d, full.names = TRUE)
  n <- length(files)
  if (n > 0L) unlink(files, recursive = TRUE)
  cli::cli_inform("Removed {n} cached file{?s} from {.path {d}}.")
  invisible(NULL)
}

#' Check whether a CKAN package has been updated since the cache was last written
#'
#' Only runs when `options(ato.check_staleness = TRUE)`. Silently no-ops on
#' network error so it never blocks data retrieval.
#' @noRd
ato_check_staleness <- function(package_id) {
  if (!isTRUE(getOption("ato.check_staleness", FALSE))) return(invisible(NULL))
  tryCatch({
    pkg <- ato_ckan_package(package_id)
    modified <- pkg$metadata_modified %||% ""
    if (!nzchar(modified)) return(invisible(NULL))
    modified_time <- as.POSIXct(modified, format = "%Y-%m-%dT%H:%M:%S",
                                 tz = "UTC")
    d <- ato_cache_dir()
    files <- list.files(d, full.names = TRUE)
    if (length(files) == 0L) return(invisible(NULL))
    oldest_mtime <- min(file.info(files)$mtime)
    if (!is.na(modified_time) && modified_time > oldest_mtime) {
      cli::cli_warn(c(
        "ATO has updated {.val {package_id}} since your cache was last refreshed.",
        "i" = "Run {.code ato_clear_cache()} and re-fetch to get the latest data."
      ))
    }
  }, error = function(e) invisible(NULL))
  invisible(NULL)
}

#' Inspect the local ato cache
#'
#' @return A list with `dir`, `n_files`, `size_bytes`,
#'   `size_human`, and `files`.
#' @family configuration
#' @export
#' @examples
#' \donttest{
#' op <- options(ato.cache_dir = tempdir())
#' ato_cache_info()
#' options(op)
#' }
ato_cache_info <- function() {
  d <- ato_cache_dir()
  empty <- data.frame(
    name = character(0L),
    size_bytes = numeric(0L),
    modified = as.POSIXct(character(0L)),
    stringsAsFactors = FALSE
  )
  paths <- list.files(d, full.names = TRUE)
  if (length(paths) == 0L) {
    return(list(dir = d, n_files = 0L, size_bytes = 0,
                size_human = "0 B", files = empty))
  }
  info <- file.info(paths)
  files <- data.frame(
    name = basename(paths),
    size_bytes = info$size,
    modified = info$mtime,
    stringsAsFactors = FALSE
  )
  files <- files[order(-files$size_bytes), , drop = FALSE]
  rownames(files) <- NULL
  total <- sum(files$size_bytes)
  list(dir = d, n_files = nrow(files), size_bytes = total,
       size_human = ato_format_bytes(total), files = files)
}
