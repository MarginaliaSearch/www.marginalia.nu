set term png
set style fill solid
set boxwidth 0.6
set grid

set output 'linespaces.png'
set title 'Line spacing, page 5 of The Role of Knowledge'
set xlabel 'Line spacing'
set ylabel 'Lines'

plot "data/linespacesp5.dat" using 1:2 \
      title "Line spacing, page 5" \
      with boxes \
      linecolor rgb "#000000"
