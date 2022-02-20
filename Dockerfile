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
# actual build operations
FROM version-base-${has_gpu} AS final

# MAINTAINER will be deprecated, so let's use LABEL
LABEL authors="Lea Laux <lea.laux@st.oth-regensburg.de>, Martin Meilinger <martin.meilinger@st.oth-regensburg.de>"

# add user
RUN useradd -m -G sudo -s /bin/bash repro && echo "repro:repro" | chpasswd
RUN usermod -a -G staff repro
WORKDIR /home/repro

# copy the files
COPY --chown=repro:repro . /home/repro/ReproducibilityPackage

# install git for cloning quantum-rl, as well as Python and LaTeX packages
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y \
        build-essential \
        git \
        python3.7 \
        texlive \
        texlive-bibtex-extra \
        texlive-latex-base \
        texlive-latex-extra \
        texlive-latex-recommended \
        texlive-luatex \
        texlive-pictures \
        texlive-publishers 

# clone the repository of Franz et al.
RUN git clone https://github.com/lfd/quantum-rl.git

RUN chown -R repro ./quantum-rl/

# install required packages
RUN python3 -m pip install --upgrade pip
RUN pip3 install -r quantum-rl/requirements.txt

RUN python3.7 -m pip install --upgrade pip
RUN python3.7 -m pip install -r ReproducibilityPackage/plot_requirements.txt

WORKDIR /home/repro/ReproducibilityPackage
USER repro

# default to run all trainings and then generate everything
ENTRYPOINT ["./run.sh"]
CMD ["true"]
