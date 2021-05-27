library(plumber)

# INITALISATION -----------------------------------------------------------

source("funs.R")

mlst_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524.db")
sero_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524_sero.db")

pr <- plumber::plumb('plumber.R');

# Close your db connections on exit
pr$registerHooks(
  list(
    "exit" = function() {
      DBI::dbDisconnect(mlst_db)
      DBI::dbDisconnect(sero_db)
    }
  )
)

pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))
