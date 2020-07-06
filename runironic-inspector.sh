#!/usr/bin/bash

CONFIG=/etc/ironic-inspector/ironic-inspector.conf

. /bin/ironic-common.sh

wait_for_interface_or_ip

cp $CONFIG $CONFIG.orig

if [ ! -z "$CLIENT_CERT_FILE" ] || [ ! -z "$CLIENT_KEY_FILE" ] || [ ! -z "$CACERT_FILE" ] || [ ! -z "$INSECURE" ]; then
    crudini --merge $CONFIG <<EOF
[DEFAULT]
host = $IRONIC_IP

[ironic]
endpoint_override = https://${IRONIC_URL_HOST}:6385
$([ ! -z "$CLIENT_CERT_FILE" ] && echo "certfile = $CLIENT_CERT_FILE")
$([ ! -z "$CLIENT_KEY_FILE" ] && echo "keyfile = $CLIENT_KEY_FILE")
$([ ! -z "$CACERT_FILE" ] && echo "cafile = $CACERT_FILE")
$([ ! -z "$INSECURE" ] && echo "insecure = $INSECURE" || echo "insecure = false")

[service_catalog]
endpoint_override = https://${IRONIC_URL_HOST}:6385
$([ ! -z "$CLIENT_CERT_FILE" ] && echo "certfile = $CLIENT_CERT_FILE")
$([ ! -z "$CLIENT_KEY_FILE" ] && echo "keyfile = $CLIENT_KEY_FILE")
$([ ! -z "$CACERT_FILE" ] && echo "cafile = $CACERT_FILE")
$([ ! -z "$INSECURE" ] && echo "insecure = $INSECURE" || echo "insecure = false")
EOF
else
    crudini --merge $CONFIG <<EOF
[ironic]
endpoint_override = http://${IRONIC_URL_HOST}:6385

[service_catalog]
endpoint_override = http://${IRONIC_URL_HOST}:6385
EOF
fi

python3 -c 'import os; import sys; import jinja2; sys.stdout.write(jinja2.Template(sys.stdin.read()).render(env=os.environ))' < /etc/apache.conf.j2 > /etc/httpd/conf.d/ironic.conf
sed -i "/Listen 80/c\#Listen 80" /etc/httpd/conf/httpd.conf

/usr/sbin/httpd

exec /usr/bin/ironic-inspector --config-file /etc/ironic-inspector/inspector-dist.conf \
	--config-file /etc/ironic-inspector/inspector.conf
