#!/usr/bin/env gnuplot

set term png
set style fill solid
set boxwidth 0.1
set grid

set output 'fontsizes.png'
set xrange [5:20]
set xtics 5, 1, 20

set xlabel 'Font size'
set ylabel 'Characters'

set title 'Font size distribution in Can Education Be Standardized?'

set logscale y 10

plot "data/fontsizes.dat" using 1:2 \
      title "Page 1" \
      with boxes \
      linecolor rgb "#FF0000", \
      "data/fontsizes.dat" using ($1+0.2):3 \
      title "Page 9" \
      with boxes \
      linecolor rgb "#006060", \
      "data/fontsizes.dat" using ($1+0.4):4 \
      title "Page 10" \
      with boxes \
      linecolor rgb "#008000"
