#!/bin/bash

DEVICE=/dev/xvdb
FS_TYPE=$(file -s $DEVICE | awk '{print $2}')
MOUNT_POINT=/home/ubuntu/.band

# If no FS, then this output contains "data"
if [ "$FS_TYPE" = "no" ]
then
    echo "Creating file system on $DEVICE"
    sudo mkfs -t ext4 $DEVICE
fi

mkdir $MOUNT_POINT
sudo chown -R ubuntu:ubuntu $MOUNT_POINT
sudo mount $DEVICE $MOUNT_POINT

sudo apt-get update -y
sudo apt-get install git zip curl wget build-essential jq -y

sudo rm -rf /usr/local/go
curl https://go.dev/dl/go1.19.12.linux-amd64.tar.gz | sudo tar -C /usr/local -xzf -
cat <<'EOF' >>$HOME/.profile
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin
EOF
source $HOME/.profile

git clone https://github.com/bandprotocol/chain
cd chain
git fetch
git checkout v2.5.2
make install

sudo cp -r /home/ubuntu/go/bin/bandd /usr/local/bin/
sudo cp -r /home/ubuntu/go/bin/yoda /usr/local/bin/
sudo chown -R ubuntu:ubuntu /home/ubuntu/.band
curl https://raw.githubusercontent.com/bandprotocol/launch/master/laozi-mainnet/files.tar.gz | sudo tar -C $HOME/.band/ -xzf -


chainName=`laozi-mainnet`
bandd init --chain-id $chainName validator
curl https://raw.githubusercontent.com/bandprotocol/launch/master/laozi-mainnet/genesis.json > $HOME/.band/config/genesis.json 
bandd unsafe-reset-all

peers=`98823087b61d442a4ab86998709c77b2e517ee78@35.240.152.216:26656,d047cfabdfd5e244af530d6d2101d07c45ff7424@165.22.167.234:41656,1a4af7cbd3db94a3881dc35cfa261ec2ac788f8f@91.246.64.247:26656,570787c6484fb5aef9182f032dbd54042d93b93c@35.82.85.220:26656,39d45dae55f36db42ef3997376efbbf725666f75@51.38.53.4:30656`
seeds=`8d42bdcb6cced03e0b67fa3957e4e9c8fd89015a@34.87.86.195:26656,2c884e60a0944958a2a9389f07f2f66dcfc3add0@seeds-bandprotocol.activenodes.io:36656`
sed -i.bak 's/^log_level/# log_level/' $HOME/.band/config/config.toml
sed -i.bak -e "s/^seeds *=.*/seeds = $seeds/; s/^persistent_peers *=.*/persistent_peers = $peers/" $HOME/.band/config/config.toml

sudo tee <<EOF >/dev/null /etc/systemd/system/band.service
[Unit]
Description=Band Validator daemon
After=network-online.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/bandd start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo tee <<EOF >/dev/null /etc/systemd/system/yoda.service
[Unit]
Description=Band Yoda daemon
After=network-online.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/yoda start
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable bandd
sudo systemctl enable yoda
sudo systemctl daemon-reload
sudo systemctl start bandd
sudo systemctl start yoda
