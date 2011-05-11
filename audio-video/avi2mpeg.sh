#!/bin/sh
# avi2mpeg - converts an AVI video to a DVD complient MPEG2 video
# USAGE: avi2mpeg -i <infile> -o <outfile> [options]

INFILE=""
OUTFILE=""
VIDASPECT="4/3"
VIDSCALE="720:480"
AUDIO="acodec=ac3:abitrate=192"

until [ -z "$1" ]
do
        case "$1" in
		-a|--audio)
			shift
			case "$1" in
			ac3|AC3)
			AUDIO="acodec=ac3:abitrate=192"
			;;
			mp2|MP2|mpeg2|MPEG2)
			AUDIO="acodec=mp2:abitrate=192"
			esac
			;;
		-i|--infile)
			shift
			INFILE="$1"
			;;
		-o|--outfile)
			shift
			OUTFILE="$1"
			;;
		--vidaspect)
			shift
			VIDASPECT="$1"
			;;
		--vidscale)
			shift
			VIDSCALE="$1"
			;;
	esac
	shift
done

LAVCOPTS="vcodec=mpeg2video:vrc_buf_size=1835:vrc_maxrate=9800:vbitrate=5000:keyint=18:vstrict=0:$AUDIO:aspect=$VIDASPECT"

mencoder -oac lavc -ovc lavc -of mpeg -mpegopts format=dvd:tsaf \
-vf scale=$VIDSCALE,harddup -srate 48000 -af lavcresample=48000 \
-lavcopts $LAVCOPTS -ofps 30000/1001 -o "$OUTFILE.mpg" "$INFILE"
