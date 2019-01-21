#####################################################
# Created by cryptopool.builders for crypto use...
#####################################################

# set our variables
source /etc/functions.sh
source /etc/multipool.conf
source $HOME/multipool/daemon_builder/.my.cnf
cd $HOME/multipool/daemon_builder

# Select random unused port for coin.conf creation

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

# Set what we need
now=$(date +"%m_%d_%Y")
set -e
NPROC=$(nproc)
if [[ ! -e '$STORAGE_ROOT/coin_builder/temp_coin_builds' ]]; then
sudo mkdir -p $STORAGE_ROOT/daemon_builder/temp_coin_builds
else
echo "temp_coin_builds already exists.... Skipping"
fi

# Just double checking folder permissions
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/daemon_builder/temp_coin_builds

cd $STORAGE_ROOT/daemon_builder/temp_coin_builds

coindir=$coinname$now

# save last coin information in case coin build fails
echo '
lastcoin='"${coindir}"'
' | sudo -E tee $STORAGE_ROOT/daemon_builder/temp_coin_builds/.lastcoin.conf >/dev/null 2>&1

# Clone the coin
if [[ ! -e $coindir ]]; then
git clone $coinrepo $coindir
else
echo "$STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir already exists.... Skipping"
echo "If there was an error in the build use the build error options on the installer"
exit 0
fi

cd "${coindir}"

# Build the coin under the proper configuration
if [[ ("$autogen" == "true") ]]; then
if [[ ("$berkeley" == "4.8") ]]; then
echo "Building using Berkeley 4.8..."
basedir=$(pwd)
sh autogen.sh
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/share/genbuild.sh
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/leveldb/build_detect_platform
./configure CPPFLAGS="-I$STORAGE_ROOT/berkeley/db4/include -O2" LDFLAGS="-L$STORAGE_ROOT/berkeley/db4/lib" --without-gui --disable-tests
else
echo "Building using Berkeley 5.3..."
basedir=$(pwd)
sh autogen.sh
sudo chmod 777 $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/share/genbuild.sh
sudo chmod 777 $STORAGE_ROOT/daemon_builderr/temp_coin_builds/$coindir/src/leveldb/build_detect_platform
./configure CPPFLAGS="-I$STORAGE_ROOT/berkeley/db5/include -O2" LDFLAGS="-L$STORAGE_ROOT/berkeley/db5/lib" --without-gui --disable-tests
fi
make -j$(nproc)
else
echo "Building using makefile.unix method..."
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src
if [[ ! -e '$STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/obj' ]]; then
mkdir -p $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/obj
else
echo "Hey the developer did his job and the src/obj dir is there!"
fi
if [[ ! -e '$STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/obj/zerocoin' ]]; then
mkdir -p $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/obj/zerocoin
else
echo  "Wow even the /src/obj/zerocoin is there! Good job developer!"
fi
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/leveldb
sudo chmod +x build_detect_platform
sudo make clean
sudo make libleveldb.a libmemenv.a
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src
sed -i '/USE_UPNP:=0/i BDB_LIB_PATH = /home/crypto-data/berkeley/db4/lib\nBDB_INCLUDE_PATH = /home/crypto-data/berkeley/db4/include\nOPENSSL_LIB_PATH = /home/crypto-data/openssl/lib\nOPENSSL_INCLUDE_PATH = /home/crypto-data/openssl/include' makefile.unix
make -j$NPROC -f makefile.unix USE_UPNP=-
fi

clear

# LS the SRC dir to have user input bitcoind and bitcoin-cli names
cd $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/
find . -maxdepth 1 -type f \( -perm -1 -o \( -perm -10 -o -perm -100 \) \) -printf "%f\n"
read -e -p "Please enter the coind name from the directory above, example bitcoind :" coind
read -e -p "Is there a coin-cli, example bitcoin-cli [y/N] :" ifcoincli

if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
read -e -p "Please enter the coin-cli name :" coincli
fi

clear

# Strip and copy to /usr/bin
sudo strip $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/$coind
sudo cp $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/$coind /usr/bin
if [[ ("$ifcoincli" == "y" || "$ifcoincli" == "Y") ]]; then
sudo strip $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/$coincli
sudo cp $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir/src/$coincli /usr/bin
fi

# Make the new wallet folder and autogenerate the coin.conf
if [[ ! -e '$STORAGE_ROOT/wallets' ]]; then
sudo mkdir -p $STORAGE_ROOT/wallets
fi

sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/wallets
mkdir -p $STORAGE_ROOT/wallets/."${coind::-1}"

rpcpassword=$(openssl rand -base64 29 | tr -d "=+/")
rpcport=$(EPHYMERAL_PORT)

echo 'rpcuser=NOMPrpc
rpcpassword='${rpcpassword}'
rpcport='${rpcport}'
rpcthreads=8
rpcallowip=127.0.0.1
# onlynet=ipv4
maxconnections=12
daemon=1
gen=0
' | sudo -E tee $STORAGE_ROOT/wallets/."${coind::-1}"/"${coind::-1}".conf >/dev/null 2>&1
' | sudo -E tee $HOME/."${coind::-1}"/"${coind::-1}".conf >/dev/null 2>&1

echo "Starting ${coind::-1}"
/usr/bin/veild -generateseed=1 -daemon=1
/usr/bin/"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" -daemon -shrinkdebugfile
/usr/bin/"${coind}" -datadir=$HOME/."${coind::-1}" -conf="${coind::-1}.conf" -daemon -shrinkdebugfile

# Create easy daemon start file
echo '
"${coind}" -datadir=$STORAGE_ROOT/wallets/."${coind::-1}" -conf="${coind::-1}.conf" -daemon -shrinkdebugfile
"${coind}" -datadir=$HOME/."${coind::-1}" -conf="${coind::-1}.conf" -daemon -shrinkdebugfile
' | sudo -E tee /usr/bin/"${coind::-1}" >/dev/null 2>&1
sudo chmod +x /usr/bin/"${coind::-1}"

# If we made it this far everything built fine removing last coin.conf and build directory
sudo rm -r $STORAGE_ROOT/daemon_builder/temp_coin_builds/.lastcoin.conf
sudo rm -r $STORAGE_ROOT/daemon_builder/temp_coin_builds/$coindir
sudo rm -r $HOME/multipool/daemon_builder/.my.cnf

echo 'rpcpassword='${rpcpassword}'
rpcport='${rpcport}''| sudo -E tee $HOME/multipool/daemon_builder/.my.cnf

cd $HOME/multipool/nomp
