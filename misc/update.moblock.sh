#!/bin/sh

LOGFILE="/var/log/moblock/moblock.update.log"
CONFDIR="/etc/moblock"
MASTERF="$CONFDIR/master.p2p"

echo =================================================== >> "$LOGFILE"
date >> "$LOGFILE"

# FETCH FILES
UPDTURL="http://www.bluetack.co.uk/config/level1.gz"
for addy in $UPDTURL; do
   echo Fetching $addy >> "$LOGFILE"
   wget -nv -N -P $CONFDIR $addy >> "$LOGFILE"
done

# UNZIP FILES
GUNZPFLE="$CONFDIR/level1.gz"
for file in $GUNZPFLE; do
   echo Unzipping $file >> "$LOGFILE"
   gunzip $file >> "$LOGFILE"
done

# GENERATE MASTER LIST
CATFILE="$CONFDIR/level1"
rm -f $MASTERF
for file in $CATFILE; do
   echo Adding $file to master.p2p >> "$LOGFILE"
   cat $file >> $MASTERF
   echo Removing $file >> "$LOGFILE"
   rm -f $file
done

# RELOAD MASTER LIST
echo Reloading master.p2p >> "$LOGFILE"
kill -HUP `cat /var/run/moblock.pid` >> "$LOGFILE"

echo -n "Size of master list: " >> "$LOGFILE"
ls -lh $MASTERF | awk ' { print $5 } ' >> "$LOGFILE"

echo DONE >> "$LOGFILE"
