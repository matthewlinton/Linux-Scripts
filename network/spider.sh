#!/bin/sh
# spider.sh - uses wget to slowly surf through websites. Spider.sh will
# launch one process per entry in the target list.

BINWGET=`which wget 2> /dev/null`

TARGETLIST="http://digg.com/
            http://www.fark.com/
            http://www.reddit.com/
            http://www.i-am-bored.com/
            http://www.stumbleupon.com/"
DEPTH=32
RETRIES=3
WAIT=10
RATELIMIT="30k"
USERAGENT="Squid Prefetch 1.0"
PAUSE=2
TEMP="/tmp"

for url in $TARGETLIST; do
   $BINWGET -b -q -r -H -np -P -l $DEPTH -t $RETRIES -w $WAIT --random-wait \
   --limit-rate=$RATELIMIT -P "$TEMP/spider.$RANDOM" \
   -o "$TEMP/spider-$RANDOM.log" -U "$USERAGENT" $url
   sleep $PAUSE
done
