set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-2a-f2.eps"
set xlabel 't'
set ylabel 'f(t)'
set xrange [-20:20]
set yrange [-100:100]
set dummy t
set sample 1001
set xtics 20
set ytics 20
set grid linewidth 3 

f(t) = (t == 0) \
         ? sqrt(-1) \
         : ((t < 0) \
           ? 0 \
           : (exp(t)));

plot f(t) lw 10;
set output;
quit;

