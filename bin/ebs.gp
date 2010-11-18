#!/usr/bin/gnuplot -persist

binwidth=5
bin(x,width)=width*floor(x/width)

# plot '/dev/shm/datafile' using (bin($1,binwidth)):(1.0) smooth freq with boxes
plot '/dev/shm/datafile' using (bin($1,binwidth)):(1.0) smooth freq with boxes
