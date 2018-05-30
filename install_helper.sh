#!/bin/sh

#  install_helper.sh
#  shadowsocks
#
#  Created by clowwindy on 14-3-15.

cd `dirname "${BASH_SOURCE[0]}"`
sudo mkdir -p "/Library/Application Support/ShadowsocksX-dummy/"
sudo touch "/Library/Application Support/ShadowsocksX-dummy/a"
echo `pwd` | sudo tee -a "/Library/Application Support/ShadowsocksX-dummy/pwd.txt"
sudo cp "proxy_conf_helper" "/Library/Application Support/ShadowsocksX-dummy/"
sudo touch "/Library/Application Support/ShadowsocksX-dummy/b"
ls "/Library/Application Support/ShadowsocksX-dummy/"
sudo touch "/Library/Application Support/ShadowsocksX-dummy/c"
sudo chown root:admin "/Library/Application Support/ShadowsocksX-dummy/proxy_conf_helper"
sudo chmod a+rx "/Library/Application Support/ShadowsocksX-dummy/proxy_conf_helper"
sudo chmod +s "/Library/Application Support/ShadowsocksX-dummy/proxy_conf_helper"

echo done
