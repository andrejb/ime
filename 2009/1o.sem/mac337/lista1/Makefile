TEXFILES = lista1.tex
GRAPHICS = grafico-1a.eps grafico-1a-transformada.eps grafico-1b.eps grafico-1b-transformada.eps grafico-1c.eps grafico-1c-transformada.eps

lista1.pdf: $(TEXFILES) $(GRAPHICS)
	latex $<

grafico-1a.eps: grafico-1a.gnuplot
	gnuplot $<

grafico-1a-transformada.eps: grafico-1a-transformada.gnuplot
	octave 1a.m
	tail -n +6 1a-sintese.data | ./fix_data6.rb > 1a-sintese-fixed.data
	gnuplot $<

grafico-1b.eps: grafico-1b.gnuplot
	gnuplot $<

grafico-1b-transformada.eps: grafico-1b-transformada.gnuplot
	octave 1b.m
	tail -n +6 1b-sintese.data | ./fix_data6.rb > 1b-sintese-fixed.data
	gnuplot $<

grafico-1c.eps: grafico-1c.gnuplot
	gnuplot $<

grafico-1c-transformada.eps: grafico-1c-transformada.gnuplot
	octave 1c.m
	tail -n +6 1c-sintese.data | ./fix_data6pi.rb > 1c-sintese-fixed.data
	gnuplot $<

clean:
	rm -f *.data *.{aux,log,dvi,pdf} *.eps
	
	
	
