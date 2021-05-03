
library(shiny)
library(insect)
library(RSQLite)
library(DT)
library(waiter)

## Notes
# When adding new genomes also update the isolate_metadata.csv file

conn <- dbConnect(RSQLite::SQLite(), "data/classifiers/GBS/210209.db")

varcharize <- function(s, k = 20){
    s <- gsub("[^ACGT]", "", s)
    if(nchar(s) < 20) return(integer(0))
    ncs <- nchar(s)
    s1 <- s # sense and antisense strands
    s2 <- rc(s1)
    s1s <- substring(s1, seq(1, ncs - k + 1), seq(k, ncs))
    s2s <- rev(substring(s2, seq(1, ncs - k + 1), seq(k, ncs)))
    smat <- rbind(s1s, s2s)
    out <- apply(smat, 2, min) # ~4s
    out <- unique(out)
    return(out)
}

ui <- fluidPage(
    use_waiter(),
    #theme = "bootstrap.css",
    shinyWidgets::setBackgroundImage(src = "rect.png"),
    titlePanel(h1("Rappseq", style="opacity:0.8; text-decoration: underline; line-height:20px; "), windowTitle = "Rappseq"),
    titlePanel(h4("Rapid pathogen sequencing and identification", style="opacity:0.8; line-height:15px;")), #text-decoration: overline; line-height: 0;
    titlePanel(h4("", style="opacity:0; line-height:10px;")),
    fluidRow(column(12,
                tabsetPanel(
                    #tabPanel("Instructions", br(), htmlOutput('Instructions', inline = FALSE)),
                    tabPanel("Classifier",
                         br(),
                         p("Welcome to Rappseq, a tool for identifying bacterial pathogens to MLST
                           (multilocus sequence type) level,
                           based on Oxford Nanopore long read sequence data."),
                         p("For optimal performance, only upload fastq files containing 1000 sequences or less.
                           Processing time will depend on the average sequence length,
                           but is generally 10-20s per 1000 sequences"),
                         p("The result table lists the most likely MLST matches with the best match at the top.
                           If the number of kmer hits for the best match is low (i.e. less than 100),
                           or multiple strains have a similar number of kmer hits,
                           this can be interpreted as an inconclusive result.
                           This often arises when the query strain is not present in the reference database.
                           As a rule of thumb, the best match should have at least 1000 diagnostic kmer hits
                           and at least 10x that of the next best hit."),
                         p("Rappseq is currently in development. Currently the features are restricted to Group B
                           Streptococcus (S. agalactiae) multilocus sequence types ST23, ST260 and ST261
                           from the University of Quesensland culture collection.
                           More species, serotypes and MLSTs will be available shortly."),
                         #htmlOutput('Instructions', inline = T),
                         br(),
                         # textInput("sequence2", label = "Paste long-read sequence for kmer classifier"),
                         # br(),
                         fileInput("file1", "Upload fastq file", multiple = FALSE),
                         actionButton("submit2", label = "Assign"),
                         br(),
                         br(),
                         dataTableOutput('table2')# %>% withSpinner(color="#0dc5c1")
                    ),
                    tabPanel("Reference data",
                         # br(),
                         # textInput(inputId = 'pass_code', label = "Passcode (optional)"),
                         br(),
                         dataTableOutput('table3'),
                         br()
                         )
                )
    ))
)

# Define server logic
server <- function(input, output) {
    w <- Waiter$new(id = "table2")
    options(shiny.maxRequestSize=100*1024^2)
    # cat(session$user)
    datasetInput <- reactive({

        metadata <- read.csv("data/isolate_metadata.csv", stringsAsFactors = FALSE)
        refseqs <- dir("data/refseqs/GBS")
        seqIDs <- sub("_.+", "", refseqs)
        stopifnot(all(seqIDs %in% metadata$IsolateID))
        stopifnot(all(metadata$IsolateID %in% seqIDs))
        metadata <- metadata[match(seqIDs, metadata$IsolateID),]

        # metadata$Download <- paste0("<a href='refseqs/GBS/", refseqs, "' download>fasta</a>")
        rownames(metadata) <- NULL
        colnames(metadata) <- c("Sequence_ID","Lab_Name","Isolate_ID","Genus","Species","Host",
                                "Origin","Year","Serotype","MLST")
        # if(!input$pass_code == "ky7%yJIOIjY6*UMOOK$jU") metadata$Download <- "Enter passcode for access"
        return(metadata)
    })

    observeEvent(input$submit2, {
        w$show()
        metadata <- datasetInput()
        # if(input$sequence2 != ""){
        #     x <- toupper(input$sequence2)
        #     x <- gsub(" ", "", x)
        #     x <- gsub("[^ACGT]", "", x)
        #     outtab <- data.frame(taxID = 0, name = "", count = 0)
        #     if(grepl("[^ACGTMRWSYKVHDBN]", x)) {
        #         outtab$name <- "Invalid characters in sequence"
        #     }else if(nchar(x) < 16L){
        #         #outtab$name <- "Short-read sequence must contain at least 100 characters"
        #     }else if(nchar(x) > 10000000L){
        #         outtab$name <- "Short-read sequence must contain fewer than 100000000 characters"
        #     }else{
        #         ints <- intemize(x, k = 20)
        #         if(length(ints) > 0L){
        #             qry <- paste0("SELECT taxID FROM kmers WHERE kmer IN (", paste0(ints, collapse=","), ");")
        #             outtab <- dbGetQuery(conn, qry)
        #             out <- sort(table(outtab$taxID), decreasing = T)
        #             sppnames <- qmastrains$Name[match(as.integer(names(out)), qmastrains$QMA_ID)]
        #             outtab <- data.frame(taxID = names(out), name = sppnames, hits = as.vector(out))
        #             #outtab$name <- qmastrains$Name[match(outtab$taxID, qmastrains$QMA_ID)]
        #         }else{
        #             # do nothing
        #         }
        #     }
        # }else{
            req(input$file1)
            # x <- readFASTQ("~/Documents/Worldfish/Rappseq/Mystery/Mystery1_nano_porechop_400.fastq", bin=F)
            x <- readFASTQ(input$file1$datapath, bin = F)
            ints <- unlist(lapply(x, varcharize, k = 20), use.names = F)
            if(length(ints) > 0L){
                qry <- paste0("SELECT taxID FROM kmers WHERE kmer IN ('", paste0(ints, collapse="','"), "');")
                outtab <- dbGetQuery(conn, qry)
                out <- sort(table(outtab$taxID), decreasing = T)
                sppnames <- metadata$MLST[match(names(out), metadata$MLST)]
                outtab <- data.frame(taxID = names(out), hits = as.vector(out))
                outtab <- DT::datatable(outtab, rownames = F,
                                        options = list(searching = FALSE,
                                                       filtering='none',
                                                       lengthChange = FALSE,
                                                       paging = FALSE,
                                                       info = FALSE),
                                        colnames = c("MLST", "Number of kmer hits"))
                #outtab <- data.frame(taxID = length(x), name = "") #######
            }
        #}
        output$table2 <- renderDataTable(outtab)
    }
)


    # output$table3 <- DT::renderDataTable({
    #     qmastrains <- datasetInput()
    #     qmastrains
    # })

    output$table3 <- renderDataTable({
        metadata <- datasetInput()
        metadata <- DT::datatable(metadata, escape = F, rownames = FALSE,
                                  colnames= c("Sequence ID","Lab name","Isolate ID","Genus","Species","Host",
                                                          "Origin","Year","Serotype","MLST"))
        metadata
    })
    output$Instructions <- renderUI(includeHTML("www/Instructions.html"))
}


onStop(function() {
    # print(DBI::dbGetInfo(con))
    message("disconnecting...")
    RSQLite::dbDisconnect(conn)
})

# Run the application
shinyApp(ui = ui, server = server)
