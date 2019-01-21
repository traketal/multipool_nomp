#####################################################
# Created by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
source $STORAGE_ROOT/nomp/.nomp.conf

echo Installing BitCoin PPA...
if [ ! -f /etc/apt/sources.list.d/bitcoin.list ]; then
hide_output sudo add-apt-repository -y ppa:bitcoin/bitcoin
fi
echo Installing additional system files required for daemons...
hide_output sudo apt-get update
apt_install build-essential libtool autotools-dev \
automake pkg-config libssl-dev libevent-dev bsdmainutils git libboost-all-dev libminiupnpc-dev \
libqt5gui5 libqt5core5a libqt5webkit5-dev libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev \
protobuf-compiler libqrencode-dev libzmq3-dev

cd $STORAGE_ROOT/nomp/nomp_setup/tmp

echo Building Berkeley 4.8, this may take several minutes...
sudo mkdir -p $STORAGE_ROOT/berkeley/db4/
hide_output wget 'http://download.oracle.com/berkeley-db/db-4.8.30.NC.tar.gz'
hide_output tar -xzvf db-4.8.30.NC.tar.gz
cd db-4.8.30.NC/build_unix/
hide_output ../dist/configure --enable-cxx --disable-shared --with-pic --prefix=$STORAGE_ROOT/berkeley/db4/
hide_output sudo make install
cd $STORAGE_ROOT/nomp/nomp_setup/tmp
sudo rm -r db-4.8.30.NC.tar.gz db-4.8.30.NC

echo Daemon setup completed...

cd $HOME/multipool/nomp
