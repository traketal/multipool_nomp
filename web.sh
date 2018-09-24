source /etc/functions.sh
source $STORAGE_ROOT/nomp/.nomp.conf

echo Building web file structure and copying files...
cd $STORAGE_ROOT/nomp/nomp_setup/nomp
sudo cp -r $STORAGE_ROOT/nomp/nomp_setup/nomp/. $STORAGE_ROOT/nomp/site/

if [[ ("$UsingSubDomain" == "y" || "$UsingSubDomain" == "Y" || "$UsingSubDomain" == "yes" || "$UsingSubDomain" == "Yes" || "$UsingSubDomain" == "YES") ]]; then

if [[ ("$InstallSSL" == "y" || "$InstallSSL" == "Y" || "$InstallSSL" == "yes" || "$InstallSSL" == "Yes" || "$InstallSSL" == "YES") ]]; then
echo Installing LetsEncrypt and setting up SSL...
apt_install letsencrypt
hide_output sudo letsencrypt certonly --standalone --staging --webroot-path=$STORAGE_ROOT/nomp/site/ --email "$SupportEmail" --agree-tos -d "$DomainName"
echo Generating DHPARAM, this may take awhile...
hide_output sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
fi
fi

if [[ ("$InstallSSL" == "y" || "$InstallSSL" == "Y" || "$InstallSSL" == "yes" || "$InstallSSL" == "Yes" || "$InstallSSL" == "YES") ]]; then
echo Installing LetsEncrypt and setting up SSL...
apt_install letsencrypt
hide_output sudo letsencrypt certonly --standalone --staging --webroot-path=$STORAGE_ROOT/yiimp/site/web --email "$SupportEmail" --agree-tos -d "$DomainName" -d www."$DomainName"
echo Generating DHPARAM, this may take awhile...
hide_output sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
fi

echo Setting correct folder permissions...
whoami=`whoami`
sudo usermod -aG www-data $whoami
sudo usermod -a -G www-data $whoami
sudo usermod -a -G crypto-data $whoami
sudo usermod -a -G crypto-data www-data

sudo find $STORAGE_ROOT/nomp/site/ -type d -exec chmod 775 {} +
sudo find $STORAGE_ROOT/nomp/site/ -type f -exec chmod 664 {} +

sudo chgrp www-data $STORAGE_ROOT -R
sudo chmod g+w $STORAGE_ROOT -R

cd $HOME/multipool/nomp

echo Web build complete...
