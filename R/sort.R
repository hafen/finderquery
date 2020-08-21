
#' Specify field to sort on
#' @export
sort_by <- function(query, field, asc = TRUE) {
  # TODO: make sure field is valid
  query$sort <- c(query$sort,
    list(paste0(field, "+", ifelse(asc, "asc", "desc"))))
  query
}
