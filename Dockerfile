FROM docker.io/centos:centos8

RUN dnf install -y python3 python3-requests && \
    curl https://raw.githubusercontent.com/openstack/tripleo-repos/master/tripleo_repos/main.py | python3 - -b master current-tripleo && \
    dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
    dnf update -y && \
    dnf install -y openstack-ironic-inspector openstack-ironic-inspector-api openstack-ironic-inspector-conductor crudini psmisc iproute \
    sqlite httpd mod_ssl python3-mod_wsgi python3-pymemcache inotify-tools && \
    mkdir -p /var/lib/ironic-inspector && \
    sqlite3 /var/lib/ironic-inspector/ironic-inspector.db "pragma journal_mode=wal" && \
    dnf remove -y sqlite && \
    dnf clean all && \
    rm -rf /var/cache/{yum,dnf}/* && \
    rm /etc/httpd/conf.d/ssl.conf

COPY ./inspector.conf /tmp/inspector.conf
RUN crudini --merge /etc/ironic-inspector/ironic-inspector.conf < /tmp/inspector.conf && \
    rm /tmp/inspector.conf && chown -R ironic-inspector:ironic-inspector /var/log/ironic-inspector && \
    chown -R ironic-inspector:ironic-inspector /etc/ironic-inspector/ironic-inspector.conf

RUN ironic-inspector-dbsync --config-file /etc/ironic-inspector/ironic-inspector.conf upgrade

COPY ./runironic-inspector.sh /bin/runironic-inspector
COPY ./runhealthcheck.sh /bin/runhealthcheck
COPY ./ironic-common.sh /bin/ironic-common.sh

COPY ./apache.conf.j2 /etc/apache.conf.j2

HEALTHCHECK CMD /bin/runhealthcheck
RUN chmod +x /bin/runironic-inspector

ENTRYPOINT ["/bin/runironic-inspector"]

