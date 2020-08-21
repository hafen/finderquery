#' Get how many documents were returned
#' @param x Documents object in list format
#' @export
n_docs <- function(x)
  as.integer(x$rss$channel$numFound[[1]])

next_cursor <- function(x)
  x$rss$channel$nextCursorMark
