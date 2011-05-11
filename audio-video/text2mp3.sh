#!/bin/sh
#  text2mp3 - uses festival's text2wave and LAME to create an MP3 from a text file
#  USAGE: text2mp3 <text file>
################################################################################

echo Encoding wave from text file
text2wave $1 -o $1.wav
echo DONE
echo Encoding wave to MP3
lame $1.wav $1.mp3
echo DONE
rm $1.wav
