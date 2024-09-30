#!/usr/bin/env gnuplot

set term png
set output 'poslistlength.png'
set xlabel 'position list length (truncated at 512)'
set ylabel 'count'
set logscale y 10
set logscale x 10
set title 'Position list length frequency, sample of 1M documents'
plot 'poslistlength.csv' using 1:2 with linespoints title 'count'
