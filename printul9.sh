#!/bin/bash

# go to root
cd

# Install Command
apt-get install ufw
apt-get install sudo

# Install Pritunl
#echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" > /etc/apt/sources.list.d/mongodb-org-4.0.list
#echo "deb http://repo.pritunl.com/stable/apt stretch main" > /etc/apt/sources.list.d/pritunl.list

echo "deb http://repo.mongodb.org/apt/debian stretch/mongodb-org/4.0 main" > sudo tee /etc/apt/sources.list.d/mongodb-org-4.0.list << EOF
EOF


echo "deb http://repo.pritunl.com/stable/apt stretch main" > sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
EOF

sudo apt-get install dirmngr
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 9DA31620334BD75D9DCB49F368818C72E52529D4
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
sudo apt-get update
sudo apt-get --assume-yes install pritunl mongodb-server
systemctl start mongod pritunl
systemctl enable mongod pritunl

sudo sh -c 'echo "* hard nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "* soft nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "root hard nofile 64000" >> /etc/security/limits.conf'
sudo sh -c 'echo "root soft nofile 64000" >> /etc/security/limits.conf'


# Install Squid
apt-get -y install squid
cp /etc/squid/squid.conf /etc/squid/squid.conf.orig
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/emue25/safe/master/squid.conf" 
MYIP=`ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | grep -v '192.168'`;
sed -i s/xxxxxxxxx/$MYIP/g /etc/squid/squid.conf;
systemctl restart squid

# Enable Firewall
sudo ufw allow 22,80,81,222,443,8080,9700,60000/tcp
sudo ufw allow 22,80,81,222,443,8080,9700,60000/udp
sudo yes | ufw enable

# Change to Time GMT+8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# Install Web Server
#apt-get -y install nginx php5-fpm php5-cli
#cd
#rm /etc/nginx/sites-enabled/default
#rm /etc/nginx/sites-available/default
#wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/zero9911/pritunl/master/conf/nginx.conf"
#mkdir -p /home/vps/public_html
#echo "<pre>Setup by MKSSHVPN </pre>" > /home/vps/public_html/index.html
#echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
#wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/zero9911/pritunl/master/conf/vps.conf"
#sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
#service php5-fpm restart
#service nginx restart

# Install Vnstat
#apt-get -y install vnstat
#vnstat -u -i eth0
#sudo chown -R vnstat:vnstat /var/lib/vnstat
#systemctl restart vnstat

# Install Vnstat GUI
#cd /home/vps/public_html/
#wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
#tar xf vnstat_php_frontend-1.5.1.tar.gz
#rm vnstat_php_frontend-1.5.1.tar.gz
#mv vnstat_php_frontend-1.5.1 vnstat
#cd vnstat
#sed -i "s/\$iface_list = array('eth0', 'sixxs');/\$iface_list = array('eth0');/g" config.php
#sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
#sed -i 's/Internal/Internet/g' config.php
#sed -i '/SixXS IPv6/d' config.php
#cd

# About
clear
echo "Script ini hanya mengandungi :-"
echo "-Pritunl"
echo "-MongoDB"
echo "-Vnstat"
echo "-Squid Proxy Port 80,3128,8080"
echo "CREATE BY DENBAGUSS"
echo "TimeZone   :  Malaysia"
echo "Vnstat     :  http://$MYIP:81/vnstat"
echo "Pritunl    :  https://$MYIP"
echo "Sila login ke pritunl untuk proceed step seterusnya"
echo "Sila copy code dibawah untuk Pritunl anda"
pritunl setup-key
