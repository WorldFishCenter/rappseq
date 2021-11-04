# If storage is not loaded, it loads it
load_storage_module <- function(){
  if (!exists("storage")) {
    storage <<- reticulate::import_from_path("storage")
    return(0)
  }
  else {
    return(0)
  }
}

# Function to save sequence file in google cloud storage bucket if it doesn't exist. Returns 0 if successful
save_in_bucket <- function(
  path,
  file_extension,
  data_hash,
  directory = config::get(value = "storage")$directory,
  bucket = config::get(value = "storage")$bucket) {

  load_storage_module()
  blob_name <- file.path(directory, paste(data_hash, file_extension, sep = "."))

  blob_already_exists <- storage$check_blob_existence(bucket, blob_name)

  if (!blob_already_exists) storage$upload_blob(bucket, path, blob_name)

  return(0)
}
