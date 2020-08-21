#' Initialize a query with a specified query string
#'
#' @param con A finder connection object from [finder_connect()].
#' @param str A SOLR query string, e.g. "op=search&q=*:*&rows=0".
#' @param path An optional directory in which to place downloaded results
#'   (required when `format="file"`).
#' @param format One of "list", "json", "xml", "file". In the case of "file",
#'   The path to the file will be returned. In all other cases, an object
#'   with the fetched data will be returned in the format specified.
#' @export
query_str <- function(
  con, str, path = NULL,
  format = c("list", "json", "xml", "file")
) {
  format <- match.arg(format)

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
    format = format
  ), class = c("es_query", "query_str"))
}
