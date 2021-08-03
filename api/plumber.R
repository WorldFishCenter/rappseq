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

  request_values <- suppressWarnings(mime::parse_multipart(req))
  hash <- digest::digest(request_values$fastq$datapath, "md5", file = TRUE)
  logger::log_info("generated hash", hash, "for input file", req$body$fastq$filename)
  logger::log_info(hash, " calling matching procedures")
  matches <- match(request_values$fastq$datapath, db_conn, hash)
  logger::log_info(hash, " matching completed")

  list(
    data_filename = req$body$fastq$filename,
    data_content_type = req$body$fastq$content_type,
    matches = matches
  )
}
