set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-2a-u.eps"
set xlabel 't'
set ylabel 'U(t)'
set xrange [-10:10]
set yrange [-5:5]
set dummy t
set sample 1001
set xtics 1
set ytics 1
set grid linewidth 3 

U(t) = (t == 0) \
         ? sqrt(-1) \
         : ((t < 0) \
           ? 0 \
           : 1);

plot U(t) lw 10;
set output;
quit;



