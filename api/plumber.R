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
  x <- read_fastq(request_values$fastq$datapath, bin = F)
  ints <- unlist(lapply(x, varcharize, k = 20), use.names = F)

  matches_tbl <- lapply(db_conn, function(x) find_matches(ints, x, hash))
  matches <- lapply(matches_tbl, as.list)

  list(
    data_filename = req$body$fastq$filename,
    data_content_type = req$body$fastq$content_type,
    matches = matches
  )
}
