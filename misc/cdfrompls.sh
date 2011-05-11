#!/bin/sh
# cdfrompls
# VER: 1.5-2005.05.23
# AUTHOR: Matthew Linton
# E_MAIL: Matthew.Linton+cdfrompls@gmail.com
# This script is designed to create CDs from playlists (.pls or .m3u)
# REQUIRES: cdrtools v2.0 or later
#           lame v3.96 or later
# USAGE:  cdfrompls <-f|--file playlist> [args]
# ARGS:
#    --appid <appid>         mkisofs application ID
#                            (see mkisofs manpage for more info)
#    -a, --audio             Create a normal audio CD rather than an MP3 CD
#                            NOTE: When creating an audio CD no ISO is created
#                            therefore the options --isofile, -ni/--noiso have
#                            no effect.
#    -b, --blank <method>    cdrecord blank rewritable CD -b uses default "all"
#                            (Default assumes non rewriteable CD)
#                            (see cdrecord manpage for more info)
#    -c, --coppy             Just copy the files to the specified location.
#                            (Usefull for copying files over to a USB mp3 player)
#    --creator <name>        mkisofs creator name
#                            (see mkisofs manpage for more info)
#    --cdname <name>         mkisofs CD name
#                            (see mkisofs manpage for more info)
#    --cmdfile <path/file>   Before actualy moving the mp3s to a temp dirctory
#                            cdfrompls creates a file with mv commands.
#                            Specify an alternate command file with this arg.
#    --dummy                 tells cdrecord to preform a test run
#                            (see cdrecord manpage for more information)
#    --driveropts <opts>     Listing of driver options for cdrecord in a comma
#                            seperated quoted list.
#                            eg. --driveropts "burnfree,hidecdr,singlesession"
#                            (see cdrecord manpage for more info)
#    --eject                 Eject CD when done burning
#    -f, --file <filename>   The path & filename for the playlist
#                            this argument is manditory
#    -h, --help              Print out this help section
#    -i, --iso               Just create an ISO, don't burn (assumes -nb)
#    --isofile <name>        Specify the name of the ISO file
#    -nb, --noburn           Do not burn the CD. (Usefull if you don't have
#                            permissions to burn CDs)
#    -ni, --noiso            Do not Create an ISO (assumes -nb)
#    -nx, --noexecute        Do not execute the command file
#                            (assumes -nb, -ni, and -s)
#    --publisher <name>      mkisofs publisher name
#                            (see mkisofs manpage for more info)
#    -s, --save              Save all temp files
#    --size <size>           Size of CD im MB
#    --sleeptime <sec>       Specify the number of sec to sleep between ops.
#    --speed <speed>         Manualy set burn speed for cdrecord
#    --targetdir <dir>       Specify the target directory to copy the mp3s to.
#    --targetdev <device>    Target device for cdrecord
#                            (see cdrecord manpage for more info)
#    -v, --version           Version information
#
# EXIT CODES:
#    0  cdfrompls has completed successfully
#    1  playlist file not found
#    2  -f|--file argument not included
#    3  files being copied exceed max CD size
#    
###############################################################################
# TODO: can't handle single quotes in filenames
# TODO: needs to have more options for cd structure, IE directory sorting, etc
###############################################################################
# COPYRIGHT: Copyright (c) 2005 Matthew Linton
#            This program is free software; you can redistribute it and/or
#            modify it under the terms of the GNU General Public License
#            as published by the Free Software Foundation; either version 2
#            of the License, or (at your option) any later version.
#
#            This program is distributed in the hope that it will be useful,
#            but WITHOUT ANY WARRANTY; without even the implied warranty of
#            MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#            GNU General Public License for more details.
###############################################################################

# SETUP DEFAULT OPTIONS  (you may want or need to change some of these)
APPID="cdfrompls"                # mkisofs app ID
CDNAME="Travel"                  # mkisofs CD name
CREATOR="cdfrompls"                # mkisofs preparer
PUBLISHER="cdfrompls"              # mkisofs publisher

DRVOPTS="burnfree,hidecdr"       # cdrecord -driveropts= option
EJECT=0                          # cdrecord -eject option
SPEED=0                          # cdrecord speed= option (0 denotes default drive speed)
TARGETDEV=ATAPI:0,0,0            # cdrecord device= option

CMDFILE=travel.cmd               # temp file for copy command
ISOFILE=travel.iso               # name of the ISO file
PLAYLIST=""                      # path & filename of the playlist
SLEEPTIME=3                      # time in seconds  to rest between operations
TARGETDIR=./travel               # folder to copy files to

AUDIO=0                          # do (1) ir don't (0) create audio CD
BLANK=0                          # do (1) or don't (0) blank the CD
BMETH="all"                      # blanking method for cdrecord
BURN=1                           # do (1) or don't (0) burn the ISO
CDSIZE=700                       # size of CD in MB
CLEANISO=1                       # do (1) or don't (0) remove the ISO
CLEANTARGET=1                    # do (1) or don't (0) remove the Target Dir
CLEANCMD=1                       # do (1) or don't (0) remove the Command file
DUMMY=0                          # do (1) or don't (0) test burn a CD
EXECUTE=1                        # do (1) or don't (0) execute the command file
MKISO=1                          # do (1) or don't (0) create the ISO
MP3SIZE=0                        # size of the MP3 files

# GRAB COMMANDLINE ARGUMENTS
until [ -z "$1" ]
do
   case "$1" in
     --appid)
        shift
        APPID=$1
	;;
     -a|--audio)
        AUDIO=1
	;;
     -b)
        BLANK=1
	;;
     --blank)
        shift
	BMETH=$1
        BLANK=1
        ;;
     -c|--copy)
        MKISO=0
	CLEANTARGET=0
	;;
     --creator)
        shift
        CREATOR=$1
        ;;
     --cdname)
        shift
        CDNAME=$1
        ;;
     --cmdfile)
        shift
        CMDFILE=$1
        ;;
     --dummy)
        DUMMY=1
	;;
     --driveropts)
        shift
        DRVOPTS=$1
        ;;
     --eject)
        EJECT=1
	;;
     -f|--file)
        shift
        PLAYLIST="$1"
        if [ ! -e "$PLAYLIST" ]; then
           echo "File $1 not found"
           exit 1
        fi
        ;;
     -h|--help)
        echo
        head -n 72 ./cdfrompls* | tail -n 71
	echo
	exit 0
        ;;
     -i|--iso)
        BURN=0
	CLEANISO=0
	;;
     --isofile)
        shift
        ISOFILE=$1
	;;
     -nb|--noburn)
        BURN=0
	CLEANISO=0
	;;
     -ni|--noiso)
        BURN=0
	MKISO=0
	CLEANISO=0
	;;
     -nx|--noexecute)
        BURN=0
	MKISO=0
	CLEANISO=0
	EXECUTE=0
	CLEANCMD=0
	CLEANTARGET=0
	;;
     --publisher)
        shift
	PUBLISHER=$1
	;;
     -s|--save)
        CLEANISO=0
	CLEANCMD=0
	CLEANTARGET=0
	;;
     --size)
        shift
        CDSIZE=$1
	;;
     --sleeptime)
        shift
        SLEEPTIME=$1
	;;
     --speed)
        shift
	SPEED=$1
	;;
     --targetdir)
        shift
	TARGETDIR=$1
	;;
     --targetdev)
        shift
	TARGETDEV=$1
	;;
     -v|--version)
        echo
        head -n 6 ./cdfrompls* | tail -n 5
        echo
        exit 0
        ;;
   esac
   shift
done

# MAKE SURE MANDITORY ARGS HAVE BEEN SET
if [ "$PLAYLIST" = "" ]; then
   echo "$PLAYLIST"
   echo "Playlist has not been selected"
   echo "cdfrompls cannot continue"
   echo "try \"cdfrompls -h\" for help"
   echo
   exit 2
fi

# CLEANUP ANY LEFTOVER FILES FROM THE LAST RUN
if [ -a "$CMDFILE" ]; then
   echo "Removing previous $CMDFILE"
   rm -f $CMDFILE
fi
if [ -d "$TARGETDIR" ]; then
   echo "Removing target dir $TARGETDIR"
   rm -rf $TARGETDIR
fi
if [ -a "$ISOFILE" ]; then
   echo "Removing ISO file $ISOFILE"
   rm -f $ISOFILE
fi

# CREATE THE COMMAND FILE TO COPY OVER THE MP#s
awk -v cmdfile="$CMDFILE" -v targetdir="$TARGETDIR" '
  BEGIN { FS="=" }
  BEGIN { x=1 }
  # find entries in a .pls file
  /^[Ff]ile/ { printf "cp -vf \"%s\" \"%s/%08d.mp3\"\n", $2, targetdir, x++ >> cmdfile  }
  # find entries in a .m3u file
  /^\// && /.mp3$/ { printf "cp -vf \"%s\" \"%s/%08d.mp3\"\n", $0, targetdir, x++ >> cmdfile }
' "$PLAYLIST"

# if not specified otherwise, execute the command file
if [ $EXECUTE -eq 1 ]; then
   echo "Copying and renaming Files to $TARGETDIR"
   mkdir $TARGETDIR
   sh $CMDFILE
   sleep $SLEEPTIME
else
  echo
  echo "Skipping execution of $CMDFILE"
  echo
fi

# IF SPECIFIED BLANK THE CD
if [ $BLANK -eq 1 ]; then
   echo "Blanking rewriteable CDrom on device $TARGETDEV"
   cdrecord dev=$TARGETDEV -blank=$BMETH
   sleep $SLEEPTIME
fi

# IF SPECIFIED CONVERT MP3S TO WAV FILES
if [ $AUDIO -eq 1 ]; then
   echo "Converting MP3s to WAVs"
   find $TARGETDIR -iname *.mp3 -exec lame --decode -s 44.1 {} {}.wav \;
   echo "Removing MP3 files"
   rm -vf $TARGETDIR/*.mp3
fi

# CHECK THE SIZE OF THE FILES
MP3SIZE=`du -cm  $TARGETDIR | grep total | awk ' { printf "%s", $1 } '`
if [ $MP3SIZE -gt $CDSIZE ]; then
   echo
   echo "Size of files trying to be burnt to CD is larger than size of CD"
   echo "Size of CD: $CDSIZE"
   echo "Size of files: $MP3SIZE"
   echo "Try removing some MP3s from your playlist"
   echo
   exit 3
fi

# IF SPECIFIED CREATE AUDIO CD ELSE CREATE AN MP3 CD
if [ $AUDIO -eq 1 ]; then  
   if [ $BURN -eq 1 ]; then
      echo "Recording CD to device $TARGETDEV"
      cdrecord dev=$TARGETDEV gracetime=$SLEEPTIME -audio -pad `
         [ $SPEED != 0 ] && echo -n "speed=$SPEED" || echo -n ""` `
         [ $EJECT -eq 1 ] && echo -n "-eject" || echo -n ""` `
         [ -z $DRVOPTS ] && echo -n "" || echo -n "-driveropts=$DRVOPTS"` `
         [ $DUMMY -eq 1 ] && echo -n "-dummy" || echo -n ""` $TARGETDIR/*.wav
      sleep $SLEEPTIME
   else
      echo
      echo "Skipping burning process for Audio CD"
      echo
   fi
else
   # CREATE THE ISO
   if [ $MKISO -eq 1 ]; then
      echo "Creating ISO $ISOFILE"
      mkisofs -A $APPID -p $CREATOR -P $PUBLISHER -V $CDNAME -o $ISOFILE $TARGETDIR
      sleep $SLEEPTIME
   else
      echo
      echo "Skipping creating the ISO image $ISOFILE"
      echo
   fi

   # RECORD THE ISO
   if [ $BURN -eq 1 ]; then
      echo "Recording CD to device $TARGETDEV $DRVOPTS"
      cdrecord dev=$TARGETDEV gracetime=$SLEEPTIME `
         [ $SPEED != 0 ] && echo -n "speed=$SPEED" || echo -n ""` `
         [ $EJECT -eq 1 ] && echo -n "-eject" || echo -n ""` `
         [ -z $DRVOPTS ] && echo -n "" || echo -n "-driveropts=$DRVOPTS"` `
         [ $DUMMY -eq 1 ] && echo -n "-dummy" || echo -n ""` $ISOFILE
      sleep $SLEEPTIME
   else
      echo
      echo "Skipping burning process for MP3 CD"
      echo
   fi
fi

# REMOVE TEMP FILES AND DIRECTORIES
[ "$CLEANCMD" -eq 1 ] && rm -vf $CMDFILE || echo "Leaving $CMDFILE"
[ "$CLEANTARGET" -eq 1 ] && rm -rvf $TARGETDIR || echo "Leaving $TARGETDIR"
[ "$CLEANISO" -eq 1 ] && rm -vf $ISOFILE || echo "Leaving $ISOFILE"

echo "Done"

exit 0
