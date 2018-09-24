collapse_match <- function(x, y, collapse) {
  paste0(sort(unique(x[x %in% y])), collapse = collapse)
}

row_collapse_match <- function(.data, y, collapse) {
  tibble::rowid_to_column(.data) %>%
    split(.$rowid) %>%
    purrr::map(unlist) %>%
    purrr::map(~.x[-1]) %>%
    purrr::map_chr(collapse_match, y, collapse)
}

