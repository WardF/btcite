#!/bin/bash
# BTCite provision script for development web server.
# Assume that we're running on Ubuntu.

#####
# Set the proper timezone.
#####
echo "US/Mountain" | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata
