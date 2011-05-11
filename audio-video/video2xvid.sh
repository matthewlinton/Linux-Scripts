#!/bin/bash
# video2xvid
# Version 1.0
# Description: convert any video type to xvid/mp3 .avi
# Usage: video2xvid -i infile -o outfile <options>
# Options:
#     -h, --help                   Print this help section
#     -i, --infile <file>          Input video file
#     -o, --outfile <basename>     Output file base name (without .avi)
#     -v, --version                Print the version number

INFILE=""
OUTFILE=""
ACODEC="mp3lame"
ABITRATE=128
VBITRATE=1200
PASS=2

until [ -z "$1" ]
do
   case "$1" in
       -h|--help)
         echo
         head -n 14 ./video2xvid | tail -n 13
         echo 
         exit 0
         ;;
      -i|--infile)
         shift
	 INFILE=$1
	 ;;
      -o|--outfile)
         shift
	 OUTFILE=$1
	 ;;
      -v|--version)
         echo
         head -n 4 ./video2xvid | tail -n 3
         echo
         exit 0
         ;;
   esac
   shift
done

if [ "$INFILE" == "" ]; then
   echo "An input file has not been specified"
   echo "video2xvid cannot continue"
   echo "see \"video2xvid -h\" for more information"
   exit 1
fi

if [ "$OUTFILE" == "" ]; then
   echo "No outfile specified"
   echo "video2xvid cannot continue"
   echo "see \"video2xvid -h\" for more information"
   exit 1
fi

echo "Encoding $INFILE to $OUTFILE"

mencoder "$INFILE" -ovc xvid \
-xvidencopts pass=$PASS:bitrate=$VBITRATE:me_quality=4 -vf pp=md \
-oac mp3lame -o "$OUTFILE"

echo "Finished Encoding"
