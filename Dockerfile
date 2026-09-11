FROM rocker/r-ver:4.5.0

# Install system dependencies and R development tools
RUN apt-get update \
    && apt-get install -y \
    build-essential \
    curl \
    gdebi-core \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    make \
    graphviz \
    fontconfig \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libgif-dev \
    libwebp-dev \
    libheif-dev \
    libuv1-dev \
    wget \
    ghostscript \
    ca-certificates \
    tree \
    pandoc \
    imagemagick \
    libmagick++-dev \
    git \
    r-base-dev \
    r-cran-rcpp && \
    rm -rf /var/lib/apt/lists/*

## Must set this environment variable to avoid issues with the magick package when trying to use it in R.
ENV PATH="${PATH}:/root/bin"

## Update ImageMagick policy to allow PDF operations
RUN sed -i 's/^.*policy.*coder.*none.*PDF.*//' /etc/ImageMagick-6/policy.xml 2>/dev/null || true

# Install R packages (pinned to September 2026 snapshot for reproducibility)
RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
  install.packages(\"pak\"); \
"
RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
  pak::pkg_install(c('rmarkdown', 'quarto', 'tidyverse', 'ggplot2', 'sf', 'dplyr')); \
  pak::pkg_install(c('stan-dev/cmdstanr')); \
"

# Install CmdStan
RUN R -e "cmdstanr::check_cmdstan_toolchain(fix = TRUE); \
  cmdstanr::install_cmdstan(cores = parallel::detectCores()); \
"

RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
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
  pak::pkg_install(c('bayesplot', 'ggmcmc', 'rstan', 'posterior')); \
  pak::pkg_install(c('broom', 'broom.mixed', 'modelsummary', 'marginaleffects')); \
  pak::pkg_install(c('tinytable', 'vegan', 'ggvegan', 'pdp', 'randomForest')); \
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
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
  pak::pkg_install(c('pander', 'mvabund')); \
"
# Install Docker
RUN apt-get update && apt-get install -y \
    docker.io \
    && rm -rf /var/lib/apt/lists/*


RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
  pak::pkg_install(c('magick')); \
  pak::pkg_install(c('ggdag')); \
  pak::pkg_install(c('rstanarm')); \
  pak::pkg_install(c('timcdlucas/INLAutils')); \
  pak::pkg_install(c('collapse')); \
"

RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
  pak::pkg_install(c('julianfaraway/brinla')); \
"

RUN R -e "options(repos = \
    list(CRAN = \"https://packagemanager.posit.co/cran/2026-09-01\")); \
  options(Ncpus = 4); \
  pak::pkg_install(c('geoR', 'reshape')); \
"

# Install common fonts from Ubuntu repositories
RUN apt-get update && apt-get install -y \
    fonts-liberation \
    fonts-dejavu \
    fonts-noto \
    && rm -rf /var/lib/apt/lists/*

RUN git config --global user.name "pcinereus"
RUN git config --global user.email "i.obesulus@gmdail.com"
RUN git config --global init.defaultBranch main


# Set work directory
WORKDIR /workspace
#
COPY Makefile /workspace
# COPY tut/*.qmd /workspace/tut
COPY resources/*.* /workspace/resources

# Install custom fonts (after resources are copied)
RUN mkdir -p /usr/share/fonts/custom && \
    find /workspace/resources -maxdepth 1 \( -name "ArchitectsDaughter-Regular.ttf" -o -name "xkcd.ttf" -o -name "Hannahs_Messy_Handwriting.ttf" -o -name "CabinSketch-Bold.ttf" -o -name "Inconsolata*.ttf" -o -name "Complete in Him.ttf" -o -name "veteran_typewriter.ttf" \) -type f -exec cp {} /usr/share/fonts/custom/ \; 2>/dev/null || true

# Rebuild font cache
RUN fc-cache -fv && fc-list

# Make fonts available to LaTeX/TinyTeX
RUN Rscript -e 'tinytex_home <- tinytex::tinytex_root(); \
  #fonts_dir <- file.path(tinytex_home, "texmf-local", "fonts", "truetype", "custom"); \
  fonts_dir <- file.path(tinytex_home, "texmf-local", "fonts", "opentype", "public", "custom"); \
  dir.create(fonts_dir, recursive = TRUE, showWarnings = FALSE); \

  # Copy all TTF/OTF fonts to TinyTeX directory \
  ## font_files <- list.files("/usr/share/fonts/custom", pattern = "\\.ttf$", full.names = TRUE); \
  font_files <- list.files("/usr/share/fonts/custom", pattern = "\\.(ttf|otf)$", full.names = TRUE); \
  file.copy(font_files, fonts_dir, overwrite = TRUE); \

  # Rebuild LaTeX font database \
  system(paste(file.path(tinytex_home, "bin", "x86_64-linux"), "mktexlsr"), ignore.stdout = TRUE); \
  if (file.exists(mktexlsr_path)) {
    system(paste(mktexlsr_path))
  }; \
  system(paste(file.path(tinytex_home, "bin", "x86_64-linux"), "updmap-sys", "--enable Map=xkcd.map"), ignore.stdout = FALSE); \
  if (file.exists(updmap_path)) { \
    system(paste(updmap_path), ignore.stdout = TRUE) \
  }; \
' || true

# Also ensure system can find fonts via XDG
ENV XDG_DATA_DIRS="/usr/share/fonts:/usr/local/share:/usr/share"

# Also rebuild XeTeX font cache explicitly
RUN Rscript -e 'tinytex_home <- tinytex::tinytex_root(); \
  luaotfload_path <- file.path(tinytex_home, "bin", "x86_64-linux", "luaotfload-tool"); \
  if (file.exists(luaotfload_path)) { \
    system(paste(luaotfload_path, "--update --force")) \
  }; \
' || true
