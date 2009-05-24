set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-1a.eps"
set xlabel 't'
set ylabel 'f(t)'
set xrange [-5:5]
set yrange [-3:5]
set dummy t
set sample 1001
set xtics 1
set ytics 1
set grid linewidth 3 

f(t) = (t == floor(t)) \
         ? sqrt(-1) \
         : ((t >= 0) \
           ? ((floor(t) % 3 == 0) \
             ? 1 \
             : ((floor(t) %3 == 1) ? 2 : 0)) \
           : ((floor(-t) % 3 == 0) ? 0 : (floor(-t) %3 == 1 ? 2 : 1)));
plot f(t) lw 10;
set output;
quit;
