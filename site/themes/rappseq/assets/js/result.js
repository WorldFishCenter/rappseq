var results = document.querySelector('.results');

const urlSearchParams = new URLSearchParams(window.location.search);
const params = Object.fromEntries(urlSearchParams.entries());
//let url =  `http://127.0.0.1:1234/result?request_id=${params.request_id}`
let url =  `https://rappseq-api-zrvf6kau3q-de.a.run.app/result?request_id=${params.request_id}`


fetch(url)
    .then(function(response) {
        if (!response.ok) {
            throw Error(response.error);
        }
        return response.json();
        })
    .then(function(text) {
        console.log(text);
        results.innerHTML = json2html.render(text, classification_template);
    })
    .catch(function(error) {
        console.log(error)
        results.innerHTML = json2html.render(error, not_found_template);
    });