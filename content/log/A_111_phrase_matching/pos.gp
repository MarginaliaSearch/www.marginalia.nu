#!/usr/bin/env gnuplot

set term png
set output 'pos-abs.png'
set xlabel 'position values'
set ylabel 'counts'
set title 'Position values'
plot 'pos-abs.csv' using 1:2 with linespoints title 'count'

set output 'pos-delta.png'
set xlabel 'difference'
set ylabel 'counts'
set title 'Difference between adjacent positions'
plot 'pos-delta.csv' using 1:2 with linespoints title 'count'
