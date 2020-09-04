
#' Specify field to sort on
#' @export
sort_by <- function(query, field, asc = TRUE) {
  if (!tolower(field) %in% tolower(valid_fields()))
    stop("'sort_by' field: ", field, " is not a valid field name.",
      call. = FALSE)

  query$sort <- c(query$sort,
    list(paste0(field, "+", ifelse(asc, "asc", "desc"))))
  query
}


#' Specify fields to return in the results
#' @export
select_fields <- function(query, fields = NULL) {
  if (length(query$select) > 0)
    message("Overwriting previously-specified fields to select")
  if (!is.null(fields)) {
    nu <- setdiff(fields, valid_fields())
    if (length(nu) > 0)
      message("Ignoring invalid fields specified in 'select_fields': ",
        paste(nu, collapse = ", "))
    fields <- intersect(fields, valid_fields())
  }
  query$select <- fields
  query
}

#' Valid fields that can be selected
#' @export
valid_fields <- function() {
  c("title", "link", "description", "contentType", "pubDate", "source", 
    "language", "guid", "category", "favicon", "entity", "georss", 
    "fullgeo", "tonality", "text", "quote", "enclosure", "translate", 
    "keyword", "location", "relevance")
}
