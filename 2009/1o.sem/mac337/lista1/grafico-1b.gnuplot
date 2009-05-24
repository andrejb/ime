set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-1b.eps"
set xlabel 't'
set ylabel 'g(t)'
set xrange [-6:6]
set yrange [-3:3]
set dummy t
set sample 1001
set xtics 1
set ytics 1
set grid linewidth 3

g(t) = (t == floor(t)) \
         ? sqrt(-1) \
           : ((t > 0) \
           ? ((floor(t) % 3 == 0) \
             ? (floor(t) % 2 == 0 ? sin(pi*t) : -sin(pi*t)) \
             : (2 - t + 3*floor(t / 3))) \
           : ((floor(-t) % 3 == 2) \
             ? (floor(-t) % 2 == 0 ? sin(pi*(-t)) : -sin(pi*(-t))) \
             : (2 - t - 3 - 3*floor(-t / 3))));
plot g(t) lw 5;
set output;
quit;
