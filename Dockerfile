# Copyright 2022, Lea Laux <lea.laux@st.oth-regensburg.de>
# Copyright 2022, Martin Meilinger <martin.meilinger@st.oth-regensburg.de>
# based and extended upon the Dockerfiles of Franz et al.
#   (see the references section of the report)
# SPDX-License-Identifier: GPL-2.0

ARG has_gpu=with-gpu
# default with gpu


# --------------------------------------------------------------------------------
# base image with gpu
FROM nvcr.io/nvidia/tensorflow:21.05-tf2-py3 AS version-base-with-gpu



# --------------------------------------------------------------------------------
# base image without gpu, therefore cpu only
FROM tensorflow/tensorflow:2.4.1 AS version-base-without-gpu



# --------------------------------------------------------------------------------
# operations needed regardless of gpu presence
FROM version-base-${has_gpu} AS base

# MAINTAINER will be deprecated, so let's use LABEL
LABEL authors="Lea Laux <lea.laux@st.oth-regensburg.de>, Martin Meilinger <martin.meilinger@st.oth-regensburg.de>"

# add user
RUN useradd -m -G sudo -s /bin/bash repro && echo "repro:repro" | chpasswd
RUN usermod -a -G staff repro
WORKDIR /home/repro

# copy the files into the image/container
COPY --chown=repro:repro . /home/repro/ReproducibilityPackage

# clone the repository of Franz et al.
RUN git clone https://github.com/lfd/quantum-rl.git

# install required packages
RUN python -m pip install --upgrade pip
RUN pip3 install -r quantum-rl/requirements.txt

# install R and R-packages for plotting, as well as LaTeX packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        r-base \
        texlive \
        texlive-bibtex-extra \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-luatex \
        texlive-pictures \
        texlive-publishers \
        libcurl4-gnutls-dev \
        libssl-dev \
        libxml2-dev
RUN R -e "install.packages('ggplot2')"
RUN R -e "install.packages('tikzDevice')"
RUN R -e "install.packages('devtools')"



# --------------------------------------------------------------------------------
# one more operation for gpu-based image
FROM base AS final-with-gpu

RUN R -e "devtools::install_github('teunbrand/ggh4x')"



# --------------------------------------------------------------------------------
# one more operation for cpu-based image
FROM base AS final-without-gpu

RUN R -e "devtools::install_version('ggh4x', '0.1.2.1')"



# --------------------------------------------------------------------------------
# final image
FROM final-${has_gpu} AS final

WORKDIR /home/repro/ReproducibilityPackage
USER repro

# default to run all trainings and then generate everything
CMD ["./run_all_generate_all"]

