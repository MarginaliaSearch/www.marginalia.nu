#!/usr/bin/env gnuplot

set term png
set output 'bitsizes.png'
set xlabel 'bits in input'
set ylabel 'bits in output'
set title 'Size of encoded output, smaller y-value is better'
plot 'bitsizes.csv' using 1:2 with linespoints title 'elias gamma',\
     'bitsizes.csv' using 1:3 with linespoints title 'varint'


set output 'bitsizes2.png'
plot 'bitsizes2.csv' using 1:2 with linespoints title 'varint',\
     'bitsizes2.csv' using 1:3 with linespoints title 'gamma',\
     'bitsizes2.csv' using 1:4 with linespoints title 'delta'
