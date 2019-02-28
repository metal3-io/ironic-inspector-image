FROM docker.io/centos:centos7

RUN yum install -y python-requests
RUN curl https://raw.githubusercontent.com/openstack/tripleo-repos/master/tripleo_repos/main.py | python - current
RUN yum install -y openstack-ironic-inspector crudini psmisc

RUN crudini --set /etc/ironic-inspector/inspector.conf DEFAULT auth_strategy noauth && \ 
    crudini --set /etc/ironic-inspector/inspector.conf ironic auth_strategy noauth && \
    crudini --set /etc/ironic-inspector/inspector.conf DEFAULT debug true && \
    crudini --set /etc/ironic-inspector/inspector.conf DEFAULT transport_url fake:// && \
    crudini --set /etc/ironic-inspector/inspector.conf processing store_data database && \
    crudini --set /etc/ironic-inspector/inspector.conf pxe_filter driver noop

RUN ironic-inspector-dbsync --config-file /etc/ironic-inspector/inspector.conf upgrade 

COPY ./runironic-inspector.sh /bin/runironic-inspector
COPY ./runhealthcheck.sh /bin/runhealthcheck

RUN chmod +x /bin/runironic-inspector

ENTRYPOINT ["/bin/runironic-inspector"]

