#' Get a vector of all unique "language" values
#' @export
valid_languages <- function(con) {
  get_valid_vals(con, "language")
}

#' Get a vector of all unique "category" values
#' @export
valid_categories <- function(con) {
  get_valid_vals(con, "category")
}

#' Get a vector of all unique "country" values
#' @export
valid_countries <- function(con) {
  get_valid_vals(con, "country")
}

#' Get a vector of all unique "source" values
#' @export
valid_sources <- function(con) {
  get_valid_vals(con, "source")
}

#' @importFrom xml2 xml_children as_list
get_valid_vals <- function(con, fld) {
  res <- query_str(con,
    paste0("op=search&q=dummy&facet.sort=index&facet.field=", 
      fld, "&rows=0&facet=true&facet.limit=-1&native=true"),
    format = "xml") %>%
    run()

  res %>%
    xml2::xml_find_all(paste0("//lst[@name='", fld, "']")) %>%
    xml2::xml_children() %>%
    xml2::as_list() %>%
    lapply(function(x) attr(x, "name")) %>%
    unlist()
}
