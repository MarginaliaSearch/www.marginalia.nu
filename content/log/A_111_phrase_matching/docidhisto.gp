#!/usr/bin/env gnuplot

set term png
set output 'docidhisto.png'
set xlabel 'log_2 difference between subsequent ids'
set ylabel 'count'
set title 'distribution of document ids from a sample of 1,000,000 document lists in prod'
plot 'docidhisto.csv' using 1:2 with boxes title 'count'
