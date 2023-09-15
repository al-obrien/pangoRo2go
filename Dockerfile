# Use build time argument to create image with R version matching project
ARG R_VERSION=4.3.1
FROM rocker/r-ver:${R_VERSION}

# Must be after FROM or else not accessible
ARG RENV_VERSION=v1.0.0

# Update/Install system packages
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    git-core \
    libssl-dev \
    libcurl4-gnutls-dev \
    curl \
    libsodium-dev \
    libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install packages to get versions and start with {renv}    
RUN R -e "install.packages('remotes')"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

WORKDIR /pangoro2go
COPY renv/profiles/plumber/renv.lock renv.lock

# Lib path for {renv} to use for installations
ENV RENV_PATHS_LIBRARY renv/library

RUN R -e "renv::restore()"

COPY plumber.R plumber.R
EXPOSE 8000

# Change user to avoid root usage in container image (see https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user)
RUN groupadd -r nonroot \
    && useradd -r --no-log-init -s /sbin/nologin -g nonroot nonroot \ 
    && chown -R nonroot /pangoro2go  
USER nonroot

ENTRYPOINT ["R", "-e", "pr <- plumber::plumb('plumber.R'); pr$setDocs(TRUE); pr$run(port=8000, host='0.0.0.0')"]