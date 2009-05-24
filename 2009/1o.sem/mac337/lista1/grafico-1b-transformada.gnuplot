set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-1b-transformada.eps"
set xlabel 't'
set ylabel 'g(t)'
set xrange [-6:6]
set yrange [-3:3]
set dummy t
set sample 1001
set xtics 1
set ytics 1
set grid linewidth 3
set samples 50
plot "1b-sintese-fixed.data" with lines lw 5 ti "g(t)";
set output;
quit;
