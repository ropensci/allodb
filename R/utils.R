abort_bad_class <- function(x) {
  .class <- glue_collapse(class(x), sep = ", ", last = ", or ")
  abort(glue("Can't deal with data of class: {.class}."))
}
