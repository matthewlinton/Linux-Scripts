#!/bin/sh
# randhex
# print out random hex pairs

# Defaults
COMMAND=`basename $0`
VERSION="1.0"
RATE="0.2s"
LIMIT=0
LOOP=1
LENGTH=2
SEPERATOR=" "
PREFIX="0x"
MPREFIX=""
MSUFFIX=""

# Commandline args
until [ -z "$1" ]; do
   case "$1" in
   -l|--length)
      shift
      LENGTH="$1"
      ;;
   -n|--number)
      shift
      LIMIT="$1"
      ;;
   -o|--loop)
      shift
      LOOP="$1"
      ;;
   -p|--prefix)
      shift
      PREFIX="$1"
      ;;
   -P|--mprefix)
      shift
      MPREFIX="$1"
      ;;
   -r|--rate)
      shift
      RATE="$1"
      ;;
   -s|--seperator)
      shift
      SEPERATOR="$1"
      ;;
   -S|--suffix)
      shift
      MSUFFIX="$1"
      ;;
   -h|--help)
      # print help information
      echo
      echo "$COMMAND v$VERSION"
      echo "$COMMAND generates a string of random hex pairs"
      echo "USAGE: $COMMAND [options] [preset]"
      echo
      echo "OPTIONS:"
      echo "-l, --length=NUM	Length of each hex value in characters"
      echo "-n, --number=NUM	Adjust the number of hex values generated"
      echo "-o, --loop=NUM	Run the command x number of times"
      echo "-p, --prefix=STR	Prefix for each hex value"
      echo "-P, --mprefix=STR	Prefix each run with STR"
      echo "-r, --rate=NUM	Slow down the output by NUM. See sleep"
      echo "-s, --seperator=STR	Seperator between hex values"
      echo "-S, --suffix=STR	Suffix each run with STR"
      echo "-h, --help		This inforamtion"
      echo
      echo "The optional preset argument can be any of the following."
      echo "Arguments given after the preset option overide defaults"
      echo "MAC		Standard MAC address seperated by colins"
      echo "WEP64	64bit WEP key"
      echo "WEP128	128bit WEP key"
      exit 0
      ;;
   MAC)
      RATE=0
      LIMIT=6
      LENGTH=2
      SEPERATOR=":"
      PREFIX=""
      ;;
   WEP64)
      RATE=0
      LIMIT=5
      LENGTH=2
      SEPERATOR=" "
      PREFIX=""
      ;;
   WEP128)
      RATE=0
      LIMIT=13
      LENGTH=2
      SEPERATOR=" "
      PREFIX=""
      ;;
   *)
      echo "Unknown option $1"
      exit 1
      ;;
   esac
   shift
done

while [ $LOOP -gt 0 ]; do
   hexcount=0
   wedone=0
   echo -n "$MPREFIX"
   while [ $wedone -eq 0 ]; do
      # Generate random hex value based on length
      i=$LENGTH
      result=""
      while [ $i -gt 0 ]; do
         let "rintval = $RANDOM % 16"
         rhexval=`echo "obase=16; $rintval" | bc`
         result=$result$rhexval
         let "i -= 1"
      done

      # Print (This has been broken up for clarity)
      echo -n "$PREFIX"
      echo -n "$result"
      let "hexcount += 1"
      if [ $LIMIT -eq 0 ] || [ $hexcount -lt $LIMIT ]; then
         echo -n "$SEPERATOR"
      fi

      # Are we done?
      if [ $LIMIT -ne 0 ] && [ $hexcount -ge $LIMIT ]; then
         wedone=1
      fi

      sleep $RATE
   done
   echo "$MSUFFIX"
   let "LOOP -= 1"
done
