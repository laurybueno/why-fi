FROM jupyter/scipy-notebook:82d1d0bf0867

USER root

# Install OS level dependencies
RUN apt update &&\
    apt install -y p0f nmap

# Install python dependencies
COPY requirements /requirements
RUN pip install -r /requirements/base.txt
