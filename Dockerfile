FROM rocker/verse:4.0.5

# Extra R packages
RUN install2.r bslib

# Rstudio interface preferences
COPY rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json
