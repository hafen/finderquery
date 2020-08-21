#' Execute a query
#'
#' @param query a [query_fetch()], [query_facet()] or [query_str()] object
#' @export
run <- function(query) {
  check_class(query, c("query_facet", "query_fetch", "query_str"), "run")

  if (inherits(query, "query_str")) {
    run_query_str(query)
  } else if (inherits(query, "query_fetch")) {
    run_query_fetch(query)
  } else if (inherits(query, "query_facet")) {
    # run_query_facet(query)
  }
}

#' Get the query string for a query
#' @param query TODO
#' @export
get_query <- function(query) {
  check_class(query, c("query_fetch", "query_facet", "query_str"), "get_query")

  if (inherits(query, "query_str")) {
    qry <- query$str
  } else if (inherits(query, "query_fetch")) {
    qry <- build_query_fetch(query)
  } else {
    qry <- ""
    # qry <- build_query_facet(query)
  }

  qry
}

run_query_str <- function(query) {
  if (is.null(query$path)) {
    dest <- tempfile(fileext = ".xml")
  } else {
    dest <- file.path(query$path, "output.xml")
  }
  curl::curl_download(url = build_url(query$con$con, query$str),
    destfile = dest)

  if (query$format == "file")
    return(dest)

  res <- xml2::read_xml(dest)

  if (query$format == "list")
    return(xml2::as_list(res))

  if (query$format == "json")
    return(jsonlite::toJSON(xml2::as_list(res)))

  return(res)
}

run_query_fetch <- function(query) {
  if (is.null(query$path)) {
    dest <- tempfile(fileext = ".xml")
  } else {
    dest <- file.path(query$path, "output.xml")
  }

  qry <- build_query_fetch(query)

  aa <- curl::curl_fetch_memory(build_url(query$con$con, qry))
  if (aa$status_code != 200)
    stop("There was an error with the query: ", qry)
  bb <- rawToChar(aa$content)

  res <- xml2::read_xml(bb)

  tot <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//numFound")))
  curs <- xml2::xml_text(xml2::xml_find_first(res, ".//nextCursorMark"))

  # if there is no cursor, then results are not paginated... return
  if (is.na(curs)) {
    if (query$format == "file") {
      cat(bb, file = dest)
      return(dest)
    }

    if (query$format == "list")
      return(xml2::as_list(res))

    if (query$format == "json")
      return(jsonlite::toJSON(xml2::as_list(res)))

    return(res)
  }

  tot_hits <- tot
  cur_hits <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//rows")))

  counter <- 1
  cum_hits <- cur_hits
  cat(bb, file = sprintf("%s/out%04d.json", query$path, counter))

  sz_str <- min(query$size, cur_hits)
  denom <- tot_hits
  cum_str <- cum_hits
  if (query$max > 0) {
    sz_str <- min(sz_str, query$max)
    denom <- min(query$max, tot_hits)
    cum_str <- min(cum_hits, query$max)
  }
  message(sz_str, " documents fetched (",
    round(100 * cum_str / denom), "%)...")

  while (cum_hits < tot_hits) {
    counter <- counter + 1
    qry2 <- gsub("(.*cursorMark=)\\*(.*)", paste0("\\1", enc(curs), "\\2"), qry)
    aa <- curl::curl_fetch_memory(build_url(query$con$con, qry2))
    if (aa$status_code != 200)
      stop("There was an error with the query: ", qry2)
    bb <- rawToChar(aa$content)
    res <- xml2::read_xml(bb)
    tot <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//numFound")))
    curs <- xml2::xml_text(xml2::xml_find_first(res, ".//nextCursorMark"))
    cur_hits <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//rows")))

    if (cur_hits > 0) {
      cat(bb, file = sprintf("%s/out%04d.json", query$path, counter))
      cum_hits <- cum_hits + cur_hits
      denom <- tot_hits
      cum_str <- cum_hits
      if (query$max > 0) {
        cum_hits <- min(cum_hits, query$max)
        denom <- min(query$max, tot_hits)
        cum_str <- min(cum_hits, tot_hits)
      }
      message(min(cum_hits, tot_hits), " documents fetched (",
        round(100 * cum_str / denom), "%)...")
    }
  }

  return(query$path)
}

build_url <- function(con, str) {
  paste0(con, str)
}

build_query_fetch <- function(query) {
  str <- ""

  if (length(query$filters) > 0) {
    str <- sapply(query$filters, function(x) paste0("fq=", x)) %>%
      paste(collapse = "&")
  }

  page <- ""
  rows <- query$max
  if (query$max > query$size || query$max == 0) {
    rows <- query$size
    page <- "&cursorMark=*"
    query$sort <- c(query$sort, list("guid+asc"))
  }

  if (length(query$sort) > 0) {
    str <- paste0(str, "&sort=", paste(unlist(query$sort), collapse = ","))
  }

  paste0("op=search&q=*:*", ifelse(str == "", "", "&"), str,
    "&rows=", rows, page)
}
