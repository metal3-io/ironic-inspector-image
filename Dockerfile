FROM docker.io/centos:centos8

ENV PKGS_LIST=main-packages-list.txt
ARG EXTRA_PKGS_LIST
ARG PATCH_LIST

COPY ${PKGS_LIST} ${EXTRA_PKGS_LIST:-$PKGS_LIST} ${PATCH_LIST:-$PKGS_LIST} /tmp/
COPY prepare-image.sh patch-image.sh /bin/

RUN prepare-image.sh && \
  rm -f /bin/prepare-image.sh

RUN mkdir -p /var/lib/ironic-inspector && \
  sqlite3 /var/lib/ironic-inspector/ironic-inspector.db "pragma journal_mode=wal" && \
  dnf remove -y sqlite

COPY ironic-inspector.conf.j2 /etc/ironic-inspector/
COPY scripts/ /bin/

COPY ./inspector-apache.conf.j2 /etc/httpd/conf.d/ironic-inspector.conf.j2
HEALTHCHECK CMD /bin/runhealthcheck
RUN rm /etc/httpd/conf.d/ssl.conf -f

