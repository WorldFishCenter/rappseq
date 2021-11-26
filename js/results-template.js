
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

//Remove quality alerts for now as we don't have good thresholds yet
//json2html.component.add('good_match', good_match_template);
//json2html.component.add('no_match', bad_match_template);

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
    {"[]": "classifier", "obj": function(){return(this.matches)}},

]}

let not_found_template = {"<>": "div", "class": "text-center", "html": [
    {"<>": "h1", "class": "mb-4", "text": "No results found"},
    {"<>": "p", "class": "mb-4", "html": "We did not find any matching identification result. Please check the URL and try again."},
]}
