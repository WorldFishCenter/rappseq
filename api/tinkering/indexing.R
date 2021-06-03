# Create indices

mlst_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524 copy 2.db")
sero_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524_sero copy 2.db")

index_query <- paste("CREATE INDEX kmer_index ON", "kmers", "(kmer)")
DBI::dbSendQuery(conn = mlst_db, statement = index_query)
DBI::dbSendQuery(conn = sero_db, statement = index_query)

DBI::dbDisconnect(mlst_db)
DBI::dbDisconnect(sero_db)

## Compare times

source("funs.R")

mlst_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524.db")
sero_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524_sero.db")
mlst_index_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524 copy 2.db")
sero_index_db <- DBI::dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210524_sero copy 2.db")

path <- "data/Mystery1_nano_porechop_400.fastq"

hash <- digest::digest(path, "md5", file = TRUE)
x <- read_fastq(path, bin = F)
ints <- unlist(lapply(x, varcharize, k = 20), use.names = F)

# No indices
t <- system.time({
  matches_mlst <- find_matches(ints, mlst_db, hash)
  matches_sero <- find_matches(ints, sero_db, hash)

})
message(print(t[3]))

t <- system.time({
  matches_mlst_index <- find_matches_index(ints, mlst_index_db, hash)
  matches_sero_index <- find_matches_index(ints, sero_index_db, hash)
})
message(print(t[3]))
DBI::dbDisconnect(mlst_db)
DBI::dbDisconnect(sero_db)
DBI::dbDisconnect(mlst_index_db)
DBI::dbDisconnect(sero_index_db)
