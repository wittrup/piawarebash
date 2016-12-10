#!/usr/bin/env bash

configfile=$1
if [[ -z "$configfile" ]]; then
    exit "Configfile argument missing"
fi
configfile_secured='/tmp/ssh_tunnel_home.cfg'
# Check if the file contains something we don't want
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"; then
  echo "Config file is unclean, cleaning it..." >&2
  # Filter the original to a new file
  egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
  configfile="$configfile_secured"
fi
# Now source it, either the original or the filtered variant
source "$configfile"


# Split $destionation by ':' into $host and $port
IFS=: read -r host port <<< "$destination"
# If $port not set use 22 as default
if [[ -z "$port" ]]; then
    port=22
fi
# If $reverse port not set, then randomly select and write to config
if [[ -z "$reverse" ]]; then
    reverse=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
    echo reverse="$reverse" >> "$configfile"
fi

if [[ -n "$keyfile" ]]; then
    identity_file=" -i $keyfile"
fi
while true; do
    echo $(date +"%Y-%m-%d %H:%M:%S") Starting tunnel
    RETURN=$( { /usr/bin/ssh -o ExitOnForwardFailure=yes$identity_file -N -R $reverse:localhost:22 -p $port $host; } 2>&1)
    RESULT=$?
    if [[ $RESULT -ne 0 ]]; then
        echo $(date +"%Y-%m-%d %H:%M:%S") "["$RESULT"]" $RETURN
        if grep -i "remote port forwarding failed for listen port" <<<"${RETURN}" >/dev/null ; then
            TARGET_KEY="reverse"
            reverse=$(( ((RANDOM<<15)|RANDOM) % 63001 + 2000 ))
            sed -i "s/\($TARGET_KEY *= *\).*/\1$reverse/" $configfile
        fi
    fi
    echo $(date +"%Y-%m-%d %H:%M:%S") Tunnel down
    sleep 17
done
