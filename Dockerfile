FROM rocker/verse:4.0.5

# Extra R packages
RUN install2.r --error --skipinstalled \
    bslib \
    golem \
    insect \
    RSQLite \
    DT \
    waiter

# Rstudio interface preferences
COPY rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
