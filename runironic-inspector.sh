#!/usr/bin/bash

PROVISIONING_INTERFACE=${PROVISIONING_INTERFACE:-"provisioning"}

CONFIG=/etc/ironic-inspector/inspector.conf
PROVISIONING_IP=$(ip -4 address show dev "$PROVISIONING_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)

until [ ! -z "${PROVISIONING_IP}" ]; do
  echo "Waiting for ${PROVISIONING_INTERFACE} interface to be configured"
  sleep 1
  PROVISIONING_IP=$(ip -4 address show dev "$PROVISIONING_INTERFACE" | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -n 1)
done

# Allow access to Ironic inspector API
if ! iptables -C INPUT -i "$PROVISIONING_INTERFACE" -p tcp -m tcp --dport 5050 -j ACCEPT > /dev/null 2>&1; then
    iptables -I INPUT -i "$PROVISIONING_INTERFACE" -p tcp -m tcp --dport 5050 -j ACCEPT
fi

# Allow access to mDNS
if ! iptables -C INPUT -i $PROVISIONING_INTERFACE -p udp --dport 5353 -j ACCEPT > /dev/null 2>&1; then
    iptables -I INPUT -i $PROVISIONING_INTERFACE -p udp --dport 5353 -j ACCEPT
fi
if ! iptables -C OUTPUT -p udp --dport 5353 -j ACCEPT > /dev/null 2>&1; then
    iptables -I OUTPUT -p udp --dport 5353 -j ACCEPT
fi

# Remove log files from last deployment
rm -rf /shared/log/ironic-inspector

mkdir -p /shared/log/ironic-inspector

cp $CONFIG $CONFIG.orig

crudini --set $CONFIG ironic endpoint_override http://$PROVISIONING_IP:6385
crudini --set $CONFIG service_catalog endpoint_override http://$PROVISIONING_IP:5050
crudini --set $CONFIG mdns interfaces $PROVISIONING_IP

exec /usr/bin/ironic-inspector --config-file /etc/ironic-inspector/inspector-dist.conf \
	--config-file /etc/ironic-inspector/inspector.conf \
	--log-file /shared/log/ironic-inspector/ironic-inspector.log

