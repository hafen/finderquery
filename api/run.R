library(plumber)
r <- plumb("api/plumber.R")
r$run(port = 8000)
