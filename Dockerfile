FROM ashspencil/10.0-cudnn7.4.2.24-devel-ubuntu16.04:v1
MAINTAINER ashspencil <pencil302@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update&& apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y vim nano && \
    apt-get install -y openssh-server

### Python3.7
RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update -y && \
    apt-get install python3.7 -y && \
    cd /usr/bin/ ; rm python3 ; ln -s python3.7 python3

### Pip3 && pipenv
RUN apt-get install -y python3-pip && \
    pip3 install --upgrade pip

COPY pip3 /usr/bin/pip3

RUN pip3 install pipenv

### Build Env (Pytorch version)
ENV WORKON_HOME /envs
RUN mkdir /envs

WORKDIR /envs
RUN mkdir pytorch
COPY pytorch_version.txt pytorch/requirements.txt
WORKDIR pytorch
RUN pipenv install --python 3.7

### Build Env (Tensorflow_keras version)
WORKDIR /envs
RUN mkdir tf_keras
COPY tf_keras_version.txt tf_keras/requirements.txt
WORKDIR tf_keras
RUN pipenv install --python 3.7

WORKDIR /envs
RUN rm -rf .cache

### R for 3.4.4
RUN apt-get update -y && \
    apt-get install -y build-essential fort77 xorg-dev liblzma-dev  libblas-dev gfortran gcc-multilib gobjc++ aptitude && \
    aptitude install -y libreadline-dev && \
    aptitude install -y libcurl4-openssl-dev && \
    apt-get install -y texlive-latex-base libcairo2-dev  && \
    apt-get install -y apt-transport-https && \
    apt-get install -y software-properties-common && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 
                                            
WORKDIR /usr/lib/python3/dist-packages/

RUN cp apt_pkg.cpython-35m-x86_64-linux-gnu.so apt_pkg.so && \
    add-apt-repository "deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/" && \
    apt-get update -y && \
    apt-get -y install r-base=3.4.4-1xenial0

### oracle JAVA 8
COPY jdk-8u212-linux-x64.tar.gz /opt
WORKDIR /opt
RUN tar zxvf jdk-8u212-linux-x64.tar.gz
COPY profile /etc/profile
RUN rm jdk-8u212-linux-x64.tar.gz

### change permission for user

RUN chown -R root:imbduser /envs

WORKDIR /

RUN apt-get clean

ENTRYPOINT service ssh restart && bash
