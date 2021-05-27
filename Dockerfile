FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
	build-essential \
	git-core \
	cmake \
	zlib1g-dev \
	libncurses-dev \
	doxygen \
	libcairo-dev \
	libfreetype6-dev \
	wget \
	samtools \
	libbam-dev

RUN git clone https://github.com/jbalberge/pairoscope.git \
	&&  cd pairoscope \
	&& mkdir build \
	&& cd build \
	&& cmake .. \
	&& make \
	&& make install

#RUN wget --no-check-certificate https://github.com/genome/pairoscope/archive/refs/tags/v0.4.2.tar.gz \
#	&& tar xvzf v0.4.2.tar.gz \
#	&& rm v0.4.2.tar.gz
#
#RUN samtools --version && which samtools
#
#RUN mkdir pairoscope-0.4.2/build \
##	&& cd pairoscope-0.4.2/build \
#	&& cmake ../ \
#	&& make -j