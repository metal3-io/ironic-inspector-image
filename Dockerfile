FROM docker.io/centos:centos7

RUN yum install -y python-requests && \
    curl https://raw.githubusercontent.com/openstack/tripleo-repos/master/tripleo_repos/main.py | python - current-tripleo && \
    yum update -y && \
    yum install -y openstack-ironic-inspector crudini psmisc iproute iptables && \
    yum clean all

RUN mkdir -p /var/lib/ironic-inspector && \
    sqlite3 /var/lib/ironic-inspector/ironic-inspector.db "pragma journal_mode=wal"

RUN crudini --set /etc/ironic-inspector/inspector.conf DEFAULT auth_strategy noauth && \ 
    crudini --set /etc/ironic-inspector/inspector.conf ironic auth_type none && \
    crudini --set /etc/ironic-inspector/inspector.conf service_catalog auth_type none && \
    crudini --set /etc/ironic-inspector/inspector.conf DEFAULT debug true && \
    crudini --set /etc/ironic-inspector/inspector.conf database connection sqlite:///var/lib/ironic-inspector/ironic-inspector.db && \
    crudini --set /etc/ironic-inspector/inspector.conf DEFAULT transport_url fake:// && \
    crudini --set /etc/ironic-inspector/inspector.conf DEFAULT enable_mdns True && \
    crudini --set /etc/ironic-inspector/inspector.conf processing store_data database && \
    crudini --set /etc/ironic-inspector/inspector.conf processing ramdisk_logs_dir /shared/log/ironic-inspector/ramdisk && \
    crudini --set /etc/ironic-inspector/inspector.conf processing always_store_ramdisk_logs true && \
    crudini --set /etc/ironic-inspector/inspector.conf processing power_off false && \
    crudini --set /etc/ironic-inspector/inspector.conf pxe_filter driver noop && \
    crudini --set /etc/ironic-inspector/inspector.conf processing node_not_found_hook enroll && \
    crudini --set /etc/ironic-inspector/inspector.conf discovery enroll_node_driver ipmi && \
    crudini --set /etc/ironic-inspector/inspector.conf processing processing_hooks "\$default_processing_hooks,extra_hardware,lldp_basic" && \
    crudini --set /etc/ironic-inspector/inspector.conf processing permit_active_introspection true && \
    # NOTE(dtantsur): keep this in sync with ironic-image/inspector.ipxe
    crudini --set /etc/ironic-inspector/inspector.conf mdns params \
        'ipa_debug:1,ipa_inspection_dhcp_all_interfaces:1,ipa_collect_lldp:1,ipa_inspection_collectors:"default,extra-hardware,logs"'

RUN ironic-inspector-dbsync --config-file /etc/ironic-inspector/inspector.conf upgrade 

COPY ./runironic-inspector.sh /bin/runironic-inspector
COPY ./runhealthcheck.sh /bin/runhealthcheck

HEALTHCHECK CMD /bin/runhealthcheck
RUN chmod +x /bin/runironic-inspector

ENTRYPOINT ["/bin/runironic-inspector"]

