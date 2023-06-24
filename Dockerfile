FROM debian:stable-slim

LABEL org.opencontainers.image.source=https://github.com/spiceywasabi/weewx-container
LABEL org.opencontainers.image.title=WeeWxContainer
LABEL org.opencontainers.image.url=https://github.com/spiceywasabi/weewx-container
LABEL org.opencontainers.image.authors="wasabi@dc562.org"
LABEL org.opencontainers.image.vendor="wasabi"
LABEL version="4.10.2"

RUN apt-get update \
 && apt-get install -y libusb-1.0-0 tzdata mariadb-client python3-mysqldb sqlite3 \
 && apt-get -y --no-install-recommends install gosu python3-pip bash wget rsync gnupg sudo zip unzip sudo busybox-syslogd \
 && pip3 install pyephem paho-mqtt configobj requests

COPY ./wee*.txt /
COPY ./scripts/*.sh /

#RUN mkdir -p /var/www && mkdir -p /var/lib/weewx/ && ln -s /www /var/www/html && ln -s /data /var/lib/weewx
RUN chmod +x /*.sh && ./setup.sh && mkdir /data && mkdir /www && rm /setup.sh

VOLUME ["/data", "/www"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["--run"]
