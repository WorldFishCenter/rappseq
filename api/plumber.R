#* @apiTitle Rappseq API

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Identify pathogens in a fastq file
#* @post /identify
#* @param fastq:[file]
#* @parser multi
function(req, res){
  logger::log_info("Request received: /identify")

  running_time <- system.time({

    request_time <- Sys.time()
    request_id <- digest::digest(req)

    logger::log_info(request_id, " parsing request for ", req$body$fastq$filename)
    request_values <- suppressWarnings(mime::parse_multipart(req))
    classifiers <- strsplit(request_values$classifier, ",")[[1]]

    file_hash <- digest::digest(request_values$fastq$datapath, "md5", file = TRUE)
    logger::log_info(request_id, " generated hash ", file_hash, " for input file ", request_values$fastq$datapath)

    logger::log_info(request_id, " storing request information")
    request_info <- list(
        data_filename = req$body$fastq$filename,
        request_id = request_id,
        request_time = request_time,
        data_hash = file_hash,
        requested_classifiers = classifiers,
        email = request_values$email,
        match_completed = FALSE)
    create_record(request_info, request_id)

    logger::log_info(request_id, " calling matching procedures")
    matches <- match_kmers(request_values$fastq$datapath, classifiers, db_conn, file_hash)

    logger::log_info(request_id, " formatting response")
    classifiers_result <- mapply(
      matches_to_list, matches, names(matches),
      SIMPLIFY = FALSE, USE.NAMES = FALSE)
  })

  results <- list(
    running_time = as.numeric(running_time[3]),
    matches = classifiers_result,
    match_completed = TRUE)

  logger::log_info(request_id, " updating request information")
  update_record(results, request_id)

  logger::log_success(request_id, " matching completed")

  list(request_id = request_id)
}

#* Retrieve information about a previous request
#* @get /result
#* @serializer json list(force=TRUE)
function(request_id, res){
  logger::log_info("Requested results for request_id ", request_id, " in /result endpoint")
  record <- read_record(record_id = request_id)

  if (is.null(record)){
    res$status <- 501
    return(list(error = "Request not found"))
  } else {
    record <- as.list(record)
    record$request_time <- NULL
  }

  return(record)
}
