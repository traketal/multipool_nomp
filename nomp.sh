#####################################################
# Created by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source $STORAGE_ROOT/nomp/.nomp.conf
source $HOME/multipool/daemon_builder/.my.cnf

# Create function for random unused port
function EPHYMERAL_PORT(){
    LPORT=32768;
    UPORT=60999;
    while true; do
        MPORT=$[$LPORT + ($RANDOM % $UPORT)];
        (echo "" >/dev/tcp/127.0.0.1/${MPORT}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $MPORT;
            return 0;
        fi
    done
}

echo "Making the NOMPness Monster"

cd $STORAGE_ROOT/nomp/site/

# NPM install and update, user can ignore errors
npm install
npm i npm@latest -g

# SED config file
sudo sed -i 's/FQDN/'$StratumURL'/g' config.json
sudo sed -i 's/PASSWORD/'$AdminPass'/g' config.json

# Create the coin json file
cd $STORAGE_ROOT/nomp/site/pool_configs
sudo cp -r base_samp.json $coinname.json

# Generate our random ports
randportlow=$(EPHYMERAL_PORT)
randportvar=$(EPHYMERAL_PORT)
randporthigh=$(EPHYMERAL_PORT)

#Generate new wallet address
if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
wallet="$("${coind::-1}-cli" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" getnewaddress)"
else
wallet="$("${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" getnewaddress)"
fi

# SED the coin file
sudo sed -i 's/coinname/'$coinname'/g' $coinname.json
sudo sed -i 's/wallet/'$wallet'/g' $coinname.json
sudo sed -i 's/daemonport/'$rpcport'/g' $coinname.json
sudo sed -i 's/rpcuser/NOMPrpc/g' $coinname.json
sudo sed -i 's/rpcpass/'$rpcpassword'/g' $coinname.json
sudo sed -i 's/randportlow/'$randportlow'/g' $coinname.json
sudo sed -i 's/randportvar/'$randportvar'/g' $coinname.json
sudo sed -i 's/randporthigh/'$randporthigh'/g' $coinname.json

cd $STORAGE_ROOT/nomp/site/coins

sudo cp -r default.json $coinname.json
sudo sed -i 's/coinname/'$coinname'/g' $coinname.json
sudo sed -i 's/coinsymbol/'$coinsymbol'/g' $coinname.json
sudo sed -i 's/coinalgo/'$coinalgo'/g' $coinname.json
sudo sed -i 's/getblockapi/'$getblockapi'/g' $coinname.json
sudo sed -i 's/blockexplorer/'$blockexplorer'/g' $coinname.json
sudo sed -i 's/getblocktx/'$getblocktx'/g' $coinname.json
sudo sed -i 's/cointime/'$cointime'/g' $coinname.json

# Allow user account to bind to port 80 and 443 with out sudo privs
apt_install authbind
sudo touch /etc/authbind/byport/80
sudo touch /etc/authbind/byport/443
sudo chmod 777 /etc/authbind/byport/80
sudo chmod 777 /etc/authbind/byport/443

cd $HOME/multipool/nomp
