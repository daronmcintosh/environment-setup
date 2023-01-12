# syntax=docker/dockerfile:1

FROM ubuntu:latest

RUN apt update && apt install -y \
    curl \
    gpg \
    wget \
    git \
    sudo \
    nano

COPY linux-setup.sh ./
RUN chmod +x linux-setup.sh
ARG CACHE_DATE=2023-01-01
RUN ./linux-setup.sh

ENTRYPOINT [ "/bin/zsh" ]
