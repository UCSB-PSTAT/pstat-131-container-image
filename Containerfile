FROM ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN R -e "install.packages(c('dplyr', 'ggplot2', 'glmnet', 'ROCR', 'ISLR', 'tree', 'maptree', 'dendextend'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"

USER $NB_USER

