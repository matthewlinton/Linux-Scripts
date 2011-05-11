#!/bin/sh
# findwordpattern
# parse a text file looking for hidden phrases by printing every x word

# Get BIN location
BINAWK=`which awk`
BINSED=`which sed`

# Check for necessary commands
if [ ! -x "$BINAWK" ]; then exit 1; fi

# Defaults
COMMAND=`basename $0`
VERSION="0.1b"
INFILE=""
TEMPFILE="/tmp/$COMMAND.`date +%Y%m%d%H%M$S%N`.tmp"
SKIP=3
START=10

# Commandline arguments
until [ -z "$1" ]; do
   case "$1" in
   -f|--infile)
      shift
      INFILE="$1"
      ;;
   -n|--skip)
      shift
      SKIP="$1"
      ;;
   -s|--start)
      shift
      START=$1
      ;;
   -h|--help)
      echo "$COMMAND v$VERSION"
      echo "description"
      echo "USAGE: $COMMAND -f <file> [options]"
      echo "OPTIONS:"
      exit 0
      ;;
   *)
      echo "Unknown command"
      exit 1
      ;;
   esac
   shift
done

#if [ -a "$INFILE" ]; then echo "Could not Find \"$INFILE\"" && exit 1 ; fi

$BINSED -e "s/[-\*.,]*//g" \
        -e "s/^[ \t]*//g" \
        -e "s/[ \t]*$//g" \
	-e "/^$/d" \
	-e "s/$//g" \
	$INFILE > $TEMPFILE

n=0
for word in $TEMPFILE; do
   if [ $START -le 0 ]; then
      echo "START = $START"
      if [ $n -ge $SKIP ]; then
         echo "n = $n"
         echo -n "$WORD "
         n=0
      else
         let "n += 1"
      fi
   else
      let "START -= 1"
   fi
done
