set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-1c-transformada.eps"
set xlabel 't'
set ylabel 'h(t)'
set xrange [-10:10]
set yrange [-8:8]
set dummy t
set sample 10000
set xtics 2
set ytics 2
set grid linewidth 3
set samples 50
plot "1c-sintese-fixed.data" with lines lw 5 ti "h(t)";
set output;
quit;
