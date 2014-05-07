#!/bin/bash
#####
# BTCite provision script for development web server.
# Assume that we're running on Ubuntu.
#####

#####
# Update, Install system packages.
#####
apt-get update
apt-get install -y emacs24 ruby1.9.3 sqlite3 libsqlite3-dev nodejs htop git wget zip unzip

#####
# Install Ruby-related stuff.
#####

###
# Update gems
###

gem install rubygems-update
update_rubygems

###
# Install Gems
###

gem install rake
gem install rails

#####
# Download and untar the latest
# stable x64-linux btsync.
#####

if [ ! -f /usr/local/bin/btsync.tar.gz ]; then
    wget http://download-lb.utorrent.com/endpoint/btsync/os/linux-x64/track/stable -O btsync.tar.gz
    mv btsync.tar.gz /usr/local/bin
    pushd /usr/local/bin
    tar -zxf btsync.tar.gz
    popd
fi

#####
# Set the proper timezone.
#####
echo "US/Mountain" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

#####
# Clean stuff up
#####
mkdir installation_files
mv * installation_files

#####
# Create some scripts
#####

###
# Start up the btsync process, using
# the config file in /vagrant/btsync_api_dev
###

SCRIPTFILE="/home/vagrant/btsync_bootstrap.sh"
CONFDIR="/vagrant/btsync_api_dev"
STORDIR="/vagrant/SyncAPI"

echo '#!/bin/bash' > $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo 'set -x' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo "CONFDIR=\"$CONFDIR\"" >> $SCRIPTFILE
echo "STORDIR=\"$STORDIR\"" >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo 'if [ ! -d "$CONFDIR" ]; then' >> $SCRIPTFILE
echo '   echo "Unable to find $CONFDIR ."' >> $SCRIPTFILE
echo '   exit 1' >> $SCRIPTFILE
echo 'fi' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo 'if [ ! -d "$STORDIR" ]; then' >> $SCRIPTFILE
echo '  mkdir -p $STORDIR' >> $SCRIPTFILE
echo 'fi' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE

echo 'BTS=`which btsync`' >> $SCRIPTFILE
echo 'sudo $BTS --config "$CONFDIR/btsync_config.json"' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
chmod 775 $SCRIPTFILE

#####
# Final Clean Up
#####
chown -R vagrant:vagrant /home/vagrant 

