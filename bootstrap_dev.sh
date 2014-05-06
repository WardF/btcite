#!/bin/bash
#####
# BTCite provision script for development web server.
# Assume that we're running on Ubuntu.
#####

#####
# Update, Install system packages.
#####
apt-get update
apt-get install -y emacs24 ruby1.9.3 sqlite3 libsqlite3-dev nodejs htop git

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
# Set the proper timezone.
#####
echo "US/Mountain" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

