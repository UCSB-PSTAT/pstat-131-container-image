FROM ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN mamba install -y r-dplyr r-ggplot2 r-glmnet r-rocr r-islr r-tree r-maptree r-dendextend

USER $NB_USER

