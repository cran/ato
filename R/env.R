# Package-level environment for session state (manifest registry,
# snapshot pin). Created at load time by .onLoad().

#' @noRd
.ato_env <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  .ato_env$manifest <- list()
  invisible(NULL)
}
