

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
        {'<>': "thead", 'class': "thead-light", 'html': [
            {'<>': "tr", 'html': [
                {'<>': "th", "text": "${type}", "scope": "col"}, 
                {'<>': "th", "text": "Number of matches", "scope": "col"}
            ]}
        ]},
        {'<>': "tbody", 'html': [{'[]': 'row', "obj": function(){return(this.matches);}}]}
    ]
}


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
            results.innerHTML = json2html.render(text.classifiers[0],table_template);
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
      "UPM_3_100seqs.fastq"
    ],
    "data_content_type": [
      "application/octet-stream"
    ],
    "data_hash": [
      "e8035ed367de9f099b42634214f69e05"
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
        "matches": [
          {
            "name": [
              "22"
            ],
            "value": [
              74
            ]
          },
          {
            "name": [
              "617"
            ],
            "value": [
              61
            ]
          },
          {
            "name": [
              "1"
            ],
            "value": [
              50
            ]
          },
          {
            "name": [
              "609"
            ],
            "value": [
              33
            ]
          },
          {
            "name": [
              "26"
            ],
            "value": [
              29
            ]
          },
          {
            "name": [
              "103"
            ],
            "value": [
              28
            ]
          },
          {
            "name": [
              "261"
            ],
            "value": [
              23
            ]
          },
          {
            "name": [
              "459"
            ],
            "value": [
              9
            ]
          },
          {
            "name": [
              "7"
            ],
            "value": [
              9
            ]
          },
          {
            "name": [
              "61"
            ],
            "value": [
              8
            ]
          },
          {
            "name": [
              "23"
            ],
            "value": [
              4
            ]
          },
          {
            "name": [
              "552"
            ],
            "value": [
              4
            ]
          },
          {
            "name": [
              "12"
            ],
            "value": [
              2
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
        "matches": [
          {
            "name": [
              "III"
            ],
            "value": [
              541
            ]
          },
          {
            "name": [
              "V"
            ],
            "value": [
              118
            ]
          },
          {
            "name": [
              "Ib"
            ],
            "value": [
              109
            ]
          },
          {
            "name": [
              "II"
            ],
            "value": [
              82
            ]
          },
          {
            "name": [
              "VI"
            ],
            "value": [
              62
            ]
          },
          {
            "name": [
              "Ia"
            ],
            "value": [
              38
            ]
          },
          {
            "name": [
              "IV"
            ],
            "value": [
              9
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
        "matches": [
          {
            "name": [
              "O1a"
            ],
            "value": [
              2
            ]
          },
          {
            "name": [
              "O2"
            ],
            "value": [
              2
            ]
          }
        ]
      }
    ]
  }

