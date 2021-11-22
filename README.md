# Lab in a Backpack

Lab in a Backpack is a rapid pathogen sequencing and identification workflow. 
This repository contains the code for the cloud based identification tool.

---
**Content**

- [Backend](#backend)
- [Frontend](#frontend)
- [How-to](#how-to)
---

## Intro

Lab in a Backpack uses GitHub Actions as a continuous development system. 
That means that updating the code in the repository automatically trigger the update and redeployment of the services that comprise AquaPath. 
After updating code or content the new changes will be live in a couple of minutes. 

Lab in a Backpack is comprised by two sub-systems. 
A web based frontend that provides inormation about the tool and serves as an user interface. 
The backend is formed by an R based API deployed in Google Cloud Services infrastructure. 

![Lab in a Backpack structure diagram](aquapath-structure.png)

## Backend

The backbone of Lab in a Backpack's backend is formed by a R based API. 
This RESTFUL API is deployed as a serverless service in Google Cloud Run. 

All the code for this service is stored in the [api](api) directory.

The API is built using [plumber](https://www.rplumber.io/) API generation tool for R. 
The api is encapsulated in a [docker container](https://www.docker.com/resources/what-container). 
This containers contains almost everything (code, runtime, system tools, libraries and settings) needed to run the API in Google Cloud Run. 

The docker container executes the (api.R)[api/api.R] script. 
This scripts loads the configurations, connects to the kmer databases for each classifier, and initialises the plumber endpoints. 

### Endpoints

The API endpoints are defined in the [plumber.R](api/plumber.R) file.
The Swagger documentation for the API can be accessed via [https://rappseq-api-zrvf6kau3q-de.a.run.app/__docs__/](https://rappseq-api-zrvf6kau3q-de.a.run.app/__docs__/s) 

#### Identifycation endpoint

The `/identification` endpoint accepts POST requests and accepts the fastq files containing the sequences as well as other metadata sent with the request. 
This endpoint return a json message with the request id once the identification is completed. 
The results of the identification can then be accessed using the `/results` endpoint using this request id. 

When an identification request is received the API: 

- Creates a unique ID for the request and the sequence file received
- Stores the request information in the Google firestore request database
- Saves the submitted sequence file in the Google cloud storage bucket 
- Finds matches for each classifier requested
  - If the matching has already been done in this file, retrieves previous results from the Google firestore request database
  - Otherwise, it looks matches in the corresponding kmer database for the classifier
- Stores the matching results in the Google firestore request database
- Returns the request ID as a json payload

#### Results endpoint

The `/results` endpoint accepts GET requests and accepts the request ids of an existing request. 
It returns a json object containing information about the request and the matching results. 

When a results request is received the API:

- Consults the existing results in the Google firestore request database
- Returns the data obtained from the database as a json object 

### Continuous development

aqua


## Front-end

AquaPath front-end is built as a static website. 
This makes it fast and very cost-effective. 
As a development framework we use Hugo. 

All the code for the front-end can be found in the [site](site) directory.

### Content

The contents of the front-end are coded in four different types of files). 

* Markdown files that can be found in the [site/content](site/content) directory. These include general pages in the website as well as pathogen profiles. 
* Hugos [configuration file](site/config.yaml)
* HTML [layouts](site/themes/rappseq/layouts) in the "rappseq" theme
* Javascript based templates in the "rappseq" theme assets. These are used to dynamically display the responses of API requests to the backend. 

Modifying the Markdown based content of AquaPath does not require any specialised knowledge. 
This can be done by creating or the editing markdown files in the [site/content](site/content) directory; either from a local copy of the repository or directly from GitHub web interface. 

Modyfing all other content of AquaPath, including the landing page, the identification and results page as well as aesthetic changes to the website requires working (but basic) knowledge of HTML, (S)CSS, and JavaScript. 
Knowledge of Hugo or go templating in general is also helpful. 

### Design

### Identification

### Results

### Continuous development

