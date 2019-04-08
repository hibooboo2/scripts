FROM ubuntu:latest
MAINTAINER James Jeffrey wizardofmath@gmail.com
LABEL devbox="wizardofmath"
ENV MYSCRIPTS /source/scripts
env HOME /source
VOLUME /source
WORKDIR /source
ADD . /source/scripts
RUN /source/scripts/scripts/bootstrap
ENTRYPOINT /bin/bash
