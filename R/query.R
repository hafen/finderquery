#' Execute a query
#'
#' @param query a [fq_query_fetch()], [fq_query_facet()] or [fq_query_str()] object
#' @export
fq_run <- function(query) {
  check_class(query, c("query_facet", "query_fetch", "query_str"), "run")

  if (inherits(query, "query_str")) {
    if (query$type == "unknown") {
      run_query_str(query)
    } else if (query$type == "fetch") {
      run_query_fetch(query)
    } else {
      run_query_facet(query)
    }
  } else if (inherits(query, "query_fetch")) {
    run_query_fetch(query)
  } else if (inherits(query, "query_facet")) {
    run_query_facet(query)
  }
}

#' Get the query string for a query
#' @param query a [fq_query_fetch()], [fq_query_facet()], or [fq_query_str()] object
#' @export
fq_get_query <- function(query) {
  check_class(query, c("query_fetch", "query_facet", "query_str"), "get_query")

  if (inherits(query, "query_str")) {
    qry <- query$str
  } else if (inherits(query, "query_fetch")) {
    qry <- build_query_fetch(query)
  } else {
    qry <- build_query_facet(query)
  }

  qry
}

#' @importFrom curl curl_download curl_fetch_memory
#' @importFrom xml2 read_xml as_list xml_text xml_find_first write_xml
#' @importFrom jsonlite toJSON
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

  res <- xml2::read_xml(dest, options = c("NOBLANKS", "HUGE"))

  # we can't use xml_to_list since we don't know what kind of content
  # a string query will return (could be facet, fetch, etc.)
  if (query$format == "list") {
    if (is.na(xml2::xml_text(xml2::xml_find_first(res, ".//numFound")))) {
      # it's not a fetch query so just return a list
      return(xml2::as_list(res))
    } else {
      # it's a fetch query
      return(fq_xml_to_list(res))
    }
  }

  return(res)
}

run_query_fetch <- function(query) {
  if (is.null(query$path)) {
    dest <- tempfile(fileext = ".xml")
  } else {
    dest <- file.path(query$path, "output.xml")
  }

  if (inherits())

  # by default it filters to last 30 days
  # so if no pubdate filter is specified, add really old lower bound
  if (!any(grepl("^pubdate", unlist(query$filters))))
    query <- query %>% fq_filter_pubdate(from = as.Date("1990-01-01"))

  qry <- build_query_fetch(query)

  aa <- curl::curl_fetch_memory(build_url(query$con$con, qry))
  if (aa$status_code != 200)
    stop("There was an error with the query: ", qry)
  bb <- rawToChar(aa$content)

  res <- xml2::read_xml(bb, options = c("NOBLANKS", "HUGE"))
  res <- remove_fields(res, query)

  tot <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//numFound")))
  curs <- xml2::xml_text(xml2::xml_find_first(res, ".//nextCursorMark"))

  # if there is no cursor, then results are not paginated... return
  if (is.na(curs)) {
    if (query$format == "file") {
      xml2::write_xml(res, file = dest)
      return(dest)
    }

    if (query$format == "list")
      return(fq_xml_to_list(res))

    return(res)
  }

  tot_hits <- tot

  counter <- 1
  cum_hits <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//rows")))
  xml2::write_xml(res,
    file = sprintf("%s/out%04d.xml", query$path, counter))

  sz_str <- min(query$size, tot_hits)
  denom <- tot_hits
  cum_str <- min(cum_hits, tot_hits)
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
    res <- xml2::read_xml(bb, options = c("NOBLANKS", "HUGE"))
    res <- remove_fields(res, query)
    tot <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//numFound")))
    curs <- xml2::xml_text(xml2::xml_find_first(res, ".//nextCursorMark"))
    cur_hits <- as.integer(xml2::xml_text(xml2::xml_find_first(res, ".//rows")))

    if (cur_hits > 0) {
      xml2::write_xml(res,
        file = sprintf("%s/out%04d.xml", query$path, counter))
      cum_hits <- cum_hits + cur_hits
      denom <- tot_hits
      cum_str <- min(cum_hits, tot_hits)
      if (query$max > 0) {
        cum_hits <- min(cum_hits, query$max)
        denom <- min(query$max, tot_hits)
      }
      message(min(cum_hits, tot_hits), " documents fetched (",
        round(100 * cum_str / denom), "%)...")
    }
  }

  if (query$try_read && tot_hits <= 100000) {
    message("Reading into a list...")
    ff <- list.files(query$path, full.names = TRUE)
    tmp <- lapply(ff, function(f) {
      res <- xml2::read_xml(f, options = c("NOBLANKS", "HUGE"))
      fq_xml_to_list(res)
    })
    return(unlist(tmp, recursive = FALSE))
  }

  return(query$path)
}

# facet queries always read into memory and transform to a nice format
#' @importFrom tibble tibble
run_query_facet <- function(query) {
  if (is.null(query$facet))
    stop("Must specify faceting.")

  # by default it filters to last 30 days
  # so if no pubdate filter is specified, add really old lower bound
  if (!any(grepl("^pubdate", unlist(query$filters))))
    query <- query %>% fq_filter_pubdate(from = as.Date("1990-01-01"))

  qry <- build_query_facet(query)
  aa <- curl::curl_fetch_memory(build_url(query$con$con, qry))
  if (aa$status_code != 200)
    stop("There was an error with the query: ", qry)
  bb <- rawToChar(aa$content)

  res <- xml2::read_xml(bb, options = c("NOBLANKS", "HUGE"))

  if (query$facet$type == "field") {
    fld <- query$facet$field
    a <- res %>%
      xml2::xml_find_all(paste0("//lst[@name='", fld, "']")) %>%
      xml2::xml_children() %>%
      xml2::as_list()

    res <- tibble::tibble(
      tmp = unlist(lapply(a, function(x) attr(x, "name"))),
      n = as.numeric(unlist(a))
    )
    names(res)[1] <- fld
  } else if (query$facet$type == "date_range") {
    fld <- query$facet$field
    a <- res %>%
      xml2::xml_find_all(paste0("//lst[@name='", fld, "']")) %>%
      xml2::xml_child() %>%
      xml2::xml_children() %>%
      xml2::as_list()

    res <- tibble::tibble(
      tmp = unlist(lapply(a, function(x) attr(x, "name"))),
      n = as.numeric(unlist(a))
    )
    res$tmp <- as.POSIXct(res$tmp)
    names(res)[1] <- fld
  } else if (query$facet$type == "pivot") {
    nm <- query$facet$pivot
    tmp <- res %>%
      xml2::xml_find_all(paste0("//arr[@name='", nm, "']")) %>%
      xml2::xml_children() %>%
      xml2::as_list()

    res <- lapply(tmp, function(el) {
      fld <- el[[1]][[1]]
      fld_val <- el[[2]][[1]]
      a1 <- unname(unlist(lapply(el[[4]], function(x) {
        x[[2]][[1]]
      })))
      a2 <- as.numeric(unname(unlist(lapply(el[[4]], function(x) {
        x[[3]][[1]]
      }))))
      tibble::tibble(
        !!fld := fld_val,
        !!el[[4]][[1]][[1]][[1]] := a1,
        n = a2
      )
      # # this is much slower
      # tb <- lapply(el[[4]], function(x) {
      #   tibble::tibble(
      #     !!fld := fld_val,
      #     !!x[[1]][[1]] := x[[2]][[1]],
      #     n = as.numeric(x[[3]][[1]])
      #   )
      # }) %>%
      # dplyr::bind_rows()
    }) %>%
    dplyr::bind_rows()
  }

  res
}

build_url <- function(con, str) {
  paste0(con, str)
}

build_filter_string <- function(query) {
  str <- ""

  if (length(query$filters) > 0) {
    str <- sapply(query$filters, function(x) paste0("fq=", x)) %>%
      paste(collapse = "&")
  }

  str
}

build_query_fetch <- function(query) {
  str <- build_filter_string(query)

  page <- ""
  rows <- query$max
  if (query$max > query$size || query$max < 0) {
    rows <- query$size
    page <- "&cursorMark=*"
    query$sort <- c(query$sort, list("guid+asc"))
  }

  if (length(query$sort) > 0) {
    str <- paste0(str, "&sort=", paste(unlist(query$sort), collapse = ","))
  }

  qstr <- ifelse(is.null(query$filter_text), "*:*", query$filter_text)

  paste0("op=search&q=", qstr, ifelse(str == "", "", "&"), str,
    "&rows=", rows, page)
}

build_query_facet <- function(query) {
  qstr <- ifelse(is.null(query$filter_text), "*:*", query$filter_text)

  if (query$facet$type %in% c("field", "pivot")) {
    pars <- query$facet
    pars$type <- NULL
    pars <- paste0(paste0("facet.", names(pars)), "=", unlist(pars))
    qry <- paste0("op=search&q=", qstr, "&rows=0&facet=true&native=true&",
      paste(pars, collapse = "&"))
  } else if (query$facet$type == "date_range") {
    pars <- query$facet
    field <- pars$field
    pars$field <- NULL
    pars$type <- NULL
    pars <- paste0(paste0("facet.range.", names(pars)), "=", unlist(lapply(pars, enc)))
    qry <- paste0("op=search&q=", qstr, "&rows=0&facet=true&native=true&",
      "facet.range=", field, "&", paste(pars, collapse = "&"))
  }
  filter_str <- build_filter_string(query)
  if (filter_str != "")
    qry <- paste0(qry, "&", filter_str)

  qry
}

#' @importFrom xml2 xml_remove
remove_fields <- function(x, query) {
  if (is.null(query$select))
    return(x)

  exclude <- setdiff(fq_selectable_fields(), query$select)
  for (val in exclude) {
    nodes <- xml2::xml_find_all(x, paste0("//", val))
    xml2::xml_remove(nodes, free = TRUE)
    nodes <- xml2::xml_find_all(x, paste0("//iso:", val))
    xml2::xml_remove(nodes, free = TRUE)
    nodes <- xml2::xml_find_all(x, paste0("//gphin:", val))
    xml2::xml_remove(nodes, free = TRUE)
    nodes <- xml2::xml_find_all(x, paste0("//emm:", val))
    xml2::xml_remove(nodes, free = TRUE)
  }

  x
}
