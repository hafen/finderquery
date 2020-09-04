


#' Filter categories
#' @param query ccc
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_category <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_category")

  term_filter(query, "category", terms)
}

#' Filter countries
#' @param query ccc
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_country <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_country")

  term_filter(query, "country", terms)
}

#' Filter bbb
#' @param query ccc
#' @export
filter_duplicate <- function(query, bool = FALSE) {
  check_class(query, c("query_facet", "query_fetch"), "filter_duplicate")

}

#' Filter bbb
#' @param query ccc
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_entityid <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_entityid")

  term_filter(query, "entityid", terms)
}

#' Filter bbb
#' @param query ccc
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_georssid <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_georssid")

  term_filter(query, "georssid", terms)
}

#' Filter bbb
#' @param query ccc
#' @export
filter_guid <- function(query, id) {
  check_class(query, c("query_facet", "query_fetch"), "filter_guid")

}

#' Filter bbb
#' @param query ccc
#' @export
filter_indexdate <- function(query, from = NULL, to = NULL, on = NULL) {
  check_class(query, c("query_facet", "query_fetch"), "filter_indexdate")

  date_filter(query, "indexdate", from, to, on)
}

#' Filter bbb
#' @param query ccc
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_language <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_language")

  term_filter(query, "language", terms)
}

#' Filter bbb
#' @param query ccc
#' @export
filter_pubdate <- function(query, from = NULL, to = NULL, on = NULL) {
  check_class(query, c("query_facet", "query_fetch"), "filter_pubdate")

  date_filter(query, "pubdate", from, to, on)
}

#' Filter bbb
#' @param query ccc
#' @export
filter_quoteabout <- function(query) {
  check_class(query, c("query_facet", "query_fetch"), "filter_quoteabout")

}

#' Filter bbb
#' @param query ccc
#' @export
filter_quotecategory <- function(query) {
  check_class(query, c("query_facet", "query_fetch"), "filter_quotecategory")

}

#' Filter bbb
#' @param query ccc
#' @export
filter_quotetext <- function(query) {
  check_class(query, c("query_facet", "query_fetch"), "filter_quotetext")

}

#' Filter bbb
#' @param query ccc
#' @export
filter_quotewho <- function(query) {
  check_class(query, c("query_facet", "query_fetch"), "filter_quotewho")

}



#' Filter bbb
#' @param query ccc
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_source <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_source")

  term_filter(query, "source", terms)
}

#' Filter bbb
#' @param query ccc
#' @export
filter_text <- function(query) {
  check_class(query, c("query_facet", "query_fetch"), "filter_text")

}

#' Filter bbb
#' @param query ccc
#' @export
filter_tonality <- function(query, value = NULL, from = NULL, to = NULL) {
  check_class(query, c("query_facet", "query_fetch"), "filter_tonality")

  # range from -4 to 4??

  # search for rssitems with a tonality of -4
  # tonality:"-4"

  # search for rssitems with a positive tonality
  # tonality:[1 TO *]
}



term_filter <- function(query, var, terms) {
  res <- paste0(var, ":(", enc(paste(terms, collapse = " ")), ")")
  query$filters <- c(query$filters, list(res))
  query
}

fix_date <- function(x) {
  if (inherits(x, c("Date", "POSIXct"))) {
    x <- paste0(as.Date(x), "T", format(x, "%H:%M:%S"), "Z")
  } else if (is.null(x)) {
    x <- "*"
  }
  x
}

date_filter <- function(query, var, from, to, on) {
  if (!is.null(on)) {
    res <- paste0(var, ":", fix_date(on))
  } else {
    res <- paste0(var, ":[", fix_date(from), " TO ", fix_date(to), "]")
  }
  query$filters <- c(query$filters, list(enc(res)))
  query
}


# No operator   makes the clause that follows optional (this is the default).

# search for rssitems with category brussels, or with category CRIME, or with category EmmPanorama

# category:brussels category:CRIME category:EmmPanorama
# category:(brussels CRIME EmmPanorama)
# The operator +
# The operator + makes the clause that follows required.

# search for rssitems with all the given categories

# +category:brussels +category:CRIME +category:EmmPanorama
# category:(+brussels +CRIME +EmmPanorama)
# The operator -
# The operator - makes the clause that follows prohibited.

# search for rssitems with category brussels, and with category CRIME, and without category EmmPanorama

# +category:brussels +category:CRIME -category:EmmPanorama
# category:(+brussels +CRIME -EmmPanorama)






# # filters can be applied to both fetch and aggregate queries

# # https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl-range-query.html

# #' Specify a range filter
# #'
# #' @param query a [query_agg()] or [query_fetch()] object
# #' @param field field name (see [queryable_fields()] for all possibilities)
# #' @param from the lower value of the range
# #' @param to the upper value of the range
# #' @export
# filter_range <- function(
#   query, field, from = NULL, to = NULL
# ) {
#   check_class(query, c("query_agg", "query_fetch"), "filter_range")
#   check_fields(query, field, "filter_range")
#   # TODO: make sure variable is numeric or date
#   # long, integer, short, byte, double, float, half_float, scaled_float

#   res <- list(
#     range = list()
#   )
#   res$range[[field]] <- list()
#   if (!is.null(from))
#     res$range[[field]]$gte <- from
#   if (!is.null(to))
#     res$range[[field]]$lte <- to

#   query$filters <- c(query$filters, list(res))
#   query
# }
# # { "range": { "processedOnDate": { "gte": "2020-02-01" }}}

# #' Specify a match filter
# #'
# #' @param query a [query_agg()] or [query_fetch()] object
# #' @param field field name (see [queryable_fields()] for all possibilities)
# #' @param match a string to match
# #' @export
# filter_match <- function(query, field, match) {
#   check_class(query, c("query_agg", "query_fetch"), "filter_match")
#   check_fields(query, field, "filter_match")
#   res <- list(
#     match = list()
#   )
#   res$match[[field]] <- match

#   query$filters <- c(query$filters, list(res))
#   query
# }
# # { "match": { "fullText": "and" }},

# #' Specify a regexp filter
# #'
# #' @param query a [query_agg()] or [query_fetch()] object
# #' @param field field name (see [queryable_fields()] for all possibilities)
# #' @param regexp a regular expression string to match
# #' @export
# filter_regexp <- function(query, field, regexp) {
#   check_class(query, c("query_agg", "query_fetch"), "filter_match")
#   check_fields(query, field, "filter_regexp")

#   res <- list(
#     regexp = list()
#   )
#   res$regexp[[field]] <- regexp

#   query$filters <- c(query$filters, list(res))
#   query
# }

# #' Specify a terms filter
# #'
# #' @param query a [query_agg()] or [query_fetch()] object
# #' @param field field name (see [queryable_fields()] for all possibilities)
# #' @param terms a string or vector of strings to exact match
# #' @importFrom jsonlite toJSON
# #' @export
# filter_terms <- function(query, field, terms) {
#   check_class(query, c("query_agg", "query_fetch"), "filter_terms")
#   check_fields(query, field, "filter_terms")

#   tm <- ifelse(length(terms) == 1, "term", "terms")
#   res <- list()
#   res[[tm]] <- list()
#   res[[tm]][[field]] <- terms

#   query$filters <- c(query$filters, list(res))
#   query
# }

# # { "term":  { "languageCode": "en" }},
# # { "terms":  { "languageCode": ["en", "au"] }},

# # logic = c("and", "or", "not")
