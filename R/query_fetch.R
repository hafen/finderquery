#' Initialize a document fetch query
#'
#' @param con A finder connection object from [finder_connect()].
#' @param path An optional directory in which to place downloaded results
#'   (required when `format="file"`).
#' @param max The maximum number of documents to fetch. Set to <0 to fetch
#'   all. When fetching all it is a good idea to first fetch with only a few
#'   documents and use [fq_n_docs()] to get a sense of how many will be pulled.
#' @param size The number of documents to fetch in each batch (max is 10000).
#' @param format One of "list", "xml", "file". In the case of "file",
#'   The path to the file will be returned. In all other cases, an object
#'   with the fetched data will be returned in the format specified. List 
#'   results are converted using [fq_xml_to_list()].
#' @export
fq_query_fetch <- function(
  con, path = NULL, max = 10, size = 10000,
  format = c("list", "xml", "file")
) {
  if (size > 10000)
    size <- 10000

  try_read <- FALSE

  format <- match.arg(format)

  if ((max > size) && format != "file") {
      message("Forcing format to be 'file' due to the large number of ",
        "documents being retrieved.")
      format <- "file"
    if (is.null(path))
      stop("Must provide a path argument when retrieving so many documents.",
        call. = FALSE)
  }

  if (max < 0 && format != "file") {
    if (is.null(path))
      path <- tempfile()
    dir.create(path)
    message("Since an indeterminate number of rows is being returned, ",
      "and a path has not been specified, the results will be temporarly ",
      "stored here: ", path, " and if there are not more than 100k documents, ",
      "will be read in.")
    format <- "file"
    try_read <- TRUE
  }

  if (!is.null(path)) {
    if (!dir.exists(path))
      stop("Path '", path, "' must exist and be a directory",
        call. = FALSE)

    if (length(list.files(path)) > 0)
      message("Note: files already exist in directory '", path, "'")
  }

  structure(list(
    con = con,
    size = size,
    path = path,
    max = max,
    format = format,
    try_read = try_read,
    filters = list(),
    filter_text = NULL
  ), class = c("fq_query", "query_fetch"))
}
