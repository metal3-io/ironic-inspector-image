#!/bin/bash
set -ex

trap killcontainer ERR
function killcontainer(){
    killall -9 sleep
}

while true ; do
    sleep 30

    curl -s http://localhost:5050 > /dev/null || ( echo "Can't contact ironic-inspector-api" && exit 1 )

done
