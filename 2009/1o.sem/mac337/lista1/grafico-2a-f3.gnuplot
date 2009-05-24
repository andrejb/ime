set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-2a-f3.eps"
set xlabel 't'
set ylabel 'f(t)'
set xrange [-10:10]
set yrange [-5:5]
set dummy t
set sample 1001
set xtics 1
set ytics 1
set grid linewidth 3 

f(t) = (t == 0) \
         ? sqrt(-1) \
         : ((t < 0) \
           ? 0 \
           : (exp(0)));

plot f(t) lw 10;
set output;
quit;


