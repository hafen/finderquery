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

#* Get meta data to list in the study table
#* @serializer unboxedJSON
#* @get /get_ndocs
function(
  country, language, source, duplicate, pubdate, indexdate, text,
  tonality, entityid, georssid, guid
) {
  # browser()
  return(1000)
}
