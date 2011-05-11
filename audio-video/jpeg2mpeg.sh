#!/bin/sh
# jpeg2mpeg - converts a jpeg and optional mpeg2 audio file to an mpeg2 video.
# USAGE:  jpeg2mpeg -j <JPEG> -o <OUTFILE> [Options]

JPEGIN=""
AUDIOIN=""
VIDEOOUT=""
FPS=25
NFRAMES=25

until [ -z "$1" ]
do
	case "$1" in
		-a|--audio)		# Audio File
			shift
			AUDIOIN="$1"
			;;
		-n|--number)		# Number of frames
			shift
			NFRAMES="$1"
			;;
		-f|--fps)		# Frames per second
			shift
			FPS="$1"
			;;
		-j|--jpeg)		# Jpeg File
			shift
			JPEGIN="$1"
			;;
		-o|--outfile)		# Output file (Basename)
			shift
			VIDEOOUT="$1"
			;;
	esac
	shift
done

jpeg2yuv -n $NFRAMES -I p -f $FPS -j $JPEGIN | \
mpeg2enc -n p -f 8 -o $VIDEOOUT.m2v

if [ ! $AUDIOIN == "" ]; then
	mplex -f 8 -o /dev/stdout $VIDEOOUT.m2v $AUDIOIN > $VIDEOOUT.mpg
	rm -v $VIDEOOUT.m2v
fi
