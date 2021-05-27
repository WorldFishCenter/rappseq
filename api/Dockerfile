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
    DBI \
    digest \
    plumber \
    RSQLite 

COPY . /home
WORKDIR /home

ENTRYPOINT ["R", "--quiet", "-e", "source('api.R')"]

# set default startup command to run the app's "plumber.R" file
CMD ["api.R"]
