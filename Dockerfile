################################
###     APEREO CAS 6.1.2     ###
################################

FROM kimbrechts/docker-jdk-alpine:11.0.5

LABEL maintainer="imbrechts.kevin+cas@protonmail.com"

ENV LASTREFRESH="20191217" \
    PATH=$PATH:$JRE_HOME/bin \
    CAS_VERSION="6.1.x"

RUN apk update && \
    apk add --no-cache --virtual utils \
            git=2.22.2-r0 \
            bash=5.0.0-r0

# Download CAS overlay project
WORKDIR /
RUN git clone --depth 1 --single-branch -b ${CAS_VERSION} https://github.com/apereo/cas.git cas-overlay

# Download Maven-Wrapper
WORKDIR /tmp
RUN git clone --depth 1 --single-branch -b master https://github.com/takari/maven-wrapper.git maven-wrapper && \
    mkdir -p /cas-overlay/.mvn/wrapper && \
    mv /tmp/maven-wrapper/.mvn/wrapper/maven-wrapper.jar /cas-overlay/.mvn/wrapper/ && \
    mv /tmp/maven-wrapper/.mvn/wrapper/maven-wrapper.properties /cas-overlay/.mvn/wrapper/ && \
    mv /tmp/maven-wrapper/mvnw /cas-overlay/

COPY cas-overlay/build.sh /cas-overlay/
COPY cas-overlay/pom.xml /cas-overlay/
COPY etc/cas/ /etc/cas/

WORKDIR /
RUN chmod 750 cas-overlay/.mvn && \
    chmod 750 cas-overlay/*.sh && \
    chmod 750 /opt/java-home/bin/java

# Cleaning
RUN apk del git && \
    rm -rf /cas-overlay/.git* && \
    rm -rf /cas-overlay/ci && \
    rm -rf /cas-overlay/docs && \
    rm -rf /cas-overlay/gradle && \
    rm -f /cas-overlay/.mergify.yml && \
    rm -f /cas-overlay/.travis.yml && \
    rm -f /cas-overlay/LICENSE && \
    rm -f /cas-overlay/NOTICE && \
    rm -f /cas-overlay/README.md && \
    rm -f /cas-overlay/build.gradle && \
    rm -f /cas-overlay/gradle.properties && \
    rm -f /cas-overlay/gradlew* && \
    rm -f /cas-overlay/release.sh && \
    rm -f /cas-overlay/settings.gradle

EXPOSE 8080 8443

WORKDIR /cas-overlay

ENTRYPOINT ["build.sh"]
CMD ["run"]