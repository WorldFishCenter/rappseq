

var results = document.querySelector('.results');
let spinner = document.querySelector('#submit-spinner')
let button = document.querySelector('#submit-button')

let row_template = {
    '<>': "tr", 
    'html': [
        {'<>': "th", 'text': "${name}", "scope": "row"},
        {'<>': "td", 'text': "${value}"}
    ]
}

json2html.component.add('row',row_template);

let table_template = {
    '<>': "table",
    'class': "table", 
    'html': [
        {'<>': "thead", 'class': "", 'html': [
            {'<>': "tr", 'html': [
                {'<>': "th", "text": "${type}", "scope": "col"}, 
                {'<>': "th", "text": "Number of matches", "scope": "col"}
            ]}
        ]},
        {'<>': "tbody", 'html': [{'[]': 'row', "obj": function(){return(this.matches);}}]}
    ]
}

json2html.component.add('table',table_template);

let hidden_table_template = {
    '<>': "div", 'id': "${id}-accordion", 'html': [
        {'<>': "div", 'class': "card overflow-hidden mb-3", 'html': [
            {'<>': "div", 'class': "card-header card-collapse", 'id': '${id}-table-heading', 'html': [
                {'<>': "button", 'class': "btn btn-link btn-block card-btn d-flex justify-content-between p-3 text-primary collapsed", 'data-toggle': 'collapse', 'data-target': '#${id}-table', 'aria-controls': '${id}-table', 'aria-expanded': 'false', 'html': [
                    {'<>': "span", 'class': "text-truncate", 'text': "Matches table"},
                    {'<>': "span", 'class': "card-btn-toggle", 'html': [
                        {'<>': "span", 'class': "card-btn-toggle-default", 'text': "+"}, 
                        {'<>': "span", 'class': "card-btn-toggle-active", 'text': "-"}
                    ]}
                ]}
            ]}, 
            {'<>': "div", 'class': "collapse", 'id': '${id}-table', 'aria-labelledby': '${id}-table-heading', 'data-parent': '#${id}-accordion', 'html': [
                {'<>': "div", 'class': "card-body text-center", 'html': [
                    {'[]': "table"}
                ]}
            ]}
        ]},
    ]
}

json2html.component.add('table-accordion',hidden_table_template);

let classifier_template = {
    '<>': "div", 
    'class': "border-bottom my-4 py-3",
    'html': [
            {'<>': "h2", 'class': 'mb-4', 'text': "${name}"},
            {"[]": function(){if(this.best_match.good[0]) return("good_match")}},
            {"[]": function(){if(!this.best_match.good[0]) return("no_match")}},
            {"[]": "pathogen_result"},
            {'<>': "div", 'class': "small", 'html': [
                {'<>': "dl", 'class': "row mb-0", 'html': [
                    {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Classifier name"},
                    {'<>': "dd", 'class': "col-sm-6", 'text': "${name}"},
                ]},
                {'<>': "dl", 'class': "row mb-0", 'html': [
                    {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Level"},
                    {'<>': "dd", 'class': "col-sm-6", 'text': "${type}"},
                ]},
                {'<>': "dl", 'class': "row mb-0", 'html': [
                    {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Kmer database"},
                    {'<>': "dd", 'class': "col-sm-6", 'text': "${db_path}"},
                ]},
            ]},
            {'[]': "table-accordion"}
    ]
}

json2html.component.add('classifier', classifier_template);

let pathogen_result_template = {'<>': "p", 'class': 'mb-4', "html": [
    {"text": "The pathogen with the most matches is "},
    {'<>': "span", "class": "font-weight-bold", "text": "${name} ${matches.0.name}"}, 
    {"text": " with ${matches.0.value} out of ${total_matches} matches "},
    {"text": function(){ return('(' + Math.round(this.best_match.prop * 100) + '%)')}},
]}

json2html.component.add('pathogen_result', pathogen_result_template);

let good_match_template = {"<>": "div", "class": "alert alert-soft-primary", "role" : "alert", 
"html": [
    {"<>": "p", "class": "font-weight-bold mb-0", "html": "&#x1F60A; We found a good match for your sequence"},
]}

let bad_match_template = {"<>": "div", "class": "alert alert-soft-danger", "role" : "alert", 
"html": [
    {"<>": "p", "class": "font-weight-bold mb-0", "html": "&#x1F641; We did NOT find a good match for your sequence in our database."},
]}

json2html.component.add('good_match', good_match_template);
json2html.component.add('no_match', bad_match_template);

let classification_template = {"<>": "div", "html": [
    {"<>": "h1", "class": "mb-4", "text": "Identification results"},
    //{"[]": "pathogen_result", "obj" : function(){return(this.classifiers)}},
    {'<>': "div", 'class': "my-4 py-3 border-bottom small", 'html': [
        {'<>': "h3", "class": "mb-4", "text": "Request details"},
        {'<>': "dl", 'class': "row mb-0", 'html': [
            {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Sequence file"},
            {'<>': "dd", 'class': "col-sm-6", 'text': "${data_filename}"},
        ]},
        {'<>': "dl", 'class': "row mb-0", 'html': [
            {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Request ID"},
            {'<>': "dd", 'class': "col-sm-6", 'text': "${request_id}"},
        ]},
        {'<>': "dl", 'class': "row mb-0", 'html': [
            {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Request time"},
            {'<>': "dd", 'class': "col-sm-6", 'text': "${request_time} UTC"},
        ]},
        {'<>': "dl", 'class': "row mb-0", 'html': [
            {'<>': "dt", 'class': "col-sm-4 text-secondary", 'text': "Processing time"},
            {'<>': "dd", 'class': "col-sm-6", 'text': "${running_time} s"},
        ]},
    ]},
    {"[]": "classifier", "obj": function(){return(this.classifiers)}},

]}

function fetchpost() {
    // Activate spinner

    spinner.style.display = "inline-block"
    button.disabled = true
    button.lastElementChild.innerText = "Matching kmers..."

    // (A) GET FORM DATA
    let data = new FormData();
    let fileField = document.querySelector('input[type="file"]');
    data.append("fastq", fileField.files[0]);

    // (B) FETCH
    //fetch("https://rappseq-api-zrvf6kau3q-de.a.run.app/identify", {
    fetch("http://127.0.0.1:4869/identify", {
        
            method: 'post',
            body: data
        })
        .then(function(response) {
            return response.json();
        })
        .then(function(text) {
            console.log(text);
            spinner.style.display = "none"
            button.lastElementChild.innerText = "Identify pathogen"
            button.disabled = false
            //results.append();
            results.innerHTML = json2html.render(text, classification_template);
            //results.innerHTML = json2html.render(text.classifiers[0],table_template);
        })
        .catch(function(error) {
            console.log(error)
        });

    // (C) PREVENT HTML FORM SUBMIT
    return false;
}

// create test data for json2html
let dummy_data = {
    "data_filename": [
      "Mystery4_nano_porechop_400.fastq"
    ],
    "data_content_type": [
      "application/octet-stream"
    ],
    "request_id": [
      "bdb2cf42541aafc2ce493f110bba7313"
    ],
    "request_time": [
      "2021-10-29 02:12:14"
    ],
    "running_time": [
      16.173
    ],
    "data_hash": [
      "c21245232a735279eff56ec9b4b7c78f"
    ],
    "classifiers": [
      {
        "name": [
          "Group B Streptococcus- multilocus sequence type"
        ],
        "binomial_name": [
          "Streptococcus agalactiae"
        ],
        "type": [
          "Sequence type"
        ],
        "db_path": [
          "data/classifiers/GBS/210524.db"
        ],
        "id": [
          "sa_mlst"
        ],
        "total_matches": [
          2310
        ],
        "best_match": {
          "good": [
            false
          ],
          "prop": [
            0.8143
          ]
        },
        "matches": [
          {
            "name": [
              "260"
            ],
            "value": [
              1881
            ]
          },
          {
            "name": [
              "103"
            ],
            "value": [
              87
            ]
          },
          {
            "name": [
              "22"
            ],
            "value": [
              78
            ]
          },
          {
            "name": [
              "261"
            ],
            "value": [
              56
            ]
          },
          {
            "name": [
              "617"
            ],
            "value": [
              54
            ]
          },
          {
            "name": [
              "23"
            ],
            "value": [
              42
            ]
          },
          {
            "name": [
              "26"
            ],
            "value": [
              25
            ]
          },
          {
            "name": [
              "609"
            ],
            "value": [
              19
            ]
          },
          {
            "name": [
              "17"
            ],
            "value": [
              16
            ]
          },
          {
            "name": [
              "552"
            ],
            "value": [
              14
            ]
          },
          {
            "name": [
              "61"
            ],
            "value": [
              11
            ]
          },
          {
            "name": [
              "1"
            ],
            "value": [
              10
            ]
          },
          {
            "name": [
              "7"
            ],
            "value": [
              10
            ]
          },
          {
            "name": [
              "12"
            ],
            "value": [
              6
            ]
          },
          {
            "name": [
              "459"
            ],
            "value": [
              1
            ]
          }
        ]
      },
      {
        "name": [
          "Group B Streptococcus- serotype"
        ],
        "binomial_name": [
          "Streptococcus agalactiae"
        ],
        "type": [
          "Serotype"
        ],
        "db_path": [
          "data/classifiers/GBS/210524_sero.db"
        ],
        "id": [
          "sa_sero"
        ],
        "total_matches": [
          21064
        ],
        "best_match": {
          "good": [
            true
          ],
          "prop": [
            0.984
          ]
        },
        "matches": [
          {
            "name": [
              "Ib"
            ],
            "value": [
              20728
            ]
          },
          {
            "name": [
              "Ia"
            ],
            "value": [
              113
            ]
          },
          {
            "name": [
              "II"
            ],
            "value": [
              89
            ]
          },
          {
            "name": [
              "VI"
            ],
            "value": [
              56
            ]
          },
          {
            "name": [
              "V"
            ],
            "value": [
              52
            ]
          },
          {
            "name": [
              "III"
            ],
            "value": [
              25
            ]
          },
          {
            "name": [
              "IV"
            ],
            "value": [
              1
            ]
          }
        ]
      },
      {
        "name": [
          "Yersinia ruckeri- serotype"
        ],
        "binomial_name": [
          "Yersinia ruckeri"
        ],
        "type": [
          "Serotype"
        ],
        "db_path": [
          "data/classifiers/GBS/210607.db"
        ],
        "id": [
          "yr_sero"
        ],
        "total_matches": [
          2
        ],
        "best_match": {
          "good": [
            false
          ],
          "prop": [
            1
          ]
        },
        "matches": [
          {
            "name": [
              "O1a"
            ],
            "value": [
              2
            ]
          }
        ]
      }
    ]
  }

  //results.innerHTML = json2html.render(dummy_data, classification_template);