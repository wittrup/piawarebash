#!/usr/bin/env bash

configfile=$HOME/ssh_tunnel_home.cfg
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

createTunnel() {
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
    # Build pipeline around ssh sub-shell, redirect errors to standard output and write to variable
    RETURN=$( { /usr/bin/ssh -N -R $reverse:localhost:22 -p $port $host; } 2>&1)
    # Store return code of last command into variable
    RESULT=$?
    # If return code not equals 0 echo return code and message
    if [[ $RESULT -ne 0 ]]; then
        echo $(date +"%Y-%m-%d %H:%M:%S") ERROR: $RESULT $RETURN
    fi
}

pid=$(/bin/pidof ssh)
if [[ $pid -eq 0 ]]; then
    createTunnel
else
    text="Tunnel is up with pid"
    tail -1 $HOME/tunnel.log | grep -q "$text" || echo $(date +"%Y-%m-%d %H:%M:%S") $text $pid
fi
