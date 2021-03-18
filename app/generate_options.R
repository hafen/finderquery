library(finderquery)

Sys.unsetenv("NO_PROXY")
Sys.unsetenv("HTTPS_PROXY")
Sys.unsetenv("HTTP_PROXY")
Sys.unsetenv("https_proxy")
Sys.unsetenv("http_proxy")

con <- finder_connect("10.49.4.6")

fld <- c("title", "link", "description", "contentType", "pubDate", "source", 
  "language", "guid", "category", "favicon", "entity", "georss", 
  "fullgeo", "tonality", "text", "quote", "enclosure", "translate", 
  "keyword", "location", "relevance")

lng <- fq_valid_languages(con)
cnt <- fq_valid_countries(con)
dup <- fq_valid_duplicate(con)
cat <- fq_valid_categories(con)
src <- fq_valid_sources(con)

opts <- list(
  fields = fld,
  vLanguages = lng,
  vCountries = cnt,
  vDuplicate = dup,
  vCategories = cat,
  vSources = src
)

out <- ""
for (nm in names(opts)) {
  out <- c(out, paste0("\nexport const ", nm, " = ", jsonlite::toJSON(opts[[nm]])))
}

writeLines(out, "app/src/options.js")
