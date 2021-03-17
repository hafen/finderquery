#' List of queryable fields
#' @export
fq_queryable_fields <- function() {
  c("language", "category", "country", "source", "quotecategory", "duplicate",
    "tonality", "entityid", "guid", "indexdate", "pubdate", "quotetext",
    "text", "quotewho", "quoteabout", "georssid")
}

# setdiff(fq_queryable_fields(), tolower(fq_selectable_fields()))
# setdiff(tolower(fq_selectable_fields()), fq_queryable_fields())

#' Get a vector of all unique "language" values
#' @param con A finder connection object from [finder_connect()].
#' @export
fq_valid_languages <- function(con) {
  fq_get_valid_vals(con, "language")
}

#' Get a vector of all unique "category" values
#' @param con A finder connection object from [finder_connect()].
#' @export
fq_valid_categories <- function(con) {
  fq_get_valid_vals(con, "category")
}

#' Get a vector of all unique "country" values
#' @param con A finder connection object from [finder_connect()].
#' @export
fq_valid_countries <- function(con) {
  fq_get_valid_vals(con, "country")
}

#' Get a vector of all unique "source" values
#' @param con A finder connection object from [finder_connect()].
#' @export
fq_valid_sources <- function(con) {
  fq_get_valid_vals(con, "source")
}

# #' Get a vector of all unique "quotewho" values
# #' @export
# fq_valid_quotewho <- function(con) {
#   fq_get_valid_vals(con, "quotewho")
# }

#' Get a vector of all unique "quotecategory" values
#' @param con A finder connection object from [finder_connect()].
#' @export
fq_valid_quotecategory <- function(con) {
  fq_get_valid_vals(con, "quotecategory")
}

#' Get a vector of all unique "duplicate" values
#' @param con A finder connection object from [finder_connect()].
#' @export
fq_valid_duplicate <- function(con) {
  fq_get_valid_vals(con, "duplicate")
}

# quotewho # very large output ~179k values
# quoteabout # very large output ~179k values
# georssid # ~105k values

#' @importFrom xml2 xml_children as_list
fq_get_valid_vals <- function(con, fld) {
  res <- fq_query_str(con,
    paste0("op=search&q=dummy&facet.sort=index&facet.field=", 
      fld, "&rows=0&facet=true&facet.limit=-1&native=true"),
    format = "xml") %>%
    fq_run()

  res %>%
    xml2::xml_find_all(paste0("//lst[@name='", fld, "']")) %>%
    xml2::xml_children() %>%
    xml2::as_list() %>%
    lapply(function(x) attr(x, "name")) %>%
    unlist()
}
