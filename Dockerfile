FROM ubuntu:14.04.2
MAINTAINER James Harris wizardofmath@gmail.com
LABEL devbox="wizardofmath"
ENV user=wizardofmath
VOLUME /source
WORKDIR /source
ADD . /source/scripts
RUN /source/scripts/scripts/bootstrap
ENTRYPOINT /bin/bash
