#' Get how many documents were returned
#' @param x Documents object in list format
#' @export
n_docs <- function(x)
  attr(x, "meta")$numFound

# next_cursor <- function(x)
#   x$rss$channel$nextCursorMark
