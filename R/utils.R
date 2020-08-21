#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`

check_class <- function(obj, class_name, fn_name) {
  if (length(class_name) == 1) {
    cls <- paste0("'", class_name, "'")
  } else {
    cls <- paste0("'", class_name, "'", collapse = " or ")
  }
  if (!inherits(obj, class_name))
    stop(fn_name, "() expects an object of class ", cls, call. = FALSE)
}
