#' Specify field to sort on
#' @param query a [fq_query_fetch()] object
#' @param field the field name to sort by (see [fq_queryable_fields()])
#' @param asc if TRUE, will sort ascending, if FALSE, descending
#' @export
fq_sort_by <- function(query, field, asc = TRUE) {
  check_class(query, c("query_fetch"), "sort_by")

  if (!tolower(field) %in% tolower(fq_queryable_fields()))
    stop("'sort_by' field: ", field, " is not a queryable/sortable field name.",
      call. = FALSE)

  query$sort <- c(query$sort,
    list(paste0(field, "+", ifelse(asc, "asc", "desc"))))
  query
}

#' Specify fields to return in the results
#' @param query a [fq_query_fetch()] object
#' @param fields a vector of field names (see [fq_selectable_fields()])
#' @export
fq_select_fields <- function(query, fields = NULL) {
  if (length(query$select) > 0)
    message("Overwriting previously-specified fields to select")
  if (!is.null(fields)) {
    nu <- setdiff(fields, fq_selectable_fields())
    if (length(nu) > 0)
      message("Ignoring invalid fields specified in 'select_fields': ",
        paste(nu, collapse = ", "))
    fields <- intersect(fields, fq_selectable_fields())
  }
  query$select <- fields
  query
}

#' Valid fields that can be selected
#' @export
fq_selectable_fields <- function() {
  c("category", "contentType", "description", "enclosure", "entity", 
    "favicon", "fullgeo", "georss", "guid", "keyword", "language", 
    "link", "location", "pubDate", "quote", "relevance", "source", 
    "text", "title", "tonality", "translate")
}

# # get a feel for valid fields found in the data
# res <- fq_query_fetch(con, max = 5000) %>%
#   fq_run()
# sort(unique(unlist(lapply(res, names))))
