#!/bin/bash

#for PORT in {1..65535}; do (echo > /dev/tcp/X.X.X.X/$PORT) >/dev/null 2>&1 && echo $PORT is open; done
#for PORT in {1..65535}; do timeout 1 bash -c "</dev/tcp/X.X.X.X/$PORT >/dev/null" && echo "port $PORT is open"; done

if [ -z "$1" ]
then
        echo -e "\nUsage: ./b4sc4n.sh <IP>"
        exit 1
fi

for port in $(seq 1 65535); do
    timeout 1 bash -c "echo '' > /dev/tcp/$1/$port" 2>/dev/null && echo "[+] Port $port - OPEN" &
done; wait
