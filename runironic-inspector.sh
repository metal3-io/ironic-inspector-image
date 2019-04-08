#!/usr/bin/bash

INTERFACE=${INTERFACE:-"provisioning"}

# Allow access to Ironic inspector API
if ! iptables -C INPUT -i $INTERFACE -p tcp -m tcp --dport 5050 -j ACCEPT > /dev/null 2>&1; then
    iptables -I INPUT -i $INTERFACE -p tcp -m tcp --dport 5050 -j ACCEPT
fi

/usr/bin/python2 /usr/bin/ironic-inspector --config-file /etc/ironic-inspector/inspector-dist.conf --config-file /etc/ironic-inspector/inspector.conf
