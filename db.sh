source /etc/functions.sh
source $STORAGE_ROOT/nomp/.nomp.conf

echo Installing Redis...
apt_install build-essential tcl

cd $STORAGE_ROOT/nomp/nomp_setup/tmp
hide_ouput curl -O http://download.redis.io/redis-stable.tar.gz
hide_output tar xzvf redis-stable.tar.gz
cd redis-stable
hide_output make
hide_ouput sudo make install
sudo mkdir /etc/redis
sudo cp /tmp/redis-stable/redis.conf /etc/redis

sudo sed -i 's/supervised no/supervised systemd/g' /etc/redis/redis.conf
sudo sed -i 's|dir ./|dir /var/lib/redis|g' /etc/redis/redis.conf

echo '
[Unit]
Description=Redis In-Memory Data Store
After=network.target

[Service]
User=redis
Group=redis
ExecStart=/usr/local/bin/redis-server /etc/redis/redis.conf
ExecStop=/usr/local/bin/redis-cli shutdown
Restart=always

[Install]
WantedBy=multi-user.target
' | sudo -E tee /etc/systemd/system/redis.service >/dev/null 2>&1

hide_ouput sudo adduser --system --group --no-create-home redis
sudo mkdir /var/lib/redis
sudo chown redis:redis /var/lib/redis
sudo chmod 770 /var/lib/redis
sudo systemctl start redis

echo Database build complete...
cd $HOME/multipool/nomp
