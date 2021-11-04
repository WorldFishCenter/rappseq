import os
from google.cloud import firestore

os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = str("auth/rappseq-935a00e0eb39.json")
db = firestore.Client(project='rappseq')

def create_document(document, document_name, collection):
  """Creates a record in a firestore database
  
  Args: 
    document: dictionary for the object to be stored
    document_name: name for the document 
    collection: name of the collection where the document lives
  """
  
  doc_ref = db.collection(collection).document(document_name)
  doc_ref.set(document)
  return(0)

def read_document(document_name, collection):
  """Reads a record in a firestore database
  
  Args: 
    document_name: name for the document 
    collection: name of the collection where the document livess
  """
  doc_ref = db.collection(collection).document(document_name)
  doc = doc_ref.get()
  document =  doc.to_dict()
  return(document)

def update_document(document, document_name, collection):
  """Updates an existing record in a firestore database
  
  Args: 
    document: dictionary for the object to be stored
    document_name: name for the document 
    collection: name of the collection where the document lives
  """
  doc_ref = db.collection(collection).document(document_name)
  doc_ref.update(document)
  return(0)

def find_matching(collection, data_hash, classifier):
  """Queries a firestore database for documents matching a hash
  
  Args: 
    collection: name of the collection where the document lives
    data_hash: hash to be matched
  """
  query = db.collection(collection).where(
    'data_hash', '==', data_hash).where(
      'requested_classifiers', 'array_contains', classifier).where(
        'match_completed', '==', True).order_by(
        'request_time', direction=firestore.Query.DESCENDING).limit(1)
  docs = query.stream()
  documents = [doc.to_dict() for doc in docs]
  return(documents)
