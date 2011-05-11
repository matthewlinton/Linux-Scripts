mencoder mf://*.jpg -mf w=320:h=240:fps=8:type=jpg -ovc lavc \
    -lavcopts vcodec=mpeg4:mbd=2:trell -oac copy -o output.avi
