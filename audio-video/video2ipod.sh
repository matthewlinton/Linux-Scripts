#!/bin/bash
# video2ipod
# Version 1.0
# Description: video2ipod converts video to iPod format
# Usage: video2ipod -i infile -o outfile <options>
# Options:
#     -a, --aspect <aspect>        Aspect ratio
#     -b, --buffer                 Buffer size
#     -h, --help                   Print this help section
#     -i, --infile <file>          Input video file
#     -l, --logfile <file>         logfile for 2 pass encoding
#     -o, --outfile <basename>     Output file base name (without .mp4)
#     -p, --pass <1|2>             Number of passes for encoding
#     -s, --size <HxV>             Screen size
#     -t, --title <string>         Title of the video
#     -v, --version                Print the version number

ABITRATE=160
ARATE=44100
ASPECT="4:3"
AUTHOR="video2ipod (ffmpeg)"
BUFFER=8192
FILEEXT="mpg"
INFILE=""
LOGFILE="/tmp/video-`date +%s`.log"
OUTFILE=""
PASS=1
TITLE=""
VBITRATE=768
VCODEC="mpeg4"
VSIZE="320x240"

until [ -z "$1" ]
do
   case "$1" in
      -a|--aspect)
         shift
	 ASPECT="$1"
	 ;;
      -b|--buffer)
         shift
	 BUFFER="$1"
	 ;;
      -h|--help)
         echo
         head -n 14 ./video2ipod | tail -n 13
         echo 
         exit 0
         ;;
      -i|--infile)
         shift
	 INFILE="$1"
         ;;
      -l|--logfile)
         shift
	 LOGFILE="$1"
	 ;;
      -o|--outfile)
         shift
	 OUTFILE="$1"
	 ;;
      -p|--pass)
         shift
	 PASS=$1
	 ;;
      -s|--size)
         shift
	 VSIZE="$1"
	 ;;
      -t|--title)
         shift
	 TITLE="$1"
	 ;;
      -v|--version)
         echo
         head -n 4 ./video2ipod | tail -n 3
         echo
         exit 0
         ;;
   esac
   shift
done

if [ "$INFILE" == "" ]; then
   echo "An input file has not been specified"
   echo "video2ipod cannot continue"
   echo "see \"video2ipod -h\" for more information"
   exit 1
fi

if [ "$OUTFILE" == "" ]; then
   echo "No outfile specified"
   echo "video2ipod cannot continue"
   echo "see \"video2ipod -h\" for more information"
   exit 1
fi

ffmpeg -i "$INFILE" -f mp4 -vcodec $VCODEC -maxrate $VBITRATE \
-minrate $VBITRATE -b $VBITRATE -qmin 3 -qmax 5 -bufsize $BUFFER -g 300 \
-acodec aac -ar $ARATE -ab $ABITRATE -s $VSIZE -aspect $ASPECT \
-author "$AUTHOR" \
`[ "$TITLE" == "" ] && echo "" || echo "-title $TITLE "` \
`[ $PASS -eq 2 ] && echo " -pass 1 -passlogfile $LOGFILE " || echo ""` \
`[ $PASS -eq 2 ] && echo " -y /dev/null " || echo "$OUTFILE.$FILEEXT"`

if [ $PASS -eq 2 ]; then
   sleep 1
   ffmpeg -i "$INFILE" -f mp4 -vcodec $VCODEC -maxrate $VBITRATE \
   -minrate $VBITRATE -b $VBITRATE -qmin 3 -qmax 5 -bufsize $BUFFER -g 300 \
   -acodec aac -ar $ARATE -ab $ABITRATE -s $VSIZE -aspect $ASPECT \
   -author "$AUTHOR" -pass 2 -passlogfile $LOGFILE \
   `[ "$TITLE" == "" ] && echo "" || echo "-title $TITLE "` \
   $OUTFILE.$FILEEXT
fi
