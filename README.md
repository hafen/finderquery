# finderquery

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- [![R build status](https://github.com/hafen/finderquery/workflows/R-CMD-check/badge.svg)](https://github.com/hafen/finderquery/actions) -->
<!-- badges: end -->

The finderquery package provides utilities for building Finder queries in a simple and intuitive way. It also provides an API that uses these utilities as well as code for a web application that provides an interface for building a query and downloading documents.

Note that this package is not of general use to the public. It is built to work against the Finder system. It is only made public to make it easier to share, as there is nothing proprietary stored in this repository.

## Installation

You can install the package from Github with:

```r
# install.packages("remotes")
remotes::install_github("hafen/finderquery")
```

## Examples

See the full "usage" documentation for many more examples as well as details on how everything works.

```r
library(finderquery)

# specify Finder location
con <- finder_connect(Sys.getenv("FINDER_IP"))

# query all documents in German that have category "CoronavirusInfection" 
# that were published in the last two days, sorted by publication date
res <- fq_query_fetch(con) %>%
  fq_filter_language("de") %>%
  fq_filter_category("CoronavirusInfection") %>%
  fq_filter_pubdate(from = as.Date(Sys.time()) - 2) %>%
  fq_run()

# count documents by top 10 categories over the last 2 days
res <- fq_query_facet(con) %>%
  fq_filter_pubdate(from = as.Date(Sys.time()) - 2) %>%
  fq_facet_by("category", limit = 10) %>%
  fq_run()

# count documents daily for all "CoronavirusInfection" articles over
# the last 20 days, hourly
res <- fq_query_facet(con) %>%
  fq_filter_category("coronavirusinfection") %>%
  fq_facet_date_range(
    start = as.Date(Sys.time()) - 20,
    end = as.Date(Sys.time()),
    gap = fq_range_gap(1, "HOUR")
  ) %>%
  fq_run()
```
