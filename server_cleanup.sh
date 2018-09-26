#####################################################
# Created by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source $STORAGE_ROOT/nomp/.nomp.conf

echo Installing cron screens to crontab...
(crontab -l 2>/dev/null; echo "@reboot sleep 20 && /home/crypto-data/nomp/starts/nomp.start.sh") | crontab -

echo Creating NOMP startup script...
echo '#!/bin/bash
source /etc/multipool.conf
################################################################################
# Author: cryptopool.builders
#
#
# Program: nomp screen startup script
#
# BTC Donation: 12Pt3vQhQpXvyzBd5qcoL17ouhNFyihyz5
#
################################################################################
cd $STORAGE_ROOT/nomp/site
screen -dmS nomp authbind node init.js
' | sudo -E tee $STORAGE_ROOT/nomp/starts/nomp.start.sh >/dev/null 2>&1
sudo chmod +x $STORAGE_ROOT/nomp/starts/nomp.start.sh

echo '
source /etc/multipool.conf
source $STORAGE_ROOT/nomp/.nomp.conf
' | sudo -E tee $STORAGE_ROOT/nomp/.prescreens.start.conf >/dev/null 2>&1

echo "source /etc/multipool.conf" | hide_output tee -a ~/.bashrc
echo "source $STORAGE_ROOT/nomp/.prescreens.start.conf" | hide_output tee -a ~/.bashrc

sudo rm -r $STORAGE_ROOT/nomp/nomp_setup
