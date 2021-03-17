#' Set connection details to Finder engine
#'
#' @param host The base host, defaults to 127.0.0.1
#' @param port The port to connect to (optional)
#' @examples
#' \dontrun{
#' con <- finder_connect(host = "localhost")
#' }
#' @export
finder_connect <- function(
  host = "127.0.0.1", port = NULL
) {
  port <- ifelse(is.null(port), "", paste0(":", port))
  con <- paste0(host, port, "/Finder/Finder?")

  structure(list(
    con = con
  ), class = "finder_connection")
}

enc <- function(x) {
  utils::URLencode(x, reserved = TRUE)
}

# #' @export
# print.finder_connection <- function(x, ...) {
#   # str(x[-1], 1)
#   "finder_connection object"
# }
