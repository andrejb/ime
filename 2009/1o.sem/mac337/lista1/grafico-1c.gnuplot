set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-1c.eps"
set xlabel 't'
set ylabel 'h(t)'
set xrange [-10:10]
set yrange [-8:8]
set dummy t
set sample 10000
set xtics 2
set ytics 2
set grid linewidth 3

h(t) = 3*cos(5*t) + 2*sin(8*t);
plot h(t) lw 5;
set output;
quit;
