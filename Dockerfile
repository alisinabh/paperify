FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive \
    FONT=roboto \
    OUTPUT_DIR=/target/ \
    INPUT_DIR=/target/


RUN apt-get update && apt-get install \
    --no-install-recommends -y \
    ca-certificates \
    imagemagick \
    fonts-roboto \
    libzbar-dev \
    qrencode \
    wget && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


RUN wget -q https://linuxtv.org/downloads/zbar/binaries/zbar-0.23.91-ubuntu-20.04.tar.gz

RUN tar -xvf zbar-0.23.91-ubuntu-20.04.tar.gz && \
    rm zbar-0.23.91-ubuntu-20.04.tar.gz && \
    dpkg -i libzbar0_0.23.91_amd64.deb libzbar-dev_0.23.91_amd64.deb python3-zbar_0.23.91_amd64.deb zbar-tools_0.23.91_amd64.deb

RUN mkdir /paperify
COPY . /paperify
WORKDIR /paperify

ENTRYPOINT ["/paperify/paperify.sh"]
