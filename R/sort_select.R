#' Specify field to sort on
#' @export
sort_by <- function(query, field, asc = TRUE) {
  if (!tolower(field) %in% tolower(queryable_fields()))
    stop("'sort_by' field: ", field, " is not a queryable/sortable field name.",
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
    nu <- setdiff(fields, selectable_fields())
    if (length(nu) > 0)
      message("Ignoring invalid fields specified in 'select_fields': ",
        paste(nu, collapse = ", "))
    fields <- intersect(fields, selectable_fields())
  }
  query$select <- fields
  query
}

#' Valid fields that can be selected
#' @export
selectable_fields <- function() {
  c("category", "contentType", "description", "enclosure", "entity", 
    "favicon", "fullgeo", "georss", "guid", "keyword", "language", 
    "link", "location", "pubDate", "quote", "relevance", "source", 
    "text", "title", "tonality", "translate")
}

# # get a feel for valid fields found in the data
# res <- query_fetch(con, max = 5000) %>%
#   run()
# sort(unique(unlist(lapply(res, names))))
