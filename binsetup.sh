#!/usr/bin/env bash
#chmod 700 $0

# mkdir only if a dir does not already exist
mkdir -p $HOME/bin

# Appending a line to a file only if it does not already exist
LINE='PATH="$HOME/bin:$PATH"'
FILE=$HOME/.bashrc
grep -q "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

ln -s /var/spool/cron/crontabs/$USER $USERcrontab
