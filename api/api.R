library(plumber)
# logger::log_layout(logger::layout_json(fields = c("time", "level", "pid", "msg")))

# INITALISATION -----------------------------------------------------------
message("Running with configuration: ", Sys.getenv("R_CONFIG_ACTIVE"))
logger::log_threshold(get(config::get(value = "loglevel"),  envir = asNamespace("logger")))
logger::log_info("sourcing classifier functions")
source("funs.R")
source("R/firestore.R")
source("R/storage.R")

logger::log_info("loading classfier data")
classifiers <- yaml::read_yaml("classifiers.yml")

db_files <- lapply(classifiers, function(x) x$db_path)

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
#pr$run(quiet = FALSE)
