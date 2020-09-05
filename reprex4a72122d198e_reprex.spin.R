#' ---
#' output:
#'   md_document:
#'     pandoc_args:
#'       - '--from=markdown-implicit_figures'
#'       - '--to=commonmark'
#'       - '--wrap=preserve'
#' ---



#+ reprex-setup, include = FALSE
options(tidyverse.quiet = TRUE)
knitr::opts_chunk$set(collapse = TRUE, comment = "#>", error = TRUE)
knitr::opts_knit$set(upload.fun = knitr::imgur_upload)

#+ reprex-body
goodpractice::goodpractice()



#' <sup>Created on `r Sys.Date()` by the [reprex package](https://reprex.tidyverse.org) (v`r utils::packageVersion("reprex")`)</sup>


