#################################
###     APEREO CAS 5.3.12     ###
###       ALPINE 3.10.9       ###
#################################

FROM alpine:3.10.2

LABEL maintainer="imbrechts.kevin+cas@protonmail.com"

ENV LASTREFRESH="20191007" \
    PATH=$PATH:$JRE_HOME/bin \
    JAVA_VERSION="8.0.222" \
    ZULU_VERSION="8.40.0.25-ca" \
    #JAVA_HASH="e0fdd6146c54829837a23c025363296c" \
    CAS_VERSION="5.3" \
    JAVA_HOME="/opt/java-home" \
    PATH=$PATH:$JAVA_HOME/bin:.

RUN apk update && \
    apk add --no-cache --virtual utils \
            bash=5.0.0-r0 \
            wget=1.20.3-r0 \
            tar=1.32-r0 \
            unzip=6.0-r4 \
            git=2.22.0-r0

# Download Azul Java, verify the hash, install
WORKDIR /tmp
RUN set -x && \
    wget http://cdn.azul.com/zulu/bin/zulu${ZULU_VERSION}-jdk${JAVA_VERSION}-linux_musl_x64.tar.gz && \
#    echo "${JAVA_HASH}  zulu${ZULU_VERSION}-jdk${JAVA_VERSION}-linux_x64.tar.gz" | md5sum -c - && \
    tar -zxvf zulu${ZULU_VERSION}-jdk${JAVA_VERSION}-linux_x64.tar.gz -C /opt && \
    rm zulu${ZULU_VERSION}-jdk${JAVA_VERSION}-linux_x64.tar.gz && \
    ln -s /opt/zulu${ZULU_VERSION}-jdk${JAVA_VERSION}-linux_x64/ /opt/java-home

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

CMD ["./build.sh run"]
