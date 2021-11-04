$(document).on('ready', function () {
  // INITIALIZATION OF CUSTOM FILE
  // =======================================================
  $('.js-file-attach').each(function () {
    var customFile = new HSFileAttach($(this)).init();
  });
});


var results = document.querySelector('.results');
let spinner = document.querySelector('#submit-spinner');
let button = document.querySelector('#submit-button');
let email = document.querySelector('input[type="email"]');
let fileField = document.querySelector('input[type="file"]');

let valid_file = false;
let valid_classifier = false;
let valid_form = false;

button.disabled = true;

function validate_file() {
    if (fileField.files.length > 0) {
        valid_file = true;
        //fileField.classList.remove("is-invalid");
        //fileField.classList.add("is-valid");
    } else {
        valid_file = false;
        //fileField.classList.remove("is-valid");
        //fileField.classList.add("is-invalid");
    }
}

function validate_classifier() {
    let checked_checboxes = document.querySelectorAll('input[name="classifier"]:checked');
    if (checked_checboxes.length > 0) {
        valid_classifier = true;
    } else {  
        valid_classifier = false;
    }
}

function validate_form(){

    if (valid_file && valid_classifier) {
        valid_form = true;
        button.disabled = false;
    } else {
        valid_form = false;
        button.disabled = true;
    }
}

let results_link_template = {"<>": "div", "class": "alert alert-soft-secondary text-center", "id": "results-alert", "html": [
    {"<>": "p", "text": "Your pathogen indentification request was successful and your results are ready."},
    {"<>": "a", "href": "${url}", "text": "View results", "class": "btn btn-secondary"}
]}

let error_template = {"<>": "div", "class": "alert alert-soft-danger", "id": "results-alert", "html": [
    {"<>": "h4", "class":"alert-heading", "html": [
        {"<>": "i", "class": "fas fa-exclamation-triangle mt-1 mr-1"}, 
        {"<>": "span", "text": " Sorry"}
    ]},
    {"<>": "p", "text": "Something went wrong and your pathogen indentification request was unsuccessful. Please contact us and we'll do our best to solve the problem."},
]}


function fetchpost() {
    // Activate spinner

    spinner.style.display = "inline-block"
    button.disabled = true
    button.lastElementChild.innerText = "Matching kmers..."

    // (A) GET FORM DATA
    let data = new FormData();
    data.append("fastq", fileField.files[0]); // Add the file

    let classifier = []
    let checked_checboxes = document.querySelectorAll('input[name="classifier"]:checked');
    for (let i = 0; i < checked_checboxes.length; i++) {
        classifier.push(checked_checboxes[i].value)
    }
    data.append("classifier", classifier)

    data.append("email", email.value)


    // (B) FETCH
    fetch("https://rappseq-api-zrvf6kau3q-de.a.run.app/identify", {
    //fetch("http://127.0.0.1:1234/identify", {
            method: 'post',
            body: data
        })
        .then(function(response) {
            return response.json();
        })
        .catch(function(error) {
            console.log(error)
        })
        .then(function(text) {
            console.log(text);
            spinner.style.display = "none"
            button.lastElementChild.innerText = "Identify pathogen"
            button.disabled = false
            if (typeof text.request_id !== 'undefined') {
                let results_url = "../result/?request_id=" + text.request_id;
                window.location.href = results_url;
                results.innerHTML = json2html.render({url : results_url}, results_link_template);
            } else {
                results.innerHTML = json2html.render({}, error_template);
            }
            
            var resultsAlert = document.getElementById("results-alert");
            resultsAlert.scrollIntoView();
            //results.innerHTML = json2html.render(text.classifiers[0],table_template);
        });

    // (C) PREVENT HTML FORM SUBMIT
    return false;
}

  //results.innerHTML = json2html.render(dummy_data, classification_template);