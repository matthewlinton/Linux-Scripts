#!/bin/sh
# avconvert.sh
# Convert audio and video files based on various presets
# Matthew Linton (matthew.linton@gmail.com)
#
# USAGE:   avconvert.sh -i <infile> -o <outfile> [options]
# OPTIONS:
#    	-d, --debug		Enable Debugging mode
#	-i, --infile <file>	Input file to be converted
# 	-l, --logging <str>	Enable logging output to a file 
#	-o, --outfile <file>	Output file with extension
#	-h, --help		This help information

# PROGRAM DEFAULTS
NAME=`basename $0 sh`
VERSION="0.1"
VDATE="2009-03-22"

# DEFAULTS (Feel free to change these as you see fit)
DEBUG=1
CDATE=`date +%F%T`		# Current date and time used for logging
INFILE=""			# File to be converted
OUTFILE="-"			# Output file
LOGFILE=""			# If defined; will log output to file

# ********* Script starts here.  Do not edit below this line *************

# DEFINE LOCATION OF BINARIES
BINMPLAYER=`which mplayer 2> /dev/null`
BINMENCODER=`which mencoder 2> /dev/null`
BINFFMPEG=`which ffmpeg 2> /dev/null`
BINSOX=`which sox 2> /dev/null`
BINAWK=`which awk 2> /dev/null`
BINTR=`which tr 2> /dev/null`

if [ $DEBUG ]; then 
   echo "Mplayer: $BINMPLAYER" 1>&2
   echo "Mencoder: $BINMENCODER" 1>&2
fi

# MAKE SURE WE HAVE ALL THE NECESSARY BINARIES
if [ ! -x "$BINMPLAYER" ]; then echo "$NAME could not find mplayer" 1>&2 && exit 1; fi
if [ ! -x "$BINMENCODER" ]; then echo "$NAME could not find mencoder" 1>&2 && exit 1; fi

# TAKE COMMANDLINE ARGUMENTS
until [ -z "$1" ]
do
   case "$1" in
   -d|--debug)
      DEBUG=1
      ;;
   -i|--infile)
      shift
      INFILE="$1"
      ;;
   -l|--logging)
      shift
      LOGFILE="$1"
      ;;
   -o|--outfile)
      shift
      OUTFILE="$1"
      ;;
   -h|--help)
      echo
      echo "$NAME v$VERSION ($VDATE)"
      head -n 11 $NAME | tail -n 9 | sed -e "s/#[ ]*//"
      echo
      exit 0
      ;;
   esac
   shift
done

# ENSURE EVERYTHING IS READY TO GO
if [ "$INFILE" == "" ]; then
   echo "An input file has not been specified"
   echo "$NAME cannot continue"
   echo "see \"$NAME -h\" for more information"
   exit 2
fi

if [ "$OUTFILE" == "" ]; then
   echo "No outfile specified"
   echo "$NAME cannot continue"
   echo "see \"$NAME -h\" for more information"
   exit 2
fi

if [ ! -f "$INFILE" ]; then
   echo "Input file \"$INFILE\" could not be found"
   echo "$NAME cannot continue"
   echo "see \"$NAME -h\" for more information"
   exit 3
fi

# GRAB FILETYPE FROM INFILE AND OUTFILE
if [ $DEBUG ]; then echo "Input file: $INFILE" 1>&2; fi
infiletype=`echo "$INFILE" | $BINAWK -F . '{print $NF}' |\
		$BINTR "[:lower:]" "[:upper:]"`
if [ $DEBUG ]; then echo "Input file type: $infiletype" 1>&2; fi
if [ $DEBUG ]; then echo "Output file: $OUTFILE" 1>&2; fi
outfiletype=`echo "$OUTFILE" | $BINAWK -F . '{print $NF}' |\
		$BINTR "[:lower:]" "[:upper:]"`
if [ $DEBUG ]; then echo "Output file type: $outfiletype" 1>&2; fi

# BUILD COMMAND
runcommand=""
if [ "$infiletype" == "AVI" ]; then
   echo
else
   echo "$infiletype not supported"
   exit 0
fi

# RUN COMMAND
echo "Running Command:"
echo "$runcommand"
#$runcommand
echo "done"
