# AquaPath

AquaPath is a rapid pathogen sequencing and identification tool. 
This repository contains the code for the tool.

AquaPath uses GitHub Actions as a continuous development system. 
That means that updating the code in the repository automatically trigger the update and redeployment of the services that comprise AquaPath. 

AquaPath is comprised by two sub-systems. 
A web based frontend that provides inormation about the tool and serves as an user interface. 
The backend is formed by an R based API deployed in Google Cloud Services infrastructure. 

## Backend

The backbone of Aquapath's backend is formed by a R based API. 
This API is deployed as a serverless service in Google Cloud Run

All the code

### Endpoints

#### Identifycation endpoint

#### Results endpoint

### Continuous development


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

