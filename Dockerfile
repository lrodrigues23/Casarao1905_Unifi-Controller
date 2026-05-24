# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-ubuntu:focal

# set version label
ARG BUILD_DATE
ARG VERSION
ARG UNIFI_VERSION="8.0.24"
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

# environment settings
ARG UNIFI_BRANCH="stable"
ARG DEBIAN_FRONTEND="noninteractive"

COPY *.deb /tmp/unifi.deb

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    binutils \
    jsvc \
    libcap2 \
    logrotate \
    mongodb-server \
    openjdk-17-jre-headless && \
  echo "**** install local unifi package ****" && \
  mkdir -p /app && \
  apt-get install -y /tmp/unifi.deb && \
  rm -f /tmp/unifi.deb && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /
RUN \
  chmod +x \
    /etc/cont-init.d/99-deprecation \
    /etc/s6-overlay/s6-rc.d/init-unifi-controller-config/run \
    /etc/s6-overlay/s6-rc.d/init-unifi-controller-config/up \
    /etc/s6-overlay/s6-rc.d/svc-unifi-controller/run \
    /etc/s6-overlay/s6-rc.d/svc-unifi-controller/data/check

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880
