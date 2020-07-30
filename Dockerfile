FROM docker.io/centos:centos8

RUN dnf install -y python3 python3-requests && \
    curl https://raw.githubusercontent.com/openstack/tripleo-repos/master/tripleo_repos/main.py | python3 - -b master current-tripleo && \
    dnf update -y && \
    dnf install -y openstack-ironic-inspector crudini psmisc iproute sqlite && \
    mkdir -p /var/lib/ironic-inspector && \
    sqlite3 /var/lib/ironic-inspector/ironic-inspector.db "pragma journal_mode=wal" && \
    dnf remove -y sqlite && \
    dnf clean all && \
    rm -rf /var/cache/{yum,dnf}/*

COPY ./inspector.conf /tmp/inspector.conf
RUN crudini --merge /etc/ironic-inspector/inspector.conf < /tmp/inspector.conf && \
    rm /tmp/inspector.conf

RUN ironic-inspector-dbsync --config-file /etc/ironic-inspector/inspector.conf upgrade 

COPY ./runironic-inspector.sh /bin/runironic-inspector
COPY ./runhealthcheck.sh /bin/runhealthcheck
COPY ./ironic-common.sh /bin/ironic-common.sh

HEALTHCHECK CMD /bin/runhealthcheck
RUN chmod +x /bin/runironic-inspector

ENTRYPOINT ["/bin/runironic-inspector"]

