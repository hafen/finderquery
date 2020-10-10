#' Initialize a document fetch query
#'
#' @param con A finder connection object from [finder_connect()].
#' @export
query_facet <- function(con) {
  structure(list(
    con = con,
    filters = list()
  ), class = c("es_query", "query_facet"))
}

#' Specify a field to facet by
#' @param query a [query_facet()] object
#' @param field field name or vector of two field names
#'   (see [facetable_fields()] for all possibilities)
#' @param sort Controls how faceted results are sorted.
# sort: Sort the constraints by count (highest count first).
# index: Return the constraints sorted in their index order (lexicographic by indexed term). For terms in the ASCII range, this will be alphabetically sorted.
#' @param limit Controls how many constraints should be returned for each facet.
#' @param offset Specifies an offset into the facet results at which to begin displaying facets.
#' @param mincount Specifies the minimum counts required for a facet field to be included in the response.
#' @export
facet_by <- function(query,
  field, limit = -1, sort = c("count", "index"), mincount = 0, offset = 0
) {
  check_class(query, c("query_facet"), "facet_by")
  sort <- match.arg(sort)

  if (!all(field %in% facetable_fields()))
    stop("'facet_by()' field name is not one of the values found in ",
      "facetable_fields().")

  if (!is.null(query$facet))
    message("Replacing previously-specified facet specification")

  if (length(field) > 2)
    stop("'facet_by()' can only have one or two fields specified.")

  query$facet <- list(
    type = ifelse(length(field) == 1, "field", "pivot"),
    field = field,
    limit = limit,
    sort = sort,
    mincount = mincount,
    offset = offset
  )

  if (query$facet$type == "pivot") {
    query$facet$pivot <- paste(query$facet$field, collapse = ",")
    query$facet$field <- NULL
  }

  query
}

#' Get a list of facetable fields
#' @export
facetable_fields <- function() {
  c("language", "category", "country", "source", "quotewho",
    "quotecategory", "duplicate")
}



# all existing values for source, with corresponding count
#   rows=0 facet=true facet.field=source facet.limit=-1 facet.mincount=1 facet.method=fcs native=true *:*
# aa <- query_str(con, "op=search&q=*%3A*&facet.field=source&rows=0&facet=true&facet.limit=-1&facet.mincount=1&facet.method=fcs&native=true", format = "xml") %>%
#   run()

# top 10 (based on count) existing values for source, with corresponding count, sorted by count
#   rows=0 facet=true facet.field=source facet.limit=10 facet.sort=count facet.method=fcs native=true *:*
# aa <- query_str(con, "op=search&q=*%3A*&facet.sort=count&facet.field=source&rows=0&facet=true&facet.limit=10&facet.method=fcs&native=true", format = "xml") %>%
#   run()

# all existing values for source, with corresponding count, for rssitem from Germany, in German, published in the last 7 days

# rows=0 facet=true facet.field=source facet.limit=-1 facet.method=fcs native=true +country:DE +language:de fq=pubdate:[NOW/DAY-7DAY TO *]

# aa <- query_str(con, "op=search&q=%2Bcountry%3ADE%20%2Blanguage%3Ade&facet.field=source&fq=pubdate%3A%5BNOW%2FDAY-7DAY%20TO%20*%5D&rows=0&facet=true&facet.limit=-1&facet.method=fcs&native=true", format = "xml") %>%
#   run()



# #' Title
# #' @export
# facet_range <- function(con, start, end, gap) {

# }

#' Specify a 'gap' parameter for facet_range queries
#' @param num the number of units to use for a date gap
#' @param units the units to use for a date gap, one of "DAY", "MINUTE", "HOUR", "WEEK", "MONTH", "YEAR"
#' @export
range_gap <- function(
  num = 1,
  units = c("DAY", "MINUTE", "HOUR", "WEEK", "MONTH", "YEAR")
) {
  units <- match.arg(units)
  structure(paste0("+", num, units, ifelse(num > 1, "S", "")),
    class = c("character", "range_gap"))
}

#' Specify a date range facet
#' @param query a [query_facet()] object
#' @param field field name (one of "pubdate" or "indexdate")
#' @param start start date
#' @param end end date
#' @param gap gap object from [range_gap()]
#' @export
facet_date_range <- function(query, field = c("pubdate", "indexdate"), start, end, gap) {
  check_class(query, c("query_facet"), "facet_by")

  field <- match.arg(field)

  if (!inherits(gap, "range_gap"))
    stop("Parameter 'gap' must be specified through range_gap()", call. = FALSE)

  query$facet <- list(
    type = "date_range",
    field = field,
    start = fix_date(start),
    end = fix_date(end),
    gap = gap
  )

  query
}

# *%3A*&fq=pubdate%3A%5BNOW%2FDAY-2MONTH%20TO%20*%5D&rows=0&facet=true&facet.range=pubdate&facet.range.start=NOW%2FDAY-2MONTH&facet.range.gap=%2B1DAY&facet.range.end=NOW&native=true

# *:*&fq=pubdate:[NOW/DAY-2MONTH TO *]&rows=0&facet=true&facet.range=pubdate&facet.range.start=NOW/DAY-2MONTH&facet.range.gap=+1DAY&facet.range.end=NOW&native=true


#    /HOUR
#       ... Round to the start of the current hour
#    /DAY
#       ... Round to the start of the current day
#    +2YEARS
#       ... Exactly two years in the future from now
#    -1DAY
#       ... Exactly 1 day prior to now
#    /DAY+6MONTHS+3DAYS
#       ... 6 months and 3 days in the future from the start of
#           the current day
#    +6MONTHS+3DAYS/DAY
#       ... 6 months and 3 days in the future from now, rounded
#           down to nearest day
 
# (Multiple aliases exist for the various units of time (ie: MINUTE and MINUTES; MILLI, MILLIS, MILLISECOND, and MILLISECONDS.) The complete list can be found by inspecting the keySet of CALENDAR_UNITS)

