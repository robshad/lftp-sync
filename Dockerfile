FROM linuxserver/baseimage
MAINTAINER Rob Shad <robertmshad@googlemail.com>
ENV APTLIST="lftp wget"

RUN apt-get update -q && \
  apt-get install $APTLIST -qy && \
  apt-get clean && rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

RUN mkdir -p /script && \
  mkdir -p /config/lftp-output && \
  chown -R abc:abc /config && \
  chown -R abc:abc /script && \
  touch /script/lftp-sync-service.sh

RUN wget -v -O /config/lftp-sync.sh https://raw.githubusercontent.com/robshad/lftp-sync/master/lftp-sync.sh
RUN wget -v -O /config/lftp-sync-defaults.cfg https://raw.githubusercontent.com/robshad/lftp-sync/master/lftp-sync-defaults.cfg

ADD init/ /etc/my_init.d/
RUN chmod -v +x /etc/service/*/run && \
  chmod -v +x /etc/my_init.d/*.sh && \
  chmod -v +x /config/lftp-sync.sh && \
  chmod -v +x /script/lftp-sync-service.sh
  
# Volumes and Ports
VOLUME ["/target"]