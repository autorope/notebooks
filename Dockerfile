#FROM python:3.6
FROM nvidia/cuda:9.0-base-ubuntu16.04

SHELL ["/bin/bash", "--login", "-c"]

RUN apt-get update && apt-get install -y \
  vim locales cmake make gcc libgl1-mesa-glx \
  wget bzip2 curl git python-pip && rm -rf /var/lib/apt/lists/*

RUN apt-get update
RUN apt install -y libsm6 libxext6
RUN apt-get install -y libxrender-dev

# Install miniconda3
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh

# Set default base directory for subsequent steps
WORKDIR /opt


# Install python dependencies before handling application files.
# COPY of a directory appears to disrupt layer cacheing.
COPY conda.env conda.env

# source conda scripts by default
RUN echo '. /opt/conda/etc/profile.d/conda.sh' >> ~/.bashrc
# Install conda packages
RUN conda env create -f conda.env && rm -rf /opt/conda/pkgs/*
# Activate works by default
RUN echo "conda activate donkey" >> ~/.bashrc

COPY requirements.txt /opt/requirements.txt
RUN conda activate donkey && pip install -r /opt/requirements.txt

RUN conda activate donkey && jupyter notebook --generate-config
RUN echo "c.NotebookApp.password = ''">>/root/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''">>/root/.jupyter/jupyter_notebook_config.py



#start the jupyter notebook
CMD conda activate donkey && jupyter notebook --no-browser --ip 0.0.0.0 --port 8888 --allow-root  --notebook-dir=/notebooks/


#for donkeycar
EXPOSE 8887

#for jupyter notebook
EXPOSE 8888