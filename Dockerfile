FROM python:3.9.6-slim
# buster is 910 MB , slim is 150 MB
LABEL org.opencontainers.image.authors="wasabi@dc562.org"
LABEL org.opencontainers.image.vendor="wasabi"
LABEL com.weewx.version=${WEEWX_VERSION}

ENV WEEWX_VERSION="4.4.0"

RUN apt-get update && apt-get install -y libusb-1.0-0 gosu busybox-syslogd tzdata unzip \
 zip sudo mariadb-client python3-mysqldb sqlite3 sqlite python3-pip bash wget

RUN pip install pyephem paho-mqtt

COPY ./wee*.txt /
COPY setup.sh /setup.sh
COPY entrypoint.sh /entrypoint.sh

RUN ./setup.sh && mkdir /data

VOLUME ["/data"]

ENTRYPOINT ["./entrypoint.sh"]
CMD ["--run"]
