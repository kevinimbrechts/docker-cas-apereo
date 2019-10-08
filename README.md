# Docker image for Apereo CAS in Alpine Linux
## Configuration
### Using CAS behind a proxy
#### Config files
If you want to use CAS behind a proxy, you have to create your own Docker Image based on this one, and create a `/cas-overlay/.mvn/jvm.config` file to install Maven and create a `/root/.m2/settings.xml` file to install Maven's plugins.

I have put some examples in `samples` directory (`./cas-overlay/.mvn/jvm.config` and `/root/.m2/settings.xml`).

#### Dockerfile
Here is a sample of a Dockerfile including proxy config:
```Dockerfile
FROM kimbrechts/docker-cas-apereo

ARG http_proxy="http://your-user:changeit@your.proxy.net:9999"
ARG https_proxy="http://your-user:changeit@your.proxy.net:9999"
ARG no_proxy="localhost, 127.0.0.0/8, ::1, *.mydomain.com"

ENV http_proxy=${http_proxy} \
    HTTP_PROXY=${http_proxy} \
    https_proxy=${https_proxy} \
    HTTPS_PROXY=${https_proxy} \
    no_proxy=${no_proxy} \
    NO_PROXY=${no_proxy} \
...
```

### Running CAS with JAAS
If you want to run CAS with JAAS, you have to create your own `/cas-overlay/run-cas.sh` script with `-Djava.security.auth.login.config` option.
Example:
```bash
#!/bin/bash
export JAVA_HOME=/opt/jre-home
export PATH=$PATH:$JAVA_HOME/bin:.
# echo "Use of this image/container constitutes acceptence of the Oracle Binary Code License Agreement for Java SE."
#exec java -jar /cas-overlay/target/cas.war
exec java -Djava.security.auth.login.config=/etc/cas/config/jaas.config -jar /cas-overlay/target/cas.war
```

You need to create a `/etc/cas/config/jaas.config` file with some configuration.

### pom.xml
This image includes some Maven plugins (for basic auth, REST...). If you want to add or remove some plugins, you have put your own `pom.xml` in your own image (or with a `docker-compose`, for example).

### Change the timezone
In your own `Dockerfile`, you can change the timezone like this:
```Dockerfile
RUN apk add --no-cache --virtual tz tzdata && \
    ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime && \
    echo "Europe/Paris" > /etc/timezone && \
    apk del tzdata
```

## Using services
Services are to be placed in `/etc/cas/services/` directory/. You can create a Docker volume or use you own `Dockerfile`.
I created `yaml` examples in `samples/etc/cas/services` directory:
* `CASAdminDashboard-10000003.yml`: Authorize Admin Dashboard
* `HTTP-10000004.yml`: Authorize all HTTP(s) applications

## Install Kerberos
If you have to use Kerberos, you need to create your own `Dockerfile` and install Kerberos, add your `krb5.conf` file and add your keytab file like this:
```Dockerfile
FROM kimbrechts/docker-cas-apereo
...
RUN apk update && \
    apk add --no-cache --virtual krb \
            krb5=1.17-r0 \
            krb5-libs=1.17-r0 \
            apache-mod-auth-kerb=5.4-r5 \
            openssl=1.1.1d-r0

COPY etc/krb5.conf /etc/
COPY cas.HTTP.keytab /etc/cas/cas.HTTP.keytab
```
