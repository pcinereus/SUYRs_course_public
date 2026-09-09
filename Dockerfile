FROM rocker/r-ver:4.5.0

# Install system dependencies
RUN apt-get update \
    && apt-get install -y \
    curl \
    gdebi-core \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    make \
    graphviz \
    fontconfig \
    build-essential \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgif-dev \
    libwebp-dev \
    libheif-dev \
    wget \
    ghostscript \
    ca-certificates \
    tree \
    pandoc \
    imagemagick \
    libmagick++-dev \
    git && \
    rm -rf /var/lib/apt/lists/*

## Must set this environment variable to avoid issues with the magick package when trying to use it in R.
ENV PATH="${PATH}:/root/bin"

## Update ImageMagick policy to allow PDF operations
RUN sed -i 's/^.*policy.*coder.*none.*PDF.*//' /etc/ImageMagick-6/policy.xml 2>/dev/null || true

# Install R packages
RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2024-01-10/\")); \
  install.packages(\"pak\"); \
"
RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2024-01-10/\")); \
  pak::pkg_install(c('rmarkdown', 'quarto', 'tidyverse', 'ggplot2', 'sf', 'dplyr')); \
  pak::pkg_install(c('stan-dev/cmdstanr')); \
"

# Install CmdStan
RUN R -e "cmdstanr::check_cmdstan_toolchain(fix = TRUE); \
  cmdstanr::install_cmdstan(cores = parallel::detectCores()); \
"

RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2024-01-10/\")); \
  pak::pkg_install(c('magick', 'pdftools', 'GGally', 'PBSmapping')); \
  pak::pkg_install(c('gmodels', 'mvtnorm', 'coda', 'gganimate', 'gridExtra')); \
  pak::pkg_install(c('ggfortify', 'DHARMa', 'glmmTMB', 'performance', 'see')); \
  pak::pkg_install(c('brms', 'knitr', 'simstudy', 'stars', 'gstat', 'patchwork')); \
  pak::pkg_install(c('remotes', 'inlabru', 'Hmisc', 'igraph', 'easystats')); \
  pak::pkg_install(c('gridGraphics', 'HDInterval', 'bayestestR', 'emmeans')); \
  pak::pkg_install(c('gert', 'usethis', 'mgcv', 'ggeffects', 'gratia', 'tree')); \
  pak::pkg_install(c('gbm', 'car', 'jmgirard/standist', 'tidybayes')); \
  pak::pkg_install(c('dagitty', 'ggdag')); \
  pak::pkg_install(c('plotrix', 'PBSmapping')); \

"

RUN R -e "install.packages('INLA',repos=c(getOption('repos'),INLA='https://inla.r-inla-download.org/R/stable'), dep=TRUE)"

RUN Rscript -e 'tinytex::install_tinytex()'
RUN Rscript -e 'tinytex::reinstall_tinytex(repository = "illinois")'
RUN Rscript -e 'tinytex::tlmgr_update(all = TRUE, self = TRUE)'
RUN Rscript -e 'tinytex::tlmgr_install("titlesec")'
RUN Rscript -e 'tinytex::tlmgr_install("forest")'
RUN Rscript -e 'tinytex::tlmgr_install("komo-script")'
RUN Rscript -e 'tinytex::tlmgr_install("caption")'
RUN Rscript -e 'tinytex::tlmgr_install("pgf")'
RUN Rscript -e 'tinytex::tlmgr_install("environ")'
RUN Rscript -e 'tinytex::tlmgr_install("tikzfill")'
RUN Rscript -e 'tinytex::tlmgr_install("tcolorbox")'
RUN Rscript -e 'tinytex::tlmgr_install("pdfcol")'
RUN Rscript -e 'tinytex::tlmgr_install("standalone")'
RUN Rscript -e 'tinytex::tlmgr_install("preview")'




# RUN tlmgr option repository https://mirror.ctan.org/systems/texlive/tlnet && \
#   tlmgr update --self && \
#   tlmgr update --all
# RUN tlmgr option repository http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/tlnet && \
#   tlmgr update --self && \
#   tlmgr update --all && \
#   tlmgr install \
#         titlesec \
#         forest \
#         koma-script \
#         caption \
#         pgf \
#         environ \
#         tikzfill \
#         tcolorbox \
#         pdfcol

ARG QUARTO_VERSION="1.6.40"
RUN curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb
RUN gdebi --non-interactive quarto-linux-amd64.deb

RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2021-02-10/\")); \
  pak::pkg_install(c('pander', 'mvabund')); \
"
# Install Docker
RUN apt-get update && apt-get install -y \
    docker.io \
    && rm -rf /var/lib/apt/lists/*


RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2024-04-11/\")); \
  pak::pkg_install(c('magick')); \
  pak::pkg_install(c('ggdag')); \

"



# Install common fonts from Ubuntu repositories
RUN apt-get update && apt-get install -y \
    fonts-liberation \
    fonts-dejavu \
    fonts-noto \
    && rm -rf /var/lib/apt/lists/*

# Install custom fonts
RUN mkdir -p /usr/share/fonts/custom

COPY resources/ArchitectsDaughter-Regular.ttf /usr/share/fonts/custom/ 2>/dev/null || true
COPY resources/xkcd.ttf /usr/share/fonts/custom/ 2>/dev/null || true
COPY resources/Hannahs_Messy_Handwriting.ttf /usr/share/fonts/custom/ 2>/dev/null || true
COPY resources/CabinSketch-Bold.ttf /usr/share/fonts/custom/ 2>/dev/null || true
COPY resources/Inconsolata*.ttf /usr/share/fonts/custom/ 2>/dev/null || true
COPY "resources/Complete in Him.ttf" /usr/share/fonts/custom/ 2>/dev/null || true
COPY resources/veteran_typewriter.ttf /usr/share/fonts/custom/ 2>/dev/null || true

# Rebuild font cache
RUN fc-cache -fv && fc-list

RUN git config --global user.name "pcinereus"
RUN git config --global user.email "i.obesulus@gmdail.com"
RUN git config --global init.defaultBranch main


# Set work directory
WORKDIR /workspace
#
COPY Makefile /workspace
COPY tut/*.qmd /workspace/tut
COPY resources/*.* /workspace/resources
