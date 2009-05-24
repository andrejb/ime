set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-1a-transformada.eps"
set xlabel 't'
set ylabel 'f(t)'
set xrange [-5:5]
set yrange [-3:5]
set dummy t
set sample 1001
set xtics 1
set ytics 1
set grid linewidth 3
set samples 50
plot "1a-sintese-fixed.data" with lines lw 5 ti "f(t)";
set output;
quit;
