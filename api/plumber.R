library(plumber)

#* @apiTitle Rappseq API

#* @filter cors
cors <- function(res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  plumber::forward()
}

#* Identify pathogens in a fastq file
#* @param fastq:[file]
#* @post /identify
#* @parser multi
#* @parser octet
function(req, fastq){

  request_values <- mime::parse_multipart(req)
  x <- read_fastq(request_values$fastq$datapath, bin = F)
  ints <- unlist(lapply(x, varcharize, k = 20), use.names = F)

  list(
    data_filename = req$body$fastq$filename,
    data_content_type = req$body$fastq$content_type,
    example_kmers = head(ints)
  )
}


# FUNCTIONS ---------------------------------------------------------------


read_fastq <- function(file, bin = TRUE){
  x <- scan(file = file, what = "", sep = "\n", quiet = TRUE)
  if (!grepl("^@", x[1]))
    stop("Not a valid fastq file\n")
  seqs <- toupper(x[seq(2, length(x), by = 4)])
  seqnames <- gsub("^@", "", x[seq(1, length(x), by = 4)])
  quals <- x[seq(4, length(x), by = 4)]
  if (bin) {
    seqs2 <- char2dna(seqs)
    quals2 <- lapply(quals, .char2qual)
    res <- mapply(function(x, y) structure(x, quality = y),
                  seqs2, quals2, SIMPLIFY = FALSE)
    names(res) <- seqnames
    class(res) <- "DNAbin"
    return(res)
  }
  else {
    attr(seqs, "quality") <- quals
    names(seqs) <- seqnames
    return(seqs)
  }
}

char2dna <- function(z, simplify = FALSE) {
  dbytes <- as.raw(c(136, 24, 72, 40, 96, 144, 192, 48, 80,
                     160, 112, 224, 176, 208, 240, 240, 4, 2))
  indices <- c(65, 84, 71, 67, 83, 87, 82, 89, 75, 77, 66,
               86, 72, 68, 78, 73, 45, 63)
  vec <- raw(89)
  vec[indices] <- dbytes
  s2d1 <- function(s) vec[as.integer(charToRaw(s))]
  if (length(z) == 1 & simplify) {
    res <- s2d1(z)
    attr(res, "quality") <- .char2qual(attr(z, "quality"))
  }
  else {
    res <- lapply(z, s2d1)
    if (!is.null(attr(z, "quality"))) {
      quals <- lapply(attr(z, "quality"), .char2qual)
      for (i in seq_along(res)) attr(res[[i]], "quality") <- quals[[i]]
    }
  }
  attr(res, "rerep.names") <- attr(z, "rerep.names")
  attr(res, "rerep.pointers") <- attr(z, "rerep.pointers")
  class(res) <- "DNAbin"
  return(res)
}

varcharize <- function(s, k = 20){
  s <- gsub("[^ACGT]", "", s)
  if (nchar(s) < 20) return(integer(0))
  ncs <- nchar(s)
  s1 <- s # sense and antisense strands
  s2 <- rc(s1)
  s1s <- substring(s1, seq(1, ncs - k + 1), seq(k, ncs))
  s2s <- rev(substring(s2, seq(1, ncs - k + 1), seq(k, ncs)))
  smat <- rbind(s1s, s2s)
  out <- apply(smat, 2, min) # ~4s
  out <- unique(out)
  return(out)
}

rc <- function(z){
  rc1 <- function(zz) {
    s <- strsplit(zz, split = "")[[1]]
    s <- rev(s)
    dchars <- strsplit("ACGTMRWSYKVHDBNI", split = "")[[1]]
    comps <- strsplit("TGCAKYWSRMBDHVNI", split = "")[[1]]
    s <- s[s %in% dchars]
    s <- dchars[match(s, comps)]
    s <- paste0(s, collapse = "")
    return(s)
  }
  z <- toupper(z)
  tmpnames <- names(z)
  res <- unname(sapply(z, rc1))
  if (!is.null(attr(z, "quality"))) {
    strev <- function(x) sapply(lapply(lapply(unname(x),
                                              charToRaw), rev), rawToChar)
    attr(res, "quality") <- unname(sapply(attr(z, "quality"),
                                          strev))
  }
  names(res) <- tmpnames
  return(res)
}

