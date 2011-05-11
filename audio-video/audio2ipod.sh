#!/bin/bash
# audio2m4b
# Version 1.0
# Description: audio2m4b
# Usage: audio2m4b -i infile.avi <options>
# Options:
#     -h, --help                   Print this help section
#     -i, --infile <file>          Input video file
#     -o, --outfile <basename>     Output file base name (without .mp4)
#     -v, --version                Print the version number

ABITRATE=32
ARATE=4410
AUTHOR="audio2ipod"
BUFFER=8192
FILEEXT="m4b"
INFILE=""
LOGFILE="/tmp/audio-`date +%s`.log"
OUTFILE=""
FILETYPE="MP3"

until [ -z "$1" ]
do
   case "$1" in
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
      -o|--outfile)
         shift
	 OUTFILE="$1"
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
   echo "No outfile specified, using infile"
   OUTFILE=`echo "$INFILE"`
   echo "$OUTFILE"
fi

if [ "$FILETYPE" == "MP3" ]; then
   echo "Converting MP3 to WAV"
   lame --decode "$INFILE" tempfile.wav
   echo "Converting WAV to M4B"
   faac -w -o temp.m4b $OUTFILE.m4b
   echo "Removing WAV"
fi
