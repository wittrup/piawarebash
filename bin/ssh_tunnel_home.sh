#!/usr/bin/env bash

# Make this executable by doing the following:
# chmod 700 ~/ssh_tunnel_home.sh

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
  /usr/bin/ssh -N -R 2222:localhost:22 -p $port $destination
  if [[ $? -eq 0 ]]; then
    echo Tunnel to jumpbox created successfully
  else
    echo An error occurred creating a tunnel to jumpbox. RC was $?
  fi
}
/bin/pidof ssh
if [[ $? -ne 0 ]]; then
  date
  echo Creating new tunnel connection
  createTunnel
fi
