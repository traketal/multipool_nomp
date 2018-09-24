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

cd $STORAGE_ROOT/nomp/site/nomp

# NPM install and update, user can ignore errors
npm install
npm i npm@latest -g

# SED config file
sudo sed -i 's/FQDN/'$StratumURL'/g' config.json
sudo sed -i 's/PASSWORD/'$AdminPass'/g' config.json

# Create the coin json file
cd $STORAGE_ROOT/nomp/site/nomp/pool_configs
sudo cp -r base_samp.json $coinname.json

# Generate our random ports
randportlow=$(EPHYMERAL_PORT)
randportvar=$(EPHYMERAL_PORT)
randporthigh=$(EPHYMERAL_PORT)

# SED the coin file
sudo sed -i 's/daemonport/'$rpcport'/g' $coinname.json
sudo sed -i 's/rpcuser/NOMPrpc/g' $coinname.json
sudo sed -i 's/rpcpass/'$rpcpassword'/g' $coinname.json
sudo sed -i 's/randportlow/'$randportlow'/g' $coinname.json
sudo sed -i 's/randportvar/'$randportvar'/g' $coinname.json
sudo sed -i 's/randporthigh/'$randporthigh'/g' $coinname.json

cd $HOME/multipool/nomp

# Allow user account to bind to port 80 and 443 with out sudo privs
apt_install authbind
sudo touch /etc/authbind/byport/80
sudo touch /etc/authbind/byport/443
sudo chmod 777 /etc/authbind/byport/80
sudo chmod 777 /etc/authbind/byport/443
