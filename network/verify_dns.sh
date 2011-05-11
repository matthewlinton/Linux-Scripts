#!/bin/sh
# verify_dns
# This runs dns queries using the default dns servers for the system and checks
# them against opendns (http://www.opendns.com/).  mismatched results are
# logged.
#
# USAGE:   verify_dns.sh [domain_list_file] <options>
# OPTIONS:
#    -l, --log <file>		File to log to (default "verifydns.log")

BINDIG=`which dig 2>/dev/null`
BINGREP=`which grep 2>/dev/null`
BINSED=`which sed 2>/dev/null`
BINDATE=`which date 2>/dev/null`

TEMPFILE="/tmp/verifydns-`$BINDATE +%F`"
LOGFILE="verifydns.log"

# opendns servers. (This may change over time.)
OPENDNS="208.67.222.222 208.67.220.220"

# GRAB DOMAIN LIST FILE (has to be the first argument)
DOMAINLIST="$1"
shift

# GRAB THE REST OF THE ARGS
until [ -z "$1" ]; do
   case "$1" in
   -l|--log)
      shift
      LOGFILE="$1"
      ;;
   esac
   shift
done
for domain in $(cat $DOMAINLIST); do
   # check default dns
   $BINDIG $domain > "$TEMPFILE"

   # check opendns
   for server in $OPENDNS; do
      $BINDIG @$server $domain
   done
done
