#!/bin/bash
#####
# BTCite provision script for development web server.
# Assume that we're running on Ubuntu.
#####

#####
# Update, Install system packages.
#####
if [ ! -d /home/vagrant/installation_files ]; then
    apt-get update
    apt-get -y upgrade
    apt-get install -y emacs24 sqlite3 libsqlite3-dev nodejs htop git wget zip unzip nmap firefox links curl libyaml-dev openssl libxml2-dev libxslt1-dev libpq-dev
    apt-get autoremove
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

RVMSCRIPT="/home/vagrant/install_rvm_and_ruby.sh"
RUBYVERS="2.1.2"

echo "RVERS=$RUBYVERS" > $RVMSCRIPT
echo '' >> $RVMSCRIPT
echo 'gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3' >> $RVMSCRIPT
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
sudo -i -u vagrant git config --global user.email "wfisher@unidata.ucar.edu"
sudo -i -u vagrant git config --global push.default simple

#####
# Set up .emacs file
#####

if [ ! -f /home/vagrant/.emacs ]; then
    echo "(normal-erase-is-backspace-mode 1)" >> /home/vagrant/.emacs
    echo "(set-face-attribute 'default nil :height 130)" >> /home/vagrant/.emacs
    echo '(custom-set-variables' >> /home/vagrant/.emacs
    echo " '(inhibit-startup-screen t)" >> /home/vagrant/.emacs
    echo " '(show-paren-mode t)" >> /home/vagrant/.emacs
    echo " '(uniquify-buffer-name-style (quote forward) nil (uniquify)))" >> /home/vagrant/.emacs
fi

#####
# Set up symbolic links
# for ease-of-use.
#####

if [ ! -f "/home/vagrant/sample_app" ]; then
    ln -s /vagrant/rails_projects/sample_app /home/vagrant/sample_app
fi

#####
# Grab the 'aptana studio' installer, which may need to be
# installed manually.
#####

#if [ ! -d "/vagrant/Aptana_Studio_3" ]; then
#    STUDIO_FNAME="Aptana_Studio_3_Setup_Linux_x86_64_3.4.2.zip"
#    if [ ! -f "/vagrant/$STUDIO_FNAME" ]; then
#	wget http://download.aptana.com/studio3/standalone/3.4.2/linux/"$STUDIO_FNAME"
#	cp "$STUDIO_FNAME" /vagrant
#    else
#	cp "/vagrant/$STUDIO_FNAME" .
#    fi

#    unzip "$STUDIO_FNAME"
#    rm "$STUDIO_FNAME"
#fi

#####
# Final Clean Up
#####
chown -R vagrant:vagrant /home/vagrant
