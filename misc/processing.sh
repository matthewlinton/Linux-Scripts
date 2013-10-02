#!/bin/bash
### CONFIGURATION #############################################################
### Edit these to suit your environment

JUNKDIR="/opt/"
TEMPFILE="/tmp/`date +%s`"

# Look up information in the /proc directory
PROCLIST="/proc/buddyinfo
          /proc/cpuinfo
          /proc/crypto
          /proc/interrupts
          /proc/iomem
          /proc/ioports
          /proc/kallsyms
          /proc/modules
          /proc/slabinfo"

# Fetch the page at these URLs
URLS="http://www.fark.com/"
      
# Characters
UALPHA="ABCDEFGHIJKLMNOPQRSTUVWXYZ"
LALPHA="abcdefghijklmnopqrstuvwxyz"
SPECIAL=" !@#$%^&*()_-+={}[]|\\:;\"'<>,.?/~\`"
HEXVAL="1234567890ABCDEF"


### GLOBAL VARIABLES ##########################################################

# Color Definitionsn
tcolor_black="\033[30;5;148m"
tcolor_red="\033[31;5;148m"
tcolor_green="\033[32;5;148m"
tcolor_yellow="\033[33;5;148m"
tcolor_blue="\033[34;5;148m"
tcolor_magenta="\033[35;5;148m"
tcolor_cyan="\033[36;5;148m"
tcolor_white="\033[37;5;148m"
tcolor_yellowgreen="\033[38;5;148m"
tcolor_dunno="\033[39;5;148m"

tcolor_end="\033[39m"


### HELPER FUNCTIONS ##########################################################

# ARGS : min, max
function rand_int {
   MIN=$1
   MAX=$2

   if [ $MIN -lt $MAX ]; then
      let "RANGE=($MAX - $MIN) + 1"
      let "VALUE=($RANDOM % $RANGE) + $MIN"
      echo "$VALUE"
   else
      echo "-1"
   fi
}

#ARGS : octet 1, octet 2, octet 3, octet 4
function rand_ipv4 {
    # First octet
    if [ "$1" == "" ]; then
        OCT1=`rand_int 1 254`
    else
        OCT1=$1
    fi
    
    # Second octet
    if [ "$2" == "" ]; then
        OCT2=`rand_int 1 254`
    else
        OCT2=$2
    fi
    
    # Third octet
    if [ "$3" == "" ]; then
        OCT3=`rand_int 1 254`
    else
        OCT3=$3
    fi
    
    # Fourth octet
    if [ "$4" == "" ]; then
        OCT4=`rand_int 1 254`
    else
        OCT4=$4
    fi
    
    echo "$OCT1.$OCT2.$OCT3.$OCT4"
}

# ARGS : type
function rand_char {
   TYPE=$1

   VALUE="-1"
   STRING=""

   case $TYPE in
      ALPHA)
         STRING="$UALPHA$LALPHA"
         ;;
      UALPHA)
         STRING="$UALPHA"
         ;;
      LALPHA)
         STRING="$LALPHA"
         ;;
      SPECIAL)
         STRING="$SPECIAL"
         ;;
      HEX)
         STRING="$HEXVAL"
         ;;
      ALL)
         STRING="$UALPHA$LALPHA$SPECIAL"
         ;;
      *)
         echo "Unknown string type \"$TYPE\" in rand_char"
         exit 1
   esac

   let "INDEX=${#STRING} - 1"
   echo "${STRING:`rand_int 0 $INDEX`:1}"
}

# ARGS : 
function rand_hex {
   VALUE=""
   LOOP=2
   
   while [ $LOOP -gt 0 ]; do
      VALUE=$VALUE`rand_char HEX`
      let "LOOP-=1"
   done

   echo "$VALUE"
}

# ARGS : length, seperator
function rand_hex_line {
   LENGTH=$1
   SEPERATOR="$2"
   VALUE=""

   while [ $LENGTH -gt 0 ]; do
      VALUE="$VALUE`rand_hex`"
      if [ $SEPERATOR ] && [ $LENGTH -gt 1 ]; then
         VALUE=$VALUE$SEPERATOR
      fi
      let "LENGTH--"
   done

   echo "$VALUE"
}

#ARG : string, color
function rand_colorstring {
    # TODO : allow user to select color by keyword
    STRLEN=${#1}
    BEGINCOLOR=`rand_int 0 $STRLEN`
    ENDCOLOR=`rand_int $BEGINCOLOR $STRLEN`
    
    if [ $BEGINCOLOR -lt $ENDCOLOR ]; then
       STRING1=${1:0:$BEGINCOLOR}
       STRING2=${1:$BEGINCOLOR:$ENDCOLOR - $BEGINCOLOR}
       STRING3=${1:$ENDCOLOR:$STRLEN}
        
       case `rand_int 0 10` in
          0)
             echo -e "$STRING1""$tcolor_yellowgreen""$STRING2""$tcolor_end""$STRING3"
             ;;
          1)
             echo -e "$STRING1""$tcolor_blue""$STRING2""$tcolor_end""$STRING3"
             ;;
          2)
             echo -e "$STRING1""$tcolor_black""$STRING2""$tcolor_end""$STRING3"
             ;;
          *)
             echo -e "$STRING1""$tcolor_red""$STRING2""$tcolor_end""$STRING3"
             ;;
       esac
    else
        echo "$1"    
    fi
}

# ARGS : min length, max length, min wait, max wait, 
function processing {
   LENGTH=`rand_int $1 $2`
   while [ $LENGTH -gt 0 ]; do
      echo -n "."
      let "LENGTH--"
      usleep `rand_int $2 $3`
   done
   echo "DONE"
}

# ARGS : filename, usleep min, usleep max
function output_file {
   DOBLANKLINES=$4
   MAXLINES=`rand_int 10 200`
   while read line; do
      echo $line
      if [ "$DOBLANKLINES" != "no" ]; then
          if [ `rand_int 0 4` -eq 0 ]; then
            BLANKLINES=`rand_int 1 3`
            while [ $BLANKLINES -gt 0 ]; do
                echo ""
                let "BLANKLINES--"
            done
        fi
      fi
      let "MAXLINES--"
      if [ $MAXLINES -le 0 ]; then break; fi
      usleep `rand_int $2 $3`
   done < "$1"
}

#ARGS :
function gibberish {
   FIRSTDIR=`find "$JUNKDIR" -maxdepth 1 -type d`

   for dir in $FIRSTDIR; do
      TRIP=`rand_int 0 4`
      if [ $TRIP -eq 0 ]; then
         tar -cz $dir | tr -d '\001'-'\011''\013''\014''\016'-'\037''\200'-'\377'' ''\n'
         break
      fi
   done
}


#ARGS : filename
function color_html {
   FILENAME=$1
}

### MAJOR FUNCTIONS ###########################################################

# ARGS : 
function print_rprocf {
   NUMITEMS=`echo $PROCLIST | wc -w`
   PFILE=`rand_int 1 $NUMITEMS`

   i=0
   for FILE in $PROCLIST; do
      if [ $i -eq $PFILE ]; then
         output_file "$FILE" 100000 900000
         exit 0
      fi
      let "i++"
   done
}

# ARGS : color (on)
function print_randomweb {
   NUMITEMS=`echo $URLS | wc -w`
   PFILE=`rand_int 1 $NUMITEMS`

   for FILE in $URLS; do
      if [ $PFILE -le 1 ]; then
         curl "$FILE" > "$TEMPFILE"
         output_file "$TEMPFILE" 0 500000 "no"
         exit 0
      fi
      let "PFILE--"
   done
   rm -f "$TEMPFILE"
}

# ARGS : color (on)
function print_hexdump {
   ISCOLOR="$1"
   COLORBEGIN=0
   COLOREND=0
   NUMBERING=`rand_int 0 1`
   RANDLINES=`rand_int 0 1`
   NUMLINES=`rand_int 10 100`
   NUMCOLS=`rand_int 8 32`
   LINENUM=10
   SEPERATORLIST=":-. "
   SEPERATOR=""
   
   let "INDEX=${#SEPERATORLIST} - 1"
   SEPERATOR=${SEPERATORLIST:`rand_int 0 $INDEX`:1}

   while [ $NUMLINES -gt 0 ]; do
   
      if [ $NUMBERING -gt 0 ]; then
          if [ "$ISCOLOR" == "on" ]; then
              echo -ne "$tcolor_end""[""$tcolor_green""$LINENUM""$tcolor_end""]:\t"
          else
              echo -ne "[$LINENUM] :\t"
          fi
      fi
      
      if [ $RANDLINES -gt 0 ]; then
          NUMCOLS=`rand_int 4 32`
         
      fi
      
      if [ "$ISCOLOR" == "on" ]; then
          rand_colorstring `rand_hex_line $NUMCOLS $SEPERATOR`
      else
          rand_hex_line $NUMCOLS $SEPERATOR
      fi
      
      let "NUMLINES--"
      let "LINENUM+=10"
   done
   
   if [ "$ISCOLOR" == "on" ]; then
       echo -ne "$tcolor_end"
   fi
}

#ARGS : 
function verify_binaries {
   BINLOCATIONS=`echo $PATH | sed -e "s/:/\n/g"`
   NUMITEMS=`echo $BINLOCATIONS | wc -w`
   ITEMNUM=`rand_int 1 $NUMITEMS`
   FILENUM=`rand_int 5 100`

   i=0
   for DIR in $BINLOCATIONS; do
      if [ $i -eq $ITEMNUM ]; then
         BINLIST=`ls -1 $DIR`
         for FILE in $BINLIST; do
            echo -en "$tcolor_cyan""Verifying""$tcolor_end" "`basename $FILE` : "
            file -b "$DIR/$FILE"
            let "FILENUM--"
            if [ $FILENUM -lt 0 ]; then break; fi
            usleep `rand_int 100000 900000`
         done
      fi
      let "i++"
   done
}

#ARGS
function rand_ping {
   IPADDY=`rand_ipv4 13 121 181`
   NUMPING=`rand_int 1 4`

   ping -DRnv -c $NUMPING $IPADDY &
}


#ARGS :
function rand_process {
   NUMPROC=`rand_int 3 20`
   
   LOOP=0
   while [ $LOOP -lt $NUMPROC ]; do
      PROCESSLIST=`ps aux | awk 'BEGIN { FS = " " } {if (NR!=1) { print $2 }}'`
      NUMPROCESS=`echo "$PROCESSLIST" | wc -l`

      let "SELECTED = `rand_int 1 $NUMPROCESS`"

      SHOWPID=`echo "$PROCESSLIST" | awk -v sl=$SELECTED 'BEGIN { FS = " " } { if ( NR == sl ) print $0 }'`

      ps -F $SHOWPID | awk '{if ( NR != 1 ) printf( "\033[32;5;148m%-6s%-6s\033[39m%s\n", $2, $3, $12) }'
      
      let "LOOP+=1"
   done
}

### BEGIN #####################################################################

# Take command line arguments


# begin main loop
while [ 1 ]; do
   case `rand_int 0 5` in
   #case 2 in
      0)
         (print_rprocf)
         ;;
      1)
         (print_randomweb)
         ;;
      2)
          if [ `rand_int 0 1` -eq 0 ]; then
                (print_hexdump)
          else
                (print_hexdump "on")
          fi
         ;;
      3)
         (verify_binaries)
         ;;
      4)
         (rand_ping)
	 ;;
      5)
         (rand_process)
         ;;
      *)
         echo "Whoops!!"
         exit 1
   esac
   sleep 1
done
