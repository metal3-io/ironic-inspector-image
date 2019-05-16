#!/usr/bin/bash

PROVISIONING_INTERFACE=${PROVISIONING_INTERFACE:-"provisioning"}

# Allow access to Ironic inspector API
if ! iptables -C INPUT -i "$PROVISIONING_INTERFACE" -p tcp -m tcp --dport 5050 -j ACCEPT > /dev/null 2>&1; then
    iptables -I INPUT -i "$PROVISIONING_INTERFACE" -p tcp -m tcp --dport 5050 -j ACCEPT
fi

# Remove log files from last deployment
rm -rf /shared/log/ironic-inspector

mkdir -p /shared/log/ironic-inspector

/usr/bin/python2 /usr/bin/ironic-inspector --config-file /etc/ironic-inspector/inspector-dist.conf --config-file /etc/ironic-inspector/inspector.conf --log-file /shared/log/ironic-inspector/ironic-inspector.log
