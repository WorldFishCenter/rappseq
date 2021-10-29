#* @apiTitle Rappseq API

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Identify pathogens in a fastq file
#* @post /identify
#* @parser multi
#* @param fastq:[file]
#* @parser octet
function(req, fastq){
  running_time <- system.time({
    request_time <- Sys.time()
    request_id <- digest::digest(req)

    logger::log_info("parsing request for ", req$body$fastq$filename)
    request_values <- suppressWarnings(mime::parse_multipart(req))
    hash <- digest::digest(request_values$fastq$datapath, "md5", file = TRUE)
    logger::log_info(hash, " generated for input file ", request_values$fastq$datapath)

    logger::log_info(hash, " calling matching procedures")
    matches <- match_all_db(request_values$fastq$datapath, db_conn, hash)

    logger::log_info("Formatting response")
    classifiers_response <- mapply(matches_to_list, matches, names(matches),
                                   SIMPLIFY = FALSE, USE.NAMES = FALSE)
  })

  response <- list(
    data_filename = req$body$fastq$filename,
    data_content_type = req$body$fastq$content_type,
    request_id = request_id,
    request_time = request_time,
    running_time = as.numeric(running_time[3]),
    data_hash = hash,
    classifiers = classifiers_response
  )

  logger::log_success(hash, " matching completed")

  response
}
