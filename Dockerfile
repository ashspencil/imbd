FROM ashspencil/10.0-cudnn7.4.2.24-devel-ubuntu16.04:v1
MAINTAINER ashspencil <pencil302@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update&& apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y net-tools && \
    apt-get install -y iputils-ping && \
    apt-get install -y vim nano && \
    apt-get install -y openssh-server && \
    apt-get clean
### Python3.7
RUN apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update -y && \
    apt-get install python3.7 -y && \
    apt-get clean && \
    cd /usr/bin/ ; rm python3 ; ln -s python3.7 python3

### Pip3 && pipenv
RUN apt-get install -y python3-pip && \
    pip3 install --upgrade pip && \
    rm -rf ~/.cache

COPY pip3 /usr/bin/pip3

RUN pip3 install pipenv

### Build Env (Pytorch version)
ENV WORKON_HOME /envs
RUN mkdir /envs

WORKDIR /envs
RUN mkdir pytorch
COPY pytorch_version.txt pytorch/requirements.txt
WORKDIR pytorch
RUN pipenv install --python 3.7 && \
    rm -rf ~/.cache

### Build Env (Tensorflow_keras version)
WORKDIR /envs
RUN mkdir tf_keras
COPY tf_keras_version.txt tf_keras/requirements.txt
WORKDIR tf_keras
RUN pipenv install --python 3.7 && \
    rm -rf ~/.cache

WORKDIR /envs

### R for 3.4.4
RUN apt-get update -y && \
    apt-get install -y build-essential fort77 xorg-dev liblzma-dev  libblas-dev gfortran gcc-multilib gobjc++ aptitude && \
    aptitude install -y libreadline-dev && \
    aptitude install -y libcurl4-openssl-dev && \
    apt-get install -y texlive-latex-base libcairo2-dev  && \
    apt-get install -y apt-transport-https && \
    apt-get install -y software-properties-common && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    apt-get clean
                                            
WORKDIR /usr/lib/python3/dist-packages/

RUN cp apt_pkg.cpython-35m-x86_64-linux-gnu.so apt_pkg.so && \
    add-apt-repository "deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/" && \
    apt-get update -y && \
    apt-get -y install r-base=3.4.4-1xenial0 && \
    apt-get clean

### oracle JAVA 8
COPY jdk-8u212-linux-x64.tar.gz /opt
WORKDIR /opt
RUN tar zxvf jdk-8u212-linux-x64.tar.gz
RUN rm jdk-8u212-linux-x64.tar.gz

ENV JAVA_HOME /opt/jdk1.8.0_212
ENV JRE_HOME=${JAVA_HOME}/jre
ENV CLASSPATH=.:${JAVA_HOME}/lib:${JRE_HOME}/lib
ENV PATH=${JAVA_HOME}/bin:$PATH
COPY profile /etc/profile

### R packages
RUN R CMD javareconf
RUN apt-get install ocl-icd-opencl-dev libxml2-dev libgmp3-dev opencl-headers libssl-dev -y
RUN ln -s /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 /usr/lib/libOpenCL.so
RUN Rscript -e "install.packages(c('xgboost', 'readxl', 'xlsx', 'tidyverse', 'klaR', 'ClusterR', 'pracma', 'fields', 'filehashSQLite', 'filehash', 'LatticeKrig', 'spam', 'RSpectra', 'filematrix', 'autoFRK', 'Metrics', 'adabag', 'neuralnet', 'caTools', 'nnet', 'caret', 'ada', 'randomForest', 'inTrees', 'UBL', 'cvTools', 'gdata', 'moments', 'zoo', 'parcor', 'MASS', 'chemometrics', 'rpart', 'e1071'))"

### change permission and create group for user

RUN groupadd imbduser && \
    chown -R root:imbduser /envs && \
    chmod -R 775 /envs

WORKDIR /envs

ENTRYPOINT service ssh restart && bash
