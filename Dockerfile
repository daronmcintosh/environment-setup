# syntax=docker/dockerfile:1

FROM --platform=linux/amd64 ubuntu:latest

RUN apt update && apt install -y \
    curl \
    gpg \
    wget \
    git \
    sudo \
    nano

COPY . .
RUN chmod +x linux-setup.sh
ARG CACHE_DATE=2024-03-13
RUN ./linux-setup.sh

ENTRYPOINT [ "/bin/zsh" ]
