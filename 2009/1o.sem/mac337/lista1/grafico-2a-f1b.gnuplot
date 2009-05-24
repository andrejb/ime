set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-2a-f1b.eps"
set xlabel 't'
set ylabel 'f(t)'
set xrange [-50:50]
set yrange [-2:2]
set dummy t
set sample 1001
set xtics 20
set ytics 1
set grid linewidth 3 

f(t) = (t == 0) \
         ? sqrt(-1) \
         : ((t < 0) \
           ? 0 \
           : (exp(-0.1*t)));

plot f(t) lw 10;
set output;
quit;
