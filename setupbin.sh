#!/bin/bash
# Stop on first error

set -e

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

sudo apt-get install git -y

git init
git remote add origin https://github.com/wittrup/piawarebash.git
git fetch --all
rm -f .bashrc
git reset --hard origin/master


# mkdir only if a dir does not already exist
mkdir -p $HOME/bin

# Appending a line to a file only if it does not already exist
LINE="PATH=\"$(readlink -f .)/bin:\$PATH\""
FILE=$HOME/.bashrc
grep -q "$LINE" "$FILE" || echo "$LINE" >> "$FILE"

