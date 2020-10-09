devtools::load_all("..")
Sys.unsetenv("NO_PROXY")
Sys.unsetenv("HTTPS_PROXY")
Sys.unsetenv("HTTP_PROXY")
Sys.unsetenv("https_proxy")
Sys.unsetenv("http_proxy")

con <- finder_connect(Sys.getenv("FINDER_HOST"))
dev_server <- as.logical(Sys.getenv("PLUMBER_DEV_SERVER", unset = FALSE))

if (!dir.exists("/tmp/__finder_downloads__/"))
  dir.create("/tmp/__finder_downloads__/")

#' @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

build_query <- function(
  category, country, language, source, duplicate, pubdate, indexdate, text,
  tonality, entityid, georssid, guid, fields, path, max = 0, format = "list"
) {
  qry <- query_fetch(con, max = max, path = path, format = format)

  up <- function(x) unlist(jsonlite::parse_json(x))

  if (!missing(category)) {
    category <- up(category)
    qry <- qry %>% filter_category(category)
  }

  if (!missing(country)) {
    country <- up(country)
    qry <- qry %>% filter_country(country)
  }

  if (!missing(language)) {
    language <- up(language)
    qry <- qry %>% filter_language(language)
  }

  if (!missing(source)) {
    source <- up(source)
    qry <- qry %>% filter_source(source)
  }

  if (!missing(duplicate)) {
    duplicate <- up(duplicate)
    qry <- qry %>% filter_duplicate(duplicate)
  }

  pubdate <- up(pubdate)
  if (!all(pubdate == "null"))
    qry <- qry %>% filter_pubdate(
      from = if(pubdate[1] == "null") { NULL } else { as.Date(pubdate[1])},
      to = if(pubdate[2] == "null") { NULL } else { as.Date(pubdate[2])})

  indexdate <- up(indexdate)
  if (!all(indexdate == "null"))
    qry <- qry %>% filter_indexdate(
      from = if(indexdate[1] == "null") { NULL } else { as.Date(indexdate[1])},
      to = if(indexdate[2] == "null") { NULL } else { as.Date(indexdate[2])})

  if (!missing(text))
    qry <- qry %>% filter_text(text)

  if (!missing(entityid))
    qry <- qry %>% filter_entityid(entityid)

  if (!missing(georssid))
    qry <- qry %>% filter_georssid(georssid)

  if (!missing(guid))
    qry <- qry %>% filter_guid(guid)

  tonality <- as.integer(up(tonality))
  if (tonality[1] != -100 || tonality[2] != 100)
    qry <- qry %>% filter_tonality(from = tonality[1], to = tonality[2])

  if (!is.null(fields)) {
    fields <- up(fields)
    if (length(fields) != length(selectable_fields()))
      qry <- qry %>% select_fields(fields)
  }

  qry  
}

#* Get the number of documents for current query parameters
#* @serializer unboxedJSON
#* @get /get_ndocs
function(
  category, country, language, source, duplicate, pubdate, indexdate, text,
  tonality, entityid, georssid, guid
) {
  qry <- build_query(
    category, country, language, source, duplicate, pubdate, indexdate, text,
    tonality, entityid, georssid, guid, fields = NULL, path = NULL
  )

  if (dev_server) {
    nd <- ifelse(runif(1) < 0.8, 10000, 10000000)
  } else {
    nd <- n_docs(finderquery::run(qry))
  }

  message(finderquery::get_query(qry))

  return(list(
    n_docs = nd,
    query = paste0(qry$con$con, finderquery::get_query(qry))
  ))
}

#* Download documents
#* @serializer unboxedJSON
#* @get /download_docs
function(
  category, country, language, source, duplicate, pubdate, indexdate, text,
  tonality, entityid, georssid, guid, fields, path, format
) {
  if (!dir.exists(path))
    dir.create(path, recursive = TRUE)
  ff <- list.files(path, full.names = TRUE)
  if (length(ff) > 0)
    unlink(ff)

  qry <- build_query(
    category, country, language, source, duplicate, pubdate, indexdate, text,
    tonality, entityid, georssid, guid, fields = fields, path = path, max = -1,
    format = "file"
  )

  if (dev_server) {
    Sys.sleep(2)
    for (i in 1:5)
      cat("test", file = file.path(path, sprintf("output%04d.xml", i)))
  } else {
    finderquery::run(qry)
  }

  if (format == "csv") {
    browser()
  }

  ff <- list.files(path)
  zipfile <- file.path(dirname(path), paste0(basename(path), ".zip"))
  withr::with_dir(path, utils::zip(zipfile, ff))

  message("downloaded... ", path)
  return(TRUE)
}

#* @assets /tmp/__finder_downloads__ /static
list()
