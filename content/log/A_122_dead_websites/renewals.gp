#!/usr/bin/env gnuplot

set term png enhanced
set grid

set xrange [-1:52]
set yrange [0:2200]
set xtics 0,2,52

set xlabel 'Weeks until certificate expiry'
set ylabel 'Fingerprint changes'

set title "Certificate Changes"

set style line 1 lt 1 lc rgb '#800080'
set style line 2 lt 1 lc rgb '#008080'
set style line 3 lt 1 lc rgb '#808000'
set style line 4 lt 1 lc rgb '#F00000'
set style line 5 lt 1 lc rgb '#0000F0'

set output 'renewals.png'

plot "data/sec_weekly.dat" using 1:2 \
      with lines \
      ls 1 \
      title 'ASN', \
      "data/sec_weekly.dat" using 1:5 \
      with lines \
      ls 2 \
      title 'Cert Fingerpint', \
      "data/sec_weekly.dat" using 1:3 \
      with lines \
      ls 3 \
      title 'IP', \
      "data/sec_weekly.dat" using 1:11 \
      with lines \
      ls 4 \
      title 'Software'


set output 'renewals_headers_fp.png'
set xrange [-1:36]
set yrange [0:100]

set title 'Fingerprint changes, where cert fingerprint and security headers have changed'
plot "data/sec_weekly_headers_fp.dat" using 1:2 \
      with lines \
      ls 1 \
      title 'ASN', \
      "data/sec_weekly_headers_fp.dat" using 1:5 \
      with lines \
      ls 2 \
      title 'Cert Fingerpint, Security Headers', \
      "data/sec_weekly_headers_fp.dat" using 1:3 \
      with lines \
      ls 3 \
      title 'IP', \
      "data/sec_weekly_headers_fp.dat" using 1:6 \
      with lines \
      ls 4 \
      title 'Cert SAN', \
      "data/sec_weekly_headers_fp.dat" using 1:11 \
      with lines \
      ls 5 \
      title 'Software'


