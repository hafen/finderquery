#' Filter categories
#' @param query a [query_fetch()] or [query_facet()] object
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_category <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_category")

  term_filter(query, "category", terms)
}

#' Filter countries
#' @param query a [query_fetch()] or [query_facet()] object
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_country <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_country")

  term_filter(query, "country", terms)
}

#' Filter duplicate
#' @param query a [query_fetch()] or [query_facet()] object
#' @param bool TRUE or FALSE
#' @export
filter_duplicate <- function(query, bool = FALSE) {
  check_class(query, c("query_facet", "query_fetch"), "filter_duplicate")

  term <- ifelse(bool, "true", "false")
  term_filter(query, "duplicate", term)
}

#' Filter entityid
#' @param query a [query_fetch()] or [query_facet()] object
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_entityid <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_entityid")

  term_filter(query, "entityid", terms)
}

#' Filter georssid
#' @param query a [query_fetch()] or [query_facet()] object
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_georssid <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_georssid")

  term_filter(query, "georssid", terms)
}

#' Filter guid
#' @param query a [query_fetch()] or [query_facet()] object
#' @param value guid to filter
#' @export
filter_guid <- function(query, value) {
  check_class(query, c("query_facet", "query_fetch"), "filter_guid")

  query$filters <- c(query$filters, list(enc(paste0("guid:", value))))
  query
}

#' Filter indexdate
#' @param query a [query_fetch()] or [query_facet()] object
#' @param from start date
#' @param to end date
#' @param on exact date (if specified, from and to are ignored)
#' @export
filter_indexdate <- function(query, from = NULL, to = NULL, on = NULL) {
  check_class(query, c("query_facet", "query_fetch"), "filter_indexdate")

  date_filter(query, "indexdate", from, to, on)
}

#' Filter language
#' @param query a [query_fetch()] or [query_facet()] object
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_language <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_language")

  term_filter(query, "language", terms)
}

#' Filter pubdate
#' @param query a [query_fetch()] or [query_facet()] object
#' @param from start date
#' @param to end date
#' @param on exact date (if specified, from and to are ignored)
#' @export
filter_pubdate <- function(query, from = NULL, to = NULL, on = NULL) {
  check_class(query, c("query_facet", "query_fetch"), "filter_pubdate")

  date_filter(query, "pubdate", from, to, on)
}

# #' Filter quoteabout
# #' @param query a [query_fetch()] or [query_facet()] object
# #' @export
# filter_quoteabout <- function(query) {
#   check_class(query, c("query_facet", "query_fetch"), "filter_quoteabout")

#   term_filter(query, "quoteabout", terms)
# }

# #' Filter quotecategory
# #' @param query a [query_fetch()] or [query_facet()] object
# #' @export
# filter_quotecategory <- function(query, terms) {
#   check_class(query, c("query_facet", "query_fetch"), "filter_quotecategory")

#   term_filter(query, "quotecategory", terms)
# }

# #' Filter quotetext
# #' @param query a [query_fetch()] or [query_facet()] object
# #' @export
# filter_quotetext <- function(query) {
#   check_class(query, c("query_facet", "query_fetch"), "filter_quotetext")
# }

# #' Filter quotewho
# #' @param query a [query_fetch()] or [query_facet()] object
# #' @export
# filter_quotewho <- function(query, terms) {
#   check_class(query, c("query_facet", "query_fetch"), "filter_quotewho")

#   term_filter(query, "quotewho", terms)
# }

#' Filter source
#' @param query a [query_fetch()] or [query_facet()] object
#' @param terms A vector of search terms. If preceded with a "+", (e.g. "+de"), then this term is required to be in the result. If preceded with "-", (e.g. "-en"), then this term is prohibited from appearing in the result.
#' @export
filter_source <- function(query, terms) {
  check_class(query, c("query_facet", "query_fetch"), "filter_source")

  term_filter(query, "source", terms)
}

#' Filter based on text found in title, description, or text, including 
#'   translations
#' @param query a [query_fetch()] or [query_facet()] object
#' @param text text to filter
#' @export
filter_text <- function(query, text) {
  check_class(query, c("query_facet", "query_fetch"), "filter_text")

  if (length(text) > 1) {
    text <- paste(paste0("+{!babel t=", text, "}"), collapse = " ")
  } else {
    text <- paste0("{!babel t=", text, "}")
  }

  if (!is.null(query$filter_text))
    message("Replacing previously-specified text filter specification")

  query$filter_text <- enc(text)
  query
}

#' Filter tonality
#' @param query a [query_fetch()] or [query_facet()] object
#' @param value exact tonality value to filter on (if specified, from and to are ignored)
#' @param from lower range to filter on
#' @param to upper range to filter on
#' @export
filter_tonality <- function(query, value = NULL, from = NULL, to = NULL) {
  check_class(query, c("query_facet", "query_fetch"), "filter_tonality")

  # RANGE
  # search for rssitems with a tonality of -4
  # tonality:"-4"
  # search for rssitems with a positive tonality
  # tonality:[1 TO *]

  if (!is.null(value)) {
    res <- paste0("tonality", ":", enc(as.character(value)))
  } else {
    from <- ifelse(is.null(from), "*", from)
    to <- ifelse(is.null(to), "*", to)
    res <- paste0("tonality", ":[", from, " TO ", to, "]")
  }
  query$filters <- c(query$filters, list(enc(res)))
  query
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



# Category
# description
# the list of category ids associated with the rssitem
# formal
# /channel/item/category/text()
# concat(/channel/item/category/@domain, '/', /channel/item/category/text())
# field name
# category
# case
# case insensitive (original data is CamelCase)
# Examples
# search for rssitems with the given category

# category:brussels
# search for rssitems with the given category of the given domain

# category:ep/theme_ep
# search for rssitems with any of the given categories

# category:(brussels CRIME EmmPanorama)
# search for rssitems with all the given categories

# category:(+brussels +CRIME +EmmPanorama)
# search for rssitems with some categories and not some other categories

# category:(+brussels +CRIME -EmmPanorama)
# search for rssitems with some category given a category id pattern

# category:Agricult*
# category:*Agriculture
# search for rssitems with zero category

# -category:[* TO *]


# Country
# description
# the country of the rssitem's source
# formal
# /channel/item/source/@country
# field name
# country
# case
# case insensitive (original data is UPPERCASE)
# Examples
# search for rssitems from the given country

# country:DE
# search for rssitems from given countries

# country:(DE GB FR)

# Duplicate
# description
# whether the rssitem was marked as duplicate (by the duplicate detector) or not
# formal
# boolean(/channel/item/@duplicate)
# field name
# duplicate
# case
# does not apply (indexed data is a boolean)
# Examples
# search for rssitems which are not duplicate

# duplicate:false


# Entity id
# description
# the list of entity ids associated with the rssitem
# formal
# /channel/item/emm:entity/@id
# field name
# entityid
# case
# case sensitive (because it is saved as text, not as numeric)
# Examples
# search for rssitems with the given entity

# entityid:2
# search for rssitems with any of the given entities

# entityid:(2 1510 10101)
# search for rssitems with all the given entities

# entityid:(+2 +1510 +10101)
# search for rssitems with some entities and not some other entities

# entityid:(+2 +1510 -10101)
# search for rssitems with zero entity

# -entityid:[* TO *]


# Location id
# description
# the list of geographical location ids associated with the rssitem
# formal
# /channel/item/emm:georss/@id
# /channel/item/emm:fullgeo[not(@adjective)]/@id
# field name
# georssid
# case
# case sensitive (because it is saved as text, not as numeric)
# note
# Finder indexes in this field also the fullgeo which are not adjective
# Examples
# search for rssitems with the given location

# georssid:2
# search for rssitems with any of the given locations

# georssid:(2 1510 10101)
# search for rssitems with all the given locations

# georssid:(+2 +1510 +10101)
# search for rssitems with some locations and not some other locations

# georssid:(+2 +1510 -10101)
# search for rssitems with zero location

# -georssid:[* TO *]


# Guid
# description
# the rssitem's guid (this is also the "primary key")
# formal
# /channel/item/guid/text()
# field name
# guid
# case
# case insensitive (original data is CamelCase)
# Examples
# search for the rssitem with the given guid

# +guid:washtimes-7f385f3952f946008efbb02b94882163 +pubdate:[* TO *]
# search for the rssitem of the given source
# note: both clauses are correct, but the second one is much more efficient than the first one

# guid:washtimes-*
# source:washtimes


# Index date
# description
# the date (timestamp) at which the document has been indexed (or reindexed) within Solr
# field name
# indexdate
# see
# this field syntax is the same as for pubdate


# Language
# description
# the rssitem's language
# formal
# /channel/item/iso:language/text()
# field name
# language
# case
# case insensitive (original data is lowercase)
# Examples
# search for rssitems from the given language

# language:de
# search for rssitems from given languages

# language:(de en fr)


# Publication date
# description
# the rssitem's pubdate (timestamp)
# formal
# /channel/item/pubDate/text()
# field name
# pubdate
# case
# does not apply
# nevertheless, TO keyword in range clauses, T and Z, keywords of DateMathParser are case sensitive
# Examples
# Timestamp format is described here. Some of these examples use DateMathParser syntax. In both cases, the default TimeZone used is UTC (this impacts rounding, for instance).

# search for rssitems published on the given timestamp

# pubdate:"2014-03-15T20:50:00Z"
# pubdate:"2014-03-15T20:50:00Z/DAY-1DAY"
# search for rssitems published on the given day

# pubdate:[2014-03-15T00:00:00Z TO 2014-03-15T23:59:59Z]
# pubdate:[2014-03-15T07:07:07Z/DAY TO 2014-03-15T07:07:07Z/DAY+24HOUR-1SECOND]
# wrong syntax to search for rssitems published on the given day

# pubdate:2014-03-15T*
# search for rssitems published within the given time range

# pubdate:[2014-03-01T00:00:00Z TO 2014-03-01T23:59:59Z]
# search for rssitems published in the last 30 days

# pubdate:[NOW/DAY-30DAY TO NOW+1DAY/DAY]
# pubdate:[NOW/DAY-30DAY TO *]
# search for rssitems published in the last year

# pubdate:[NOW-1YEAR/DAY TO NOW/DAY+1DAY]
# search for rssitems published from the beginning of the previous month up to now

# pubdate:[NOW/DAY/MONTH-1MONTH TO NOW/DAY/MONTH-1SECOND]
# get statistics on rssitems' publication date for rssitems from the given language

# language:de stats=true
# language:de stats=true stats.field=pubdate rows=0 native=true


# Quote about
# description
# the entity id mentionned within the quote of the rssitem
# formal
# /channel/item/emm:quote/@about
# field name
# quoteabout
# see
# this field syntax is the same as for quotewho


# Quote category
# description
# the list of category ids associated with the quote text of the rssitem
# formal
# tokenize(/channel/item/emm:quote/@categories,',')
# field name
# quotecategory
# see
# this field syntax is the same as for category
# note
# quotes are indexed as nested objects of the parent object (=the rssitem they belong to); the query syntax for nested objects is described here


# Quote text
# description
# the text of the quote of the rssitem
# formal
# /channel/item/emm:quote/text()
# field name
# quotetext
# see
# this field syntax is the same as for text
# note
# quotes are indexed as nested objects of the parent object (=the rssitem they belong to); the query syntax for nested objects is described here


# Quote who
# description
# the entity id of the quote of the rssitem
# formal
# /channel/item/emm:quote/@who
# field name
# quotewho
# see
# this field syntax is the same as for entityid
# note
# quotes are indexed as nested objects of the parent object (=the rssitem they belong to); the query syntax for nested objects is described here


# Source
# description
# the rssitem's source
# formal
# /channel/item/source/text()
# field name
# source
# case
# case insensitive (original data is CamelCase)
# Examples
# search for rssitems from the given source

# source:zeit
# search for rssitems from given sources

# source:(zeit THETIMES LeMonde)
# search for rssitems with some source given a source pattern

# source:bbc*
# source:*news


# Text
# description
# the rssitem's title description text, in the original language, and in any translation produced by the translation system
# formal
# concat(/channel/item/title/text(), /channel/item/description/text(), /channel/item/emm:text/text(), /channel/item/emm:title/text(), /channel/item/emm:description/text(), /channel/item/emm:translate/text())
# field name
# text
# case
# case insensitive (original data is mixed case)
# note
# text search is sometimes influenced by the language you possibly specify as language parameter l= or with a language clause language:de or language:(de en fr)
# Examples
# these examples are influenced by the language clause, and are case insensitive
# search for rssitems having the given keyword

# {!babel t=european}
# search for rssitems having the given keywords

# {!babel t="(+European +COMMISSION)"}
# +{!babel t=european} +{!babel t=COMMISSION}
# search for rssitems having the given keywords within at most the given distance

# {!babel t="\"European BRUSSELS\"~10"}
# search for rssitems having the given phrase

# {!babel t="\"european COMMISSION in Brussels\""}
# search for rssitems in german language, having the given phrase, which is in english (and which was produced by the translation system) (the difference is that the first syntax will return also rssitems in english language, having the same given phrase, wilst the second syntax only rssitems in german language)

# +{!babel t="\"European Commission in Brussels\""} +language:(en de)
# +{!babel l="en" t="\"European Commission in Brussels\""} +language:de
# search for rssitems having word that sounds like the given keyword (default edit distance being 2, and between 1 and 2)

# {!babel t=europese~}
# {!babel t=Europian~1}
# search for rssitems having word matching the given keyword pattern

# {!babel t=euro?ean}
# {!babel t=euro*n}
# {!babel t=euro*e?n}
# {!babel t=euro*}
# search for rssitems having the given phrase

# {!babel t="\"Joint Research Cent*\""}
# {!babel t="\"Join* Research Centre\""}
# search for rssitems having word within the range defined by the given keywords, boundaries included

# {!babel t="[euro TO european]"}
# search for rssitems having word within the range defined by the given keywords, boundaries excluded

# {!babel t="{euro TO european}"}
# these examples are not supported
# using * wildcard in a keyword pattern, or phrase pattern, with a prefix shorter than 4 characters

# {!babel t=e*ropean}
# {!babel t=e*}
# {!babel t="\"J* Research Centre\""}
# search for rssitems having the given phrase with a word that sounds like the given keyword

# {!babel t="\"Joint~ Research Cent*\""}


# Tonality
# description
# the tonality of the rssitem
# formal
# /channel/item/tonality/text()
# field name
# tonality
# case
# does not apply (indexed data is an integer)
# note
# tonality is not always present; Finder indexes it whenever it's present (this is the default Finder behaviour)
# if tonality is not a valid integer, it's not indexed
# Examples
# search for rssitems with a tonality of -4

# tonality:"-4"
# search for rssitems with a positive tonality

# tonality:[1 TO *]


# **DEFAULTS**

# Unless they are specified, every request on this Finder installation gets added the following default parameters.

# Publication date
# if you don't specify it, Finder adds a clause on publication date (see here), as filter parameter, to limit the search to the whole day of today and the previous 30 days.

# fq=pubdate:[NOW/DAY-30DAY TO *]
# Start and Rows
# if you don't specify it, Finder adds two parameters (see here), to return just the first 10 rows.

# start=0 rows=10

# **SYNTAX**

# Finder uses the standard Solr syntax. You can read more here. Read also the Fields section, which provides several examples of the standard Solr syntax, per each field. As regards operators, you can read more here. As regards the syntax for nested objects, you can read more here.

# Clauses
# This clause selects all documents.

# *:*
# Operators
# No operator
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
# Queries on nested objects
# This special syntax is needed to enforce a clause on a field (or several fields) belonging to a nested object. Such clause can obviously be paired with a clause (or more) on the parent object. As of today, Finder indexes two objects as nested objects: quotes and timex. One rssitem (the parent) can infact have zero, one or more quotes (its nested objects), and zero, one or more timex ranges (its nested objects).

# search for rssitems from country DE with zero quotes

# +country:DE -{!parent which=language:*}quotewho:*
# search for rssitems with a quote either from entityid 2 (quote who) or about entityid 2 (quote about)

# URLdecode("%7B!parent%20which%3Dlanguage%3A*%7D(quotewho%3A2%20quoteabout%3A2)")

# {!parent which=language:*}(quotewho:2 quoteabout:2)
# search for rssitems with category Agriculture, with a quote from entityid 2 (quote who), whose quote text is associated with category CRIME and contains the keyword european
# note: the clause on category Agriculture is defined as fq probably because of a solr bug

# fq=category:Agriculture {!parent which=language:*}(+quotewho:2 +quotecategory:CRIME +{!babel f=quotetext t=european})
# search for rssitems with a timex range exactly beginning on 2018-01-01 and ending on 2018-01-15 (exact match)

# {!parent which=language:*}(+timexfrom:[2018-01-01T00:00:00Z TO 2018-01-01T00:00:00Z] +timexto:[2018-01-15T23:59:59Z TO 2018-01-15T23:59:59Z])
# search for rssitems with a timex range completely included within 2018-01-01 and 2018-01-15 (inclusion)

# {!parent which=language:*}(+timexfrom:[2018-01-01T00:00:00Z TO 2018-01-15T23:59:59Z] +timexto:[2018-01-01T00:00:00Z TO 2018-01-15T23:59:59Z])
# {!parent which=language:*}(+timexfrom:[2018-01-01T00:00:00Z TO *] +timexto:[* TO 2018-01-15T23:59:59Z])
# search for rssitems with a timex range (completely or partially) overlapping with 2018-01-01 and 2018-01-15 (overlap)

# {!parent which=language:*}(+timexfrom:[* TO 2018-01-15T23:59:59Z] +timexto:[2018-01-01T00:00:00Z TO *])

# **PARAMETERS**

# These are the main Solr's common query parameters. You can read more here or here.

# Query filter
# Define the clauses of your search that could be reused as filters through fq. These will be cached for subsequent same calls. Filter uses the same syntax of query. More than one filter can be specified.

# fq=pubdate:[NOW/DAY-30DAY TO *] fq=language:(de en fr)
# Basic paging
# Specify an offset at which Solr should begin displaying content through start, and control how many rows of responses are returned through rows. By default offset starts at 0 and the first 10 rows are returned.

# start=0 rows=10
# Deep paging with a cursor
# Include guid in the sort parameter, control how many rows of responses are returned through rows, specify cursorMark=* for the first request and cursorMark=<nextCursorMark> for the next requests. You can read more here.

# sort=pubdate desc,guid asc rows=10 cursorMark=*
# sort=pubdate desc,guid asc rows=15 cursorMark=AoJRfSVib29rNw==
# Sorting
# Arrange search results in either ascending (asc) or descending (desc) order through sort.

# sort=pubdate desc
# Maximum time allowed
# Constraint the time allowed for the query to be processed through timeAllowed (in milliseconds). If this time expires before the search is complete, any partial results will be returned. A value of 0 means no time restriction.

# timeAllowed=60000
# Query debug
# Debug the execution of a query through debugQuery in conjunction with native. Native can be used as well on its own to pass-through Finder.

# debugQuery=true native=true
# Query caching
# Let Solr avoid caching the query results through cache.

# cache=false


# **FACETING**

# These are the parameters for Solr's faceting. You can read more here.

# Examples of faceting
# all existing values for language, alphabetically sorted

# rows=0 facet=true facet.field=language facet.limit=-1 facet.sort=index native=true dummy
# all existing values for source, with corresponding count

# rows=0 facet=true facet.field=source facet.limit=-1 facet.mincount=1 facet.method=fcs native=true *:*
# top 10 (based on count) existing values for source, with corresponding count, sorted by count

# rows=0 facet=true facet.field=source facet.limit=10 facet.sort=count facet.method=fcs native=true *:*
# top 10 (based on count) existing values for source, top 20 (based on count) existing values for language, with corresponding count, sorted by count

# rows=0 facet=true facet.field=source facet.field=language f.source.facet.limit=10 f.language.facet.limit=20 facet.sort=count native=true *:*
# all existing values for source, with corresponding count, for rssitem from Germany, in German, published in the last 7 days

# rows=0 facet=true facet.field=source facet.limit=-1 facet.method=fcs native=true +country:DE +language:de fq=pubdate:[NOW/DAY-7DAY TO *]
# Examples of faceting on fields on nested objects
# all existing values for quotewho, with corresponding count, for rssitem from Germany, published in the last 3 days
# note: the clause on pubdate must be explicit (otherwise it would apply the default pubdate filter, which doesn't include yet the 'child of' syntax, thus the query would fail); the order is relevant probably because of a Finder bug

# rows=0 facet=true facet.field=quotewho facet.limit=-1 facet.mincount=1 facet.method=fcs native=true {!child of=language:*}(+pubdate:[NOW/DAY-3DAY TO *] +country:DE)
# Examples of pivot faceting
# all existing values for country, with corresponding count, and per each country all existing values for language, with corresponding count

# rows=0 facet=true facet.pivot=country,language facet.limit=-1 native=true *:*
# Examples of range faceting
# all existing values for pubdate, in days, with corresponding count, in the last two months

# rows=0 facet=true facet.range=pubdate facet.range.start=NOW/DAY-2MONTH facet.range.gap=+1DAY facet.range.end=NOW native=true fq=pubdate:[NOW/DAY-2MONTH TO *] *:*
# all existing values for pubdate, in days, with corresponding count, for april 2014

# rows=0 facet=true facet.range=pubdate facet.range.start=2014-04-01T00:00:00Z facet.range.gap=+1DAY facet.range.end=2014-04-30T23:59:59Z native=true fq=pubdate:[2014-04-01T00:00:00Z TO 2014-04-30T23:59:59Z] *:*


# **EXTRA**

# These are some extra parameters provided by Finder.

# Leading
# Exclude duplicate rssitems from the results.
# More precisely: post-process the results of your search, so that only one rssitem per group is returned; group being the leading rssitem and its duplicates, as settled by the duplicate detection component. This functionality may not be available for rssitems indexed before January 2016.

# leading=true
# Within each group, return the oldest rssitem.
# leading=true group.sort=pubdate asc







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
