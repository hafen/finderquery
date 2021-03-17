#' Initialize a query with a specified query string
#'
#' @param con A finder connection object from [finder_connect()].
#' @param str A SOLR query string, e.g. "op=search&q=*:*&rows=0".
#' @param path An optional directory in which to place downloaded results
#'   (required when `format="file"`).
#' @param format One of "list", "xml", "file". In the case of "file",
#'   The path to the file will be returned. In all other cases, an object
#'   with the fetched data will be returned in the format specified. List
#'   results are converted using [fq_xml_to_list()].
#' @param type the type of query defined in the string - one of "unknown",
#'   "fetch", or "agg"
#' @param max The maximum number of documents to fetch (used when
#'   type=="fetch"). Set to <0 to fetch all. When fetching all it is a
#'   good idea to first fetch with only a few documents and use [n_docs()]
#'   to get a sense of how many will be pulled.
#' @param size The number of documents to fetch in each batch (max is
#'   10000 - used when type=="fetch").
#' @export
fq_query_str <- function(
  con, str, path = NULL,
  format = c("list", "xml", "file"),
  type = c("unknown", "fetch", "facet"),
  max = 10, size = 10000
) {
  format <- match.arg(format)
  type <- match.arg(type)

  check_class(con, "finder_connection", "query_str")

  if (is.null(path) && format == "file")
    stop("Must specify a path if format='file'", call. = FALSE)

  if (!is.null(path)) {
    if (!dir.exists(path))
      stop("Path '", path, "' must exist and be a directory",
        call. = FALSE)

    if (length(list.files(path)) > 0)
      message("Note: files already exist in directory '", path, "'")
  }

  structure(list(
    con = con,
    str = str,
    path = path,
    format = format,
    max = max,
    size = size,
    type = type
  ), class = c("fq_query", "query_str"))
}
