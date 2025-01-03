FROM ucsb/rstudio-base:latest

LABEL maintainer="LSIT Systems <lsitops@ucsb.edu>"

USER root

RUN conda install -y r-cluster r-dplyr r-factoextra r-fnn r-ggplot2 r-glmnet r::r-hflights r-rocr  r-islr r-tree r-maptree r-dendextend

USER $NB_USER

