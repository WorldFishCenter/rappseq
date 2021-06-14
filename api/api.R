library(plumber)

# INITALISATION -----------------------------------------------------------

source("funs.R")

cat(list.files('.', recursive = T))

db_files <- list(
  sa_mlst = "data/classifiers/GBS/210524.db",
  sa_sero = "data/classifiers/GBS/210524_sero.db")

db_conn <- lapply(db_files, function(x) DBI::dbConnect(RSQLite::SQLite(), x))

pr <- plumber::plumb('plumber.R');

# Close your db connections on exit
pr$registerHooks(
  list(
    "exit" = function() {
      lapply(db_conn, DBI::dbDisconnect)
    }
  )
)

pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))
