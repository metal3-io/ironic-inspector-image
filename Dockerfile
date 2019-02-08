FROM docker.io/centos:centos7

RUN yum install -y python-requests
RUN curl https://raw.githubusercontent.com/openstack/tripleo-repos/master/tripleo_repos/main.py | python - current-tripleo
RUN yum install -y openstack-ironic-inspector crudini 

RUN crudini --set /etc/ironic-inspector/inspector.conf DEFAULT auth_strategy noauth && \ 
    crudini --set /etc/ironic-inspector/inspector.conf ironic auth_strategy noauth && \
    crudini --set /etc/ironic-inspector/inspector.conf DEFAULT debug true && \
    crudini --set /etc/ironic-inspector/inspector.conf pxe_filter driver noop

RUN ironic-inspector-dbsync --config-file /etc/ironic-inspector/inspector.conf upgrade 

COPY ./runironic-inspector.sh /bin/runironic-inspector
RUN chmod +x /bin/runironic-inspector

ENTRYPOINT ["/bin/runironic-inspector"]
