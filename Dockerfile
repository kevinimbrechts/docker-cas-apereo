#################################
###     APEREO CAS 5.3.10     ###
#################################

FROM kimbrechts/docker-jdk-alpine

LABEL maintainer="imbrechts.kevin+cas@protonmail.com"

ENV LASTREFRESH="20191118" \
    PATH=$PATH:$JRE_HOME/bin \
    CAS_VERSION="5.3"

RUN apk update && \
    apk add --no-cache --virtual utils \
            git=2.22.0-r0 \
            bash=5.0.0-r0

# Download CAS overlay project
WORKDIR /
RUN git clone --depth 1 --single-branch -b ${CAS_VERSION} https://github.com/apereo/cas-overlay-template.git cas-overlay

COPY /cas-overlay/pom.xml /cas-overlay/
COPY etc/cas/ /etc/cas/

RUN chmod 750 cas-overlay/maven && \
    chmod 750 cas-overlay/*.sh && \
    chmod 750 /opt/java-home/bin/java

# Cleaning
RUN apk del git && \
    rm -rf /cas-overlay/.git*

EXPOSE 8080 8443

WORKDIR /cas-overlay

ENTRYPOINT ["build.sh"]
CMD ["run"]
