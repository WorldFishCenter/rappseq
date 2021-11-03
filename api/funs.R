# FUNCTIONS ---------------------------------------------------------------

find_matches <- function(ints, this_db, hash){

  logger::log_info(hash, " finding matches in ", this_db@dbname)
  ints_df <- data.frame(kmer = unique(ints), stringsAsFactors = FALSE)
  temp_table_name <- paste0("_", hash, "_",
                            digest::digest(runif(1), algo = "md5"))
  DBI::dbCreateTable(conn = this_db, name = temp_table_name,
                     temporary = TRUE, fields = ints_df)
  # Ask R to delete the temporary table on exit to avoid using extra resources
  on.exit(DBI::dbRemoveTable(conn = this_db, name = temp_table_name))
  DBI::dbAppendTable(conn = this_db, name = temp_table_name, value = ints_df)
  qry <- paste0("SELECT taxID FROM (SELECT *",
                "FROM kmers JOIN ",
                temp_table_name, " USING (kmer))")
  out <- DBI::dbGetQuery(conn = this_db, statement =  qry)
  sort(table(out$taxID), decreasing = T)
}

#' @author Shaun Wilkinson
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

#' @author Shaun Wilkinson
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

#' @author Shaun Wilkinson
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

#' @author Shaun Wilkinson
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

match_kmers <- function(path, classifiers, db_conn, hash = digest::digest(runif(1))) {

  logger::log_info(hash, " reading fastq file")
  x <- read_fastq(path, bin = F)
  logger::log_info(hash, " extracting kmers")
  ints <- unlist(lapply(x, varcharize, k = 20), use.names = F)
  logger::log_info(hash, " matching kmers")
  lapply(db_conn[classifiers], function(x) find_matches(ints, x, hash))
}

# Converts the table with matches to a list that can be used as the output of
# the classifier
matches_to_list <- function(x, classifier){
  matches <- mapply(function(x, y) {list(name = x, value = y)}, names(x), x,
         SIMPLIFY = F, USE.NAMES = FALSE)

  total_matches <- sum(x)

  matches_info <- list(
    id = classifier,
    total_matches = total_matches,
    best_match = list(
      good = as.logical(x[1] >= 200 & x[1] / total_matches > 0.9),
      prop = x[1] / total_matches),
    matches = matches)
  classifier_info <- classifiers[[classifier]]
  c(classifier_info, matches_info)
}

decode_classifiers <- function(x){
  plumber::parser_text(x)
  strsplit(x, ",")[[1]]
}
