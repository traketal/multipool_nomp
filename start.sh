#!/usr/bin/env bash
#####################################################
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source /etc/multipool.conf
# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

if ! locale -a | grep en_US.utf8 > /dev/null; then
# Generate locale if not exists
hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

# Create the temporary installation directory if it doesn't already exist.
echo Creating the temporary NOMP installation folder...
if [ ! -d $STORAGE_ROOT/nomp/nomp_setup ]; then
sudo mkdir -p $STORAGE_ROOT/nomp/nomp_setup
sudo mkdir -p $STORAGE_ROOT/nomp/nomp_setup/tmp
sudo mkdir -p $STORAGE_ROOT/nomp/site
sudo mkdir -p $STORAGE_ROOT/nomp/starts
sudo mkdir -p $STORAGE_ROOT/wallets
sudo mkdir -p $HOME/multipool/daemon_builder
fi
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/nomp
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/nomp/site
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/wallets
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/nomp/nomp_setup/tmp

# Start the installation.
source questions.sh
source system.sh
source db.sh
source web.sh
#source daemon.sh
#source build_coin.sh
source nomp.sh
source motd.sh
source server_harden.sh
source server_cleanup.sh

clear
echo Installation of your NOMP single server is now completed.
echo You *MUST* reboot the machine to finalize the machine updates and folder permissions! NOMP will not function until a reboot is performed!
echo
echo
echo By default all stratum ports are blocked by the firewall. To allow a port through, from the command prompt type sudo ufw allow port number.
