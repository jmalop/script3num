for PORT in {1..65535}; do (echo > /dev/tcp/X.X.X.X/$PORT) >/dev/null 2>&1 && echo $PORT is open; done
for PORT in {1..65535}; do timeout 1 bash -c "</dev/tcp/X.X.X.X/$PORT >/dev/null" && echo "port $PORT is open"; done


----------------------------------------------------------------------


for port in $(seq 1 65535); do
    timeout 1 bash -c "echo '' > /dev/tcp/X.X.X.X/$PORT" 2>/dev/null && echo "[+] Port $port - OPEN" &
done; wait
