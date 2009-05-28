set term postscript eps color blacktext "Helvetica" 24
#set terminal png
set output "grafico-4d-1.eps"
set xlabel 'f'
set ylabel 'G(f)'
set xrange [0:22050]
set yrange [-1:8]
set dummy f
#set sample 1003
#set xtics 1
#set ytics 1
#set grid linewidth 3

A = 0.8;
R = 44100;
theta = (pi/4);

G(f) = (sqrt(1+2*sqrt(A)*cos(2*pi*f/R)+A)  *       \
        sqrt(1-2*sqrt(A)*cos(2*pi*f/R)+A)) /       \
       (sqrt(1-2*A*cos(theta-(2*pi*f/R))+(A*A)) * \
        sqrt(1-2*A*cos(theta+(2*pi*f/R))+(A*A)));

plot G(f) lw 5;
set output;
quit;


