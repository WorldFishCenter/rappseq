FROM rocker/r-ver:4.0.5
LABEL maintainer="fernando@cagua.org"

# BEGIN rstudio/plumber layers
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  git-core \
  libssl-dev \
  libcurl4-gnutls-dev \
  curl \
  libsodium-dev \
  libxml2-dev

RUN install2.r --error --skipinstalled \
    plumber

COPY . /home
WORKDIR /home

ENTRYPOINT ["R", "-e", "--quiet", "pr <- plumber::plumb('plumber.R'); pr$run(host='0.0.0.0', port=as.numeric(Sys.getenv('PORT')))"]

# set default startup command to run the app's "plumber.R" file
CMD ["plumber.R"]