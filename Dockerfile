FROM docker.io/centos:centos8

RUN dnf install -y gcc python3-devel python3 python3-requests git && \
    curl https://raw.githubusercontent.com/openstack/tripleo-repos/master/tripleo_repos/main.py | python3 - -b master current && \
    dnf update -y && \
    dnf install -y crudini psmisc iproute sqlite && \
    mkdir -p /var/lib/ironic-inspector && \
    sqlite3 /var/lib/ironic-inspector/ironic-inspector.db "pragma journal_mode=wal" && \
    dnf remove -y sqlite && \
    dnf clean all && \
    rm -rf /var/cache/{yum,dnf}/*

RUN pip3 install git+https://opendev.org/openstack/ironic-inspector.git@master

COPY ./inspector.conf /tmp/inspector.conf
RUN mkdir /etc/ironic-inspector/
RUN touch /etc/ironic-inspector/inspector.conf

COPY ./inspector-dist.conf /etc/ironic-inspector/inspector-dist.conf

RUN crudini --merge /etc/ironic-inspector/inspector.conf < /tmp/inspector.conf && \
    rm /tmp/inspector.conf

RUN ironic-inspector-dbsync --config-file /etc/ironic-inspector/inspector.conf upgrade 

COPY ./runironic-inspector.sh /bin/runironic-inspector
COPY ./runhealthcheck.sh /bin/runhealthcheck
COPY ./ironic-common.sh /bin/ironic-common.sh

# HEALTHCHECK CMD /bin/runhealthcheck
RUN chmod +x /bin/runironic-inspector
RUN ln -s /usr/local/bin/ironic-inspector /bin/ironic-inspector
ENTRYPOINT ["/bin/runironic-inspector"]

