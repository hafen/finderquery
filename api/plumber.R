# devtools::load_all("..")
# devtools::install_github("WorldHealthOrganization/finderquery")
library(finderquery)

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
    qry <- qry %>% fq_filter_category(category)
  }

  if (!missing(country)) {
    country <- up(country)
    qry <- qry %>% fq_filter_country(country)
  }

  if (!missing(language)) {
    language <- up(language)
    qry <- qry %>% fq_filter_language(language)
  }

  if (!missing(source)) {
    source <- up(source)
    qry <- qry %>% fq_filter_source(source)
  }

  if (!missing(duplicate)) {
    duplicate <- up(duplicate)
    qry <- qry %>% fq_filter_duplicate(duplicate)
  }

  pubdate <- up(pubdate)
  if (!all(pubdate == "null"))
    qry <- qry %>% fq_filter_pubdate(
      from = if(pubdate[1] == "null") { NULL } else { as.Date(pubdate[1])},
      to = if(pubdate[2] == "null") { NULL } else { as.Date(pubdate[2])})

  indexdate <- up(indexdate)
  if (!all(indexdate == "null"))
    qry <- qry %>% fq_filter_indexdate(
      from = if(indexdate[1] == "null") { NULL } else { as.Date(indexdate[1])},
      to = if(indexdate[2] == "null") { NULL } else { as.Date(indexdate[2])})

  if (!missing(text))
    qry <- qry %>% fq_filter_text(text)

  if (!missing(entityid))
    qry <- qry %>% fq_filter_entityid(entityid)

  if (!missing(georssid))
    qry <- qry %>% fq_filter_georssid(georssid)

  if (!missing(guid))
    qry <- qry %>% fq_filter_guid(guid)

  tonality <- as.integer(up(tonality))
  if (tonality[1] != -100 || tonality[2] != 100)
    qry <- qry %>% fq_filter_tonality(from = tonality[1], to = tonality[2])

  if (!is.null(fields)) {
    fields <- up(fields)
    if (length(fields) != length(fq_selectable_fields()))
      qry <- qry %>% fq_select_fields(fields)
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
    nd <- fq_n_docs(finderquery::fq_run(qry))
  }

  message(finderquery::fq_get_query(qry))

  return(list(
    n_docs = nd,
    query = paste0(qry$con$con, finderquery::fq_get_query(qry))
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
    finderquery::fq_run(qry)
  }

  if (format == "csv") {
    ff <- list.files(path, full.names = TRUE, pattern = "xml$")

    for (f in ff) {
      tmp <- xml2::read_xml(f)
      tmp2 <- fq_xml_to_list(tmp)
      tmpdf <- fq_list_to_df(tmp2)
      f2 <- gsub("xml$", "csv", f)
      fq_write_docs_csv(tmpdf, file = f2)
      unlink(f)
    }
  }

  ff <- list.files(path)
  zipfile <- file.path(dirname(path), paste0(basename(path), ".zip"))
  withr::with_dir(path, utils::zip(zipfile, ff))

  message("downloaded... ", path)
  return(TRUE)
}

#* @assets /tmp/__finder_downloads__ /static
list()
