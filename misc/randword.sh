#!/bin/sh
# randword
# print out random words, requires aspell
DEBUG=0

# Get location of commands
BINAWK=`which awk`
BINASPELL=`which aspell`
BINFESTIVAL=""			# By default we don't want to use festival

# Check for necessary commands
if [ ! -x "$BINAWK" ]; then exit 1; fi
if [ ! -x "$BINASPELL" ]; then exit 1; fi

# Defaults
COMMAND=`basename $0`
VERSION="1.0"
STRLEN=10
MINLEN=3
RATE="0.2s"
DURATION="0.5"
LIMIT=0
LIST="abcdefghijklmnopqrstuvwxyz"

# Commandline args
until [ -z "$1" ]; do
   case "$1" in
   -d|--debug)
      DEBUG=1
      ;;
   -l|--strlen)
      shift
      STRLEN="$1"
      ;;
   -m|--minlen)
      shift
      MINLEN="$1"
      ;;
   -n|--number)
      shift
      LIMIT="$1"
      ;;
   -r|--rate)
      shift
      $RATE="$1"
      ;;
   -s|--speak)
      shift
      BINFESTIVAL=`which festival`
      ;;
   -h|--help)
      # print help information
      echo
      echo "$COMMAND v$VERSION"
      echo "$COMMAND generates a list of random words"
      echo "USAGE: $COMMAND [options]"
      echo
      echo "OPTIONS:"
      echo "-d, --debug		Print out extra debugging information"
      echo "-l, --strlen=NUM	Limit the maximum string length"
      echo "-m, --minlen=NUM	Limit the minimum string length"
      echo "-n, --number=NUM	limit the number of words generated to NUM"
      echo "-r, --rate=NUM	Slow down the output by NUM. See sleep"
      echo "-s, --speak		speak the words using festival"
      echo "-h, --help		This inforamtion"
      echo
      exit 0
      ;;
   *)
      echo "Unknown option $1"
      exit 1
      ;;
   esac
   shift
done

# Verify input
if [ $STRLEN -lt $MINLEN ]; then
   echo "Minimum string length cannot be longer than maximum" 1>&2
   echo "Minimum: $MINLEN" 1>&2
   echo "Maximum: $STRLEN" 1>&2
fi

# Configure festival
# (Parameter.set 'Duration_Stretch 1.2)

echo "Generating wordlist..." 1>&2

listlen=${#LIST}

wordcount=0
while [ 1 ]; do
   let "i = ($RANDOM % $STRLEN) + 1"
   if [ $i -ge $MINLEN ]; then
      if [ $DEBUG -eq 1 ]; then echo -n "$i:" 1>&2; fi
      # generate random string
      strout=""
      while [ $i -gt 0 ]; do
         num=$RANDOM
         let "num %= $listlen"
         strout=$strout${LIST:$num:1}
         let "i -= 1"
      done
      if [ $DEBUG -eq 1 ]; then echo -n "$strout:" 1>&2; fi

      # attempt to create a word from the random string
      result=`echo $strout | $BINASPELL pipe | \
      $BINAWK ' 
         BEGIN { FS="," }
         /&/ {
            gsub(/:/, ",")
            gsub(/ / , "")
            printf $2 " "
         }
      '`

      # Output word
      if [ "$result" != "" ]; then
         echo -n "$result"
         if [ "$BINFESTIVAL" != "" ]; then
      	    echo "$result" | $BINFESTIVAL --tts
         fi
         let "wordcount += 1"
      else
         if [ $DEBUG -eq 1 ]; then echo -n "------" 1>&2; fi
      fi

      if [ $DEBUG -eq 1 ]; then echo "" 1>&2 ; fi

      # Are we done?
      if [ $LIMIT -ne 0 ] && [ $wordcount -ge $LIMIT ]; then
         echo 1>&2
         echo "DONE" 1>&2
         exit 0
      fi
      sleep $RATE
   fi
done
