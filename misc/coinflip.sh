#!/bin/sh
# Generate coin flips
# change to test anon

FACES=2
ROUND=1
WAIT="0.02s"
LOGFILE="coinflip.csv"
countH=0
avgH=0
countT=0
avgT=0
total=0
scale=4

if [ "$LOGFILE" != "" ]; then
   echo "Total,Heads,%,Tails,%" > "$LOGFILE"
fi

while [ 1 ]; do
   i=$ROUND
   while [ $i -gt 0 ]; do
      num=$RANDOM
      let "num %= $FACES"
      case $num in
      0)
         let countH+=1
	 ;;
      1)
         let countT+=1
	 ;;
      esac
      let i-=1
   done
   let "total = $countH + $countT"
   avgH=`echo "scale=$scale; $countH/$total*100" | bc`
   avgT=`echo "scale=$scale; $countT/$total*100" | bc`
   echo -e -n "\r$total : Heads $countH / $avgH : tails $countT / $avgT"
   if [ "$LOGFILE" != "" ]; then
      echo "$total,$countH,$avgH,$countT,$avgT" >> "$LOGFILE"
   fi
done
