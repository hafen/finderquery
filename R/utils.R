#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

check_class <- function(obj, class_name, fn_name) {
  if (length(class_name) == 1) {
    cls <- paste0("'", class_name, "'")
  } else {
    cls <- paste0("'", class_name, "'", collapse = " or ")
  }
  if (!inherits(obj, class_name))
    stop(fn_name, "() expects an object of class ", cls, call. = FALSE)
}

check_query_error <- function(qry, aa) {
  if (aa$status_code != 200) {
    tmp <- rawToChar(aa$content)
    msg <- gsub("<!doctype html>", "", tmp) %>%
      xml2::read_xml() %>%
      xml2::xml_find_first(".//body") %>%
      xml2::as_list() %>%
      unlist() %>%
      unname() %>%
      paste(collapse = "\n")

    message("query string:\n", qry)
    message("\n", msg)
    stop("There was an error with the query", call. = FALSE)
  }
}
