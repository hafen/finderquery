#' Convert Finder xml result into a more convenient R list format
#' @param x an object of class "xml_document" obtained from [query_fetch()]
#' @export
xml_to_list <- function(x) {
  if (!inherits(x, "xml_document"))
    stop("Input to xml_to_list() must have class 'xml_document'.",
      call. = FALSE)

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


# these columns will be treated as having multiple values
# when transforming to data frame
list_cols <- c("entity", "category", "fullgeo")

#' Convert documents list to data frame
#' @param x an object of class "xml_document" or "finder_docs" obtained from [query_fetch()].
#' @details In general, a lot of information can be lost when transforming to a data frame, such as attributes or entries that have more than one element. Columns "title" and "description" often have two elements with the second being the English translation. Because of this, columns "title", "title_en", "description", and "description_en" are created to preserve this. Columns "entity", "category", "fullgeo" usually have more than one entry for each document and as such are added to the data frame as "list columns".
#' @export
list_to_df <- function(x) {
  if (inherits(x, "xml_document")) {
    message("Provided input was xml, not a list... Attempting to transform...")
    x <- xml_to_list(x)
  }

  if (!(inherits(x, "finder_docs") && inherits(x, "list")))
    stop("list_to_df() expects an object returned from query_fetch()",
      call. = FALSE)

  res <- dplyr::bind_rows(lapply(x, function(el) {
    tmp <- list()
    for (nm in names(el)) {
      a <- el[[nm]]
      if (nm %in% c("title", "description")) {
        tmp[[nm]] <- a[[1]]
        tmp[[paste0(nm, "_en")]] <- a[[min(2, length(a))]]
      } else if (nm %in% list_cols) {
        tmp[[nm]] <- list(unlist(a))
      } else {
        tmp[[nm]] <- a[[1]]
      }
    }
    tibble::as_tibble(tmp)
  }))

  class(res) <- c(class(res), "finder_docs")

  res
}

#' Write xml documents to a csv file
#' @param x an object of class "xml_document" or "finder_docs" obtained from [query_fetch()].
#' @param collapse The separator character to use to collapse list column fields.
#' \ldots Parameters sent to [readr::write_csv()].
#' @details List columns of the data frame will be collapsed. Currently these columns are "entity", "category", "fullgeo"
#' @export
write_docs_csv <- function(x, collapse = ";", ...) {
  if (!(inherits(x, "finder_docs") && inherits(x, "data.frame")))
    x <- list_to_df(x)

  for (nm in list_cols)
    x[[nm]] <- unlist(lapply(x[[nm]],
      function(a) paste(a, collapse = collapse)))

  do.call(readr::write_csv, list(x = x, ...))
}
