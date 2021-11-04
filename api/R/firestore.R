# If Firestore is not loaded, it loads it
load_firestore_module <- function(){
  if (!exists("firestore")) {
    firestore <<- reticulate::import_from_path("firestore")
    return(0)
  }
  else {
    return(0)
  }
}

# Read a record from a database connection, currently using firestore as the backend
read_record <- function(
  record_id,
  collection = config::get(value = "firestore")$collection){

  load_firestore_module()
  firestore$read_document(document_name = record_id, collection = collection)
}

# Create a record from a database collection, currently using firestore as the backend
create_record <- function(
  record,
  record_id,
  collection = config::get(value = "firestore")$collection){

  load_firestore_module()
  firestore$create_document(document = record,
                            document_name = record_id,
                            collection = collection)
}

update_record <- function(
  record,
  record_id,
  collection = config::get(value = "firestore")$collection){
  load_firestore_module()
  firestore$update_document(document = record,
                            document_name = record_id,
                            collection = collection)
}

find_matching_classification <- function(
  data_hash,
  classifier,
  collection = config::get(value = "firestore")$collection
  ){
  load_firestore_module()
  firestore$find_matching(collection, data_hash, classifier)
}

