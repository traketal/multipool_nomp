#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source /etc/multipool.conf

message_box "Ultimate Crypto-Server Setup Installer" \
"You have choosen to install NOMP Single Server!
\n\nThis will install NOMP and help setup your first coin for the server.
\n\nAfter answering the following questions, setup will be mostly automated.
\n\nNOTE: If installing on a system with less then 2 GB of RAM you may experience system issues!"

if [ -z "$UsingSubDomain" ]; then
DEFAULT_UsingSubDomain=no
input_box "Using Sub-Domain" \
"Are you using a sub-domain for the main website domain? Example pool.example.com?
\n\nPlease answer (y)es or (n)o only:" \
$DEFAULT_UsingSubDomain \
UsingSubDomain

if [ -z "$UsingSubDomain" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$InstallSSL" ]; then
DEFAULT_InstallSSL=yes
input_box "Install SSL" \
"Would you like the system to install SSL automatically?
\n\nPlease answer (y)es or (n)o only:" \
$DEFAULT_InstallSSL \
InstallSSL

if [ -z "$InstallSSL" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$DomainName" ]; then
DEFAULT_DomainName=localhost
input_box "Domain Name" \
"Enter your domain name. If using a subdomain enter the full domain as in pool.example.com
\n\nDo not add www. to the domain name.
\n\nDomain Name:" \
$DEFAULT_DomainName \
DomainName

if [ -z "$DomainName" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$StratumURL" ]; then
DEFAULT_StratumURL=stratum.$DomainName
input_box "Stratum URL" \
"Enter your stratum URL. It is recommended to use another subdomain such as stratum.$DomainName
\n\nDo not add www. to the domain name.
\n\nStratum URL:" \
$DEFAULT_StratumURL \
StratumURL

if [ -z "$StratumURL" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$SupportEmail" ]; then
DEFAULT_SupportEmail=support@$DomainName
input_box "System Email" \
"Enter an email address for the system to send alerts and other important messages.
\n\nSystem Email:" \
$DEFAULT_SupportEmail \
SupportEmail

if [ -z "$SupportEmail" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinname" ]; then
DEFAULT_coinname=Bitcoin
input_box "Coin Name" \
"Enter your first coins name..
\n\nCoin Name:" \
$DEFAULT_coinname \
coinname

if [ -z "$coinname" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinsymbol" ]; then
DEFAULT_coinsymbol=BTC
input_box "Coin Symbol" \
"Enter your coins symbol..
\n\nCoin Symbol:" \
$DEFAULT_coinsymbol \
coinsymbol

if [ -z "$coinsymbol" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinalgo" ]; then
DEFAULT_coinalgo=sha256
input_box "Coin Algorithm" \
"Enter your coins algorithm.. Enter as all lower case...
\n\nCoin Algorithm:" \
$DEFAULT_coinalgo \
coinalgo

if [ -z "$coinalgo" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$cointime" ]; then
DEFAULT_cointime=120
input_box "Coin Block Time" \
"Enter your coins block time in seconds..
\n\nCoin Block Time:" \
$DEFAULT_cointime \
cointime

if [ -z "$cointime" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$AdminPass" ]; then
DEFAULT_AdminPass=$(openssl rand -base64 8 | tr -d "=+/")
input_box "Admin Password" \
"Enter your new Admin password or use this randomly system generated one.
\n\nUnfortunatley dialog doesnt let you copy. So you have to write it down.
\n\nAdmin password:" \
$DEFAULT_AdminPass \
AdminPass

if [ -z "$AdminPass" ]; then
# user hit ESC/cancel
exit
fi
fi

if [ -z "$coinrepo" ]; then
DEFAULT_coinrepo="github"
input_box "Default Coin Repo" \
"Enter your coins repo to use..
\n\nIf you are using a private repo and do not specify the user name and password here, you will be promted
\n\nfor it during the installation. Instalaltion will not continue until you enter that information.
\n\nWhen pasting your link CTRL+V does NOT work, you must either SHIFT+RightMouseClick or SHIFT+INSERT!!
\n\nDefault Coin Repo:" \
$DEFAULT_coinrepo \
coinrepo

if [ -z "$coinrepo" ]; then
# user hit ESC/cancel
exit
fi
fi

RESULT=$(dialog --stdout --title "Ultimate Crypto-Server Daemon Installer" --menu "Choose one" -1 60 4 \
1 "Build coin with Berkeley 4.x" \
2 "Build coin with Berkeley 5.x" \
3 "Build coin with makefile.unix" \
4 Exit)
if [ $RESULT = ]
then
exit ;
fi

if [ $RESULT = 1 ]
then
clear;
echo '
autogen=true
berkeley="4.8"
' | sudo -E tee $HOME/multipool/daemon_builder/.my.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 2 ]
then
clear;
echo '
autogen=true
berkeley="5.3"
' | sudo -E tee $HOME/multipool/daemon_builder/.my.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 3 ]
then
clear;
echo '
autogen=false
' | sudo -E tee $HOME/multipool/daemon_builder/.my.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 4 ]
then
clear;
exit;
fi

# Save the global options in $STORAGE_ROOT/yiimp/.yiimp.conf so that standalone
# tools know where to look for data.
echo 'STORAGE_USER='"'"''"${STORAGE_USER}"''"'"'
STORAGE_ROOT='"'"''"${STORAGE_ROOT}"''"'"'
DomainName='"'"''"${DomainName}"''"'"'
StratumURL='"'"''"${StratumURL}"''"'"'
SupportEmail='"'"''"${SupportEmail}"''"'"'
UsingSubDomain='"'"''"${UsingSubDomain}"''"'"'
InstallSSL='"'"''"${InstallSSL}"''"'"'
coinname='"'"''"${coinname}"''"'"'
coinsymbol='"'"''"${coinsymbol}"''"'"'
coinalgo='"'"''"${coinalgo}"''"'"'
cointime='"'"''"${cointime}"''"'"'
AdminPass='"'"''"${AdminPass}"''"'"'

# Unless you do some serious modifications this installer will not work with any other repo of nomp!
coinrepo='"${coinrepo}"'
' | sudo -E tee $STORAGE_ROOT/nomp/.nomp.conf >/dev/null 2>&1

cd $HOME/multipool/nomp
