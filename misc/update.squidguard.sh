#!/bin/sh
# This script will update blocklists for squidguard

LOGFILE="/var/log/squidGuard/squidGuard.update.log"
CONFDIR="/etc/squidGuard"
TEMPDIR="/tmp/squidguard"
DATABASE="/var/sgdb"

echo =================================================== >> "$LOGFILE"
mkdir -p $TEMPDIR

# FETCH ADBLOCK FILES FROM MESD
#ADDY="http://squidguard.mesd.k12.or.us/blacklists.tgz"
#wget -nv -a "$LOGFILE" -P "$TEMPDIR/" $ADDY >> "$LOGFILE"
#tar --overwrite -xzvf "$TEMPDIR/blacklists.tgz" -C "$DATABASE"

# FETCH ADBLOCK LIST FROM shallalist
ADDY="http://www.shallalist.de/Downloads/shallalist.tar.gz"
wget -nv -a "$LOGFILE" -P "$TEMPDIR/" $ADDY >> "$LOGFILE"
tar --overwrite -xzvf "$TEMPDIR/shallalist.tar.gz" -C "$DATABASE"

# PROCESS DATABASES IN USE
squidGuard -C all

# FIX OWNERSHIP AND PERMISSIONS
chown -R squid:squid "$DATABASE"

# RESTART SQUID
/etc/init.d/squid restart
