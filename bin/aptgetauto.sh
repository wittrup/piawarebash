#!/usr/bin/env bash
# UPDATING AND UPGRADING RASPBIAN
#   First, update your system's package list by entering the following command in
#   LXTerminal or from the command line:
date

sudo apt-get update -y
#   Next, upgrade all your installed packages to their latest versions with the
#   command:

sudo apt-get dist-upgrade -y
#   Generally speaking, doing this regularly will keep your installation up to date, in that
#   it will be equivalent to the latest released image available from
#   raspberrypi.org/downloads.

#   However, there are occasional changes made in the Foundation's Raspbian image
#   that require manual intervention, for example a newly introduced package. These
#   are not installed with an upgrade, as this command only updates the packages you
#   already have installed.

#   UPDATING THE KERNEL AND FIRMWARE
#   The kernel and firmware are installed as a Debian package, and so will also get
#   updates when using the procedure above. These packages are updated
#   infrequently and after extensive testing.

#   RUNNING OUT OF SPACE
#   When running sudo apt-get dist-upgrade, it will show how much data will be
#   downloaded and how much space it will take up on the SD card. It's worth checking
#   with df -h that you have enough disk space free, as unfortunately apt will not
#   do this for you. Also be aware that downloaded package files (.deb files) are kept
#   in /var/cache/apt/archives. You can remove these in order to free up space with
sudo apt-get clean  -y
df -h
date
