sheet_rmd_paths <- list.files("data-sheets", pattern = "Rmd$", full.names = TRUE)
lapply(sheet_rmd_paths, rmarkdown::render)
sheet_html_paths <- list.files("data-sheets", pattern = "html$", full.names = TRUE)
file.copy(from = sheet_html_paths,
          to = stringr::str_replace(sheet_html_paths, "data-sheets", "www"),
          overwrite = T)
