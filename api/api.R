library(plumber)
# logger::log_layout(logger::layout_json(fields = c("time", "level", "pid", "msg")))

# INITALISATION -----------------------------------------------------------
logger::log_info("sourcing classifier functions")
source("funs.R")

db_files <- list(
  sa_mlst = "data/classifiers/GBS/210524.db",
  sa_sero = "data/classifiers/GBS/210524_sero.db",
  yr_sero = "data/classifiers/GBS/210607.db")

logger::log_info("connecting to kmer databases")
db_conn <- lapply(db_files, function(x) DBI::dbConnect(RSQLite::SQLite(), x))

pr <- plumber::plumb('plumber.R');

# Close your db connections on exit
pr$registerHooks(
  list(
    "exit" = function() {
      logger::log_info("disconnecting from databases")
      lapply(db_conn, DBI::dbDisconnect)
    }
  )
)

logger::log_info("initialising API")

pr$run(host = '0.0.0.0', port = as.numeric(Sys.getenv('PORT')))
# pr$run(quiet = FALSE)
