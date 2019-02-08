#!/usr/bin/bash
/usr/bin/python2 /usr/bin/ironic-inspector --config-file /etc/ironic-inspector/inspector-dist.conf --config-file /etc/ironic-inspector/inspector.conf > /var/log/ironic-inspector.out 2>&1 &
sleep infinity
