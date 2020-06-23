#!/bin/bash
set -ex


if [ -z "$CERT_FILE" ] || [ -z "$KEY_FILE" ]; then
    curl -s http://127.0.0.1:5050
else
    curl -k -s https://127.0.0.1:5050
fi