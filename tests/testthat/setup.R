ato_tmp <- tempfile("ato_cache_")
dir.create(ato_tmp, recursive = TRUE, showWarnings = FALSE)
options(ato.cache_dir = ato_tmp)
