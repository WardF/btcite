#!/bin/bash
#####
# BTCite provision script for development web server.
# Assume that we're running on Ubuntu.
#####

#####
# Update, Install system packages.
#####
if [ ! -d /home/vagrant/installation_files ]; then
#    apt-get update
    apt-get install -y emacs24 sqlite3 libsqlite3-dev nodejs htop git wget zip unzip nmap firefox links curl libyaml-dev openssl libxml2-dev libxslt1-dev libpq-dev
fi

#####
# Clean up provisioning files
#####
if [ ! -d "/home/vagrant/installation_files" ]; then
    mkdir installation_files
    mv * installation_files
fi

#####
# Install Ruby-related stuff.
#####

###
# Pre-emptively update the users path.
###

echo 'export PATH="$PATH:$HOME/.rvm/bin"' >> /home/vagrant/.profile
chown vagrant:vagrant /home/vagrant/.profile

echo 'install: --no-rdoc --no-ri' > /home/vagrant/.gemrc
echo 'update:  --no-rdoc --no-ri' >> /home/vagrant/.gemrc
chown vagrant:vagrant /home/vagrant/.gemrc

###
# Install RVM in case we want to use it.
#
# We will accomplish this by creating a script that will be run by the
# 'vagrant' user.
# 
###

touch "/home/vagrant/SOURCE_SCRIPTS_DONT_RUN_THEM"

RVMSCRIPT="/home/vagrant/first_install_rvm.sh"
RUBYVERS="2.1.1"

echo "RVERS=$RUBYVERS" > $RVMSCRIPT 
echo '' >> $RVMSCRIPT 
echo 'curl -sSL https://get.rvm.io | bash -s stable' >> $RVMSCRIPT
echo 'rvm requirements' >> $RVMSCRIPT 
echo 'rvm install $RVERS --with-openssl-dir=/usr' >> $RVMSCRIPT 
echo '' >> $RVMSCRIPT 
echo 'source /home/vagrant/.bash_profile' >> $RVMSCRIPT
echo 'rvm use $RVERS --default' >> $RVMSCRIPT 
echo 'gem update' >> $RVMSCRIPT 
echo 'gem install rails' >> $RVMSCRIPT 
echo 'gem install rake' >> $RVMSCRIPT 
echo 'gem install yard' >> $RVMSCRIPT
echo 'gem install rubygems-update' >> $RVMSCRIPT 
echo 'update_rubygems' >> $RVMSCRIPT 
echo '' >> $RVMSCRIPT 
echo 'echo "Finished."' >> $RVMSCRIPT

###
# Next, create a profile for use with the
# rails tutorial book, found at:
# http://www.railstutorial.org/book/beginning#sec-introduction
###

RVMSCRIPT="/home/vagrant/second_tutorial_install_rvm.sh"
RUBYVERS="2.0.0"

echo "RVERS=$RUBYVERS" > $RVMSCRIPT
echo '' >> $RVMSCRIPT 
echo 'rvm install $RVERS --with-openssl-dir=/usr' >> $RVMSCRIPT 
echo '' >> $RVMSCRIPT 
echo 'rvm use $RVERS@railstutorial_rails_4_0 --create' >> $RVMSCRIPT 
echo 'gem update --system 2.1.9' >> $RVMSCRIPT 
echo 'gem install rails --version 4.0.5' >> $RVMSCRIPT 
echo 'gem install rake' >> $RVMSCRIPT 
echo 'gem install rubygems-update' >> $RVMSCRIPT 
echo 'update_rubygems' >> $RVMSCRIPT 
echo '' >> $RVMSCRIPT 
echo 'echo "Finished."' >> $RVMSCRIPT 

###
# Create a script to install the heroku toolbelt.
# https://toolbelt.heroku.com/debian
###
HSCRIPT="/home/vagrant/final_heroku_toolbelt_install.sh"
echo 'wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh' >> $HSCRIPT
echo 'echo "Finished."' >> $RVMSCRIPT
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
# Create some scripts
#####

###
# Start up the btsync process, using
# the config file in /vagrant/btsync_api_dev
###

SCRIPTFILE="/home/vagrant/btsync_bootstrap.sh"
CONFDIR="/vagrant/btsync_api_dev"
CONFARC="/vagrant/btsync_api_dev.gpg"
STORDIR="/vagrant/SyncAPI"

echo '#!/bin/bash' > $SCRIPTFILE
echo '' >> $SCRIPTFILE
#echo 'set -x' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo "CONFDIR=\"$CONFDIR\"" >> $SCRIPTFILE
echo "CONFARC=\"$CONFARC\"" >> $SCRIPTFILE
echo "STORDIR=\"$STORDIR\"" >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo 'if [ ! -d "$CONFDIR" ]; then' >> $SCRIPTFILE
echo '   if [ ! -f "$CONFARC" ]; then' >> $SCRIPTFILE
echo '     echo "Unable to find configuration directory or archive."' >> $SCRIPTFILE
echo '     exit 1' >> $SCRIPTFILE
echo '   fi' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo '  pushd /vagrant' >> $SCRIPTFILE
echo '  gpg-zip -d "$CONFARC"' >> $SCRIPTFILE
echo '  popd' >> $SCRIPTFILE
echo 'fi' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo 'if [ ! -d "$STORDIR" ]; then' >> $SCRIPTFILE
echo '  echo "Creating data storage directory: $STORDIR"' >> $SCRIPTFILE
echo '  mkdir -p $STORDIR' >> $SCRIPTFILE
echo 'fi' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE
echo 'echo "Starting btsync service."' >> $SCRIPTFILE
echo 'BTS=`which btsync`' >> $SCRIPTFILE
echo 'sudo $BTS --config "$CONFDIR/btsync_config.json"' >> $SCRIPTFILE
echo '' >> $SCRIPTFILE

chmod 775 $SCRIPTFILE

#####
# Set up git
#####

sudo -i -u vagrant git config --global user.name "Ward Fisher"
sudo -i -u vagrant git config --global user.email "ward.fisher@gmail.com"
sudo -i -u vagrant git config --global push.default simple

#####
# Set up .emacs file
#####
cat "(set-face-attribute 'default nil :height 130)" >> /home/vagrant/.emacs


#####
# Final Clean Up
#####
chown -R vagrant:vagrant /home/vagrant 

