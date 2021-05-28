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
	libbam-dev \
	python3-pip

RUN git clone https://github.com/jbalberge/pairoscope.git \
	&&  cd pairoscope \
	&& mkdir build \
	&& cd build \
	&& cmake .. \
	&& make \
	&& make install

RUN pip3 install pandas

COPY phoenix_pairoscope_code.py /code/phoenix_pairoscope_code.py
COPY pairoscope.sh /code/pairoscope.sh

RUN /bin/bash -c 'chmod +x /code/pairoscope.sh'