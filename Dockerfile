FROM ubuntu

MAINTAINER Marco Crotti

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y \
    apt-utils \
    bzip2 \
    gcc \
    make \
    ncurses-dev \
    wget \
    zlib1g-dev \
    unzip

RUN apt-get update
RUN apt install -y software-properties-common
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt install -y build-essential
RUN apt install -y default-jre



####################
# TRIMMOMATIC 0.38 #
####################

ENV TRIM_INSTALL_DIR=/opt/trimmomatic

WORKDIR /tmp

RUN wget http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip && \
    unzip Trimmomatic-0.38.zip && \
    cp Trimmomatic-0.38/trimmomatic-0.38.jar /usr/bin/

WORKDIR /  

################
# STACKS  2.59 #
################

ENV STACKS_INSTALL_DIR=/opt/stacks

WORKDIR /tmp

RUN wget http://catchenlab.life.illinois.edu/stacks/source/stacks-2.59.tar.gz && \
    tar -xf stacks-2.59.tar.gz

WORKDIR /tmp/stacks-2.59
RUN ./configure --prefix=$STACKS_INSTALL_DIR && \
    make && \
    make install && \
    cp /opt/stacks/bin/* /usr/bin

WORKDIR /
RUN rm -rf /tmp/stacks-2.59

#######
# BWA #
#######

RUN apt-get --yes install bwa


##############
#HTSlib 1.3.2#
##############
ENV HTSLIB_INSTALL_DIR=/opt/htslib

WORKDIR /tmp
RUN wget https://github.com/samtools/htslib/releases/download/1.3.2/htslib-1.3.2.tar.bz2 && \
    tar --bzip2 -xvf htslib-1.3.2.tar.bz2

WORKDIR /tmp/htslib-1.3.2
RUN ./configure  --enable-plugins --prefix=$HTSLIB_INSTALL_DIR && \
    make && \
    make install && \
    cp $HTSLIB_INSTALL_DIR/lib/libhts.so* /usr/lib/

################
#Samtools 1.3.1#
################
ENV SAMTOOLS_INSTALL_DIR=/opt/samtools

WORKDIR /tmp
RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    tar --bzip2 -xf samtools-1.3.1.tar.bz2

WORKDIR /tmp/samtools-1.3.1
RUN ./configure --with-htslib=$HTSLIB_INSTALL_DIR --prefix=$SAMTOOLS_INSTALL_DIR && \
    make && \
    make install && \
    cp samtools /usr/bin

WORKDIR /
RUN rm -rf /tmp/samtools-1.3.1

