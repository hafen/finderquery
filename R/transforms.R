#' Convert Finder xml result into a more convenient R list format
#' @export
xml_to_list <- function(x, fields = NULL) {
  x <- xml2::as_list(x)
  if (is.null(x$rss$channel))
    stop("Output is not in the expected format.", call. = FALSE)

  idx <- names(x$rss$channel) == "item"

  meta <- as.list(unlist(x$rss$channel[!idx]))
  # QTime is elapsed time (in milliseconds) between the arrival of the 
  # request (when the SolrQueryRequest object is created) and the completion 
  # of the request handler
  meta$QTime <- as.integer(meta$QTime)
  meta$numFound <- as.numeric(meta$numFound)
  meta$start <- as.integer(meta$start)
  meta$rows <- as.integer(meta$rows)

  docs <- unname(x$rss$channel[idx])

  # # see what fields can show up more than once in a document
  # lapply(docs, function(x) table(names(x))[table(names(x)) > 1])
  # unique(unlist(lapply(docs, function(a) {
  #   nms <- table(names(a))
  #   names(nms[nms > 1])
  # })))
  # # it looks like most anything can show up more than once

  docs <- lapply(docs, function(a) {
    # list has structure of repeated fields of same name
    # need to group them together...
    # everything in the document is a list of length 1 
    # make it more convenient...

    # first, attributes should belong to the list elements
    for (ii in seq_along(a)) {
      atr <- attributes(a[[ii]])
      if (length(a[[ii]]) == 0)
        a[[ii]] <- list(NULL)
      attributes(a[[ii]][[1]]) <- atr
    }
    # now bundle elements with multiple of the same field name together
    nmstab <- table(names(a))
    to_bundle <- names(nmstab[nmstab > 1])
    for (nm in to_bundle) {
      idx <- which(names(a) == nm)
      a[[idx[1]]] <- unlist(unname(a[idx]), recursive = FALSE)
      a[idx[-1]] <- NULL
    }
    a
  })

  # # all unique fields
  # dput(unique(unlist(lapply(docs, names))))

  class(docs) <- c("finder_docs", "list")
  attr(docs, "meta") <- meta

  docs
}

# TODO: data frame transform?
