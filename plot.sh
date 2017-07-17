gnuplot <<EOF
set terminal x11
set xdata time
set timefmt "%Y-%m-%dT%H:%M:%S"
set format x "%H:%M:%.3S"
plot '-' u 1:3 w l
pause 10000
EOF
