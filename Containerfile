FROM registry.cloud.college.ucsb.edu/ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN conda install -y \
 r-cluster \
 r-dendextend \
 r-dplyr \
 r-factoextra \
 r-fnn \
 r-ggplot2 \
 r-glmnet \
 r-islr \
 r-maptree \
 r-rocr  \
 r-tree 

# Install from CRAN to avoid R Downgrades
RUN R -e "install.packages(c( 'hflights'), repos = 'https://cloud.r-project.org/', Ncpus = parallel::detectCores())"


USER $NB_USER

