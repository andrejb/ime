TEXFILES = lista1.tex lista1-ex1.tex lista1-ex2.tex lista1-ex3.tex lista1-ex4.tex
FUNCTION_GRAPHICS = grafico-1a.eps grafico-1b.eps grafico-1c.eps
TRANSFORM_GRAPHICS =  grafico-1a-transformada.eps grafico-1b-transformada.eps grafico-1c-transformada.eps

lista1.pdf: lista1.dvi
	dvipdf lista1.dvi
#	make partial-clean

lista1.dvi: $(TEXFILES) $(FUNCTION_GRAPHICS) $(TRANSFORM_GRAPHICS)
	latex -output-format=dvi $<
	latex -output-format=dvi $<
	latex -output-format=dvi $<

$(FUNCTION_GRAPHICS): %.eps: %.gnuplot
	gnuplot $(subst eps,gnuplot,$@)

grafico-1a-transformada.eps: grafico-1a-transformada.gnuplot
	octave 1a.m
	tail -n +6 1a-sintese.data | ./fix_data6.rb > 1a-sintese-fixed.data
	gnuplot $<

grafico-1b-transformada.eps: grafico-1b-transformada.gnuplot
	octave 1b.m
	tail -n +6 1b-sintese.data | ./fix_data6.rb > 1b-sintese-fixed.data
	gnuplot $<

grafico-1c-transformada.eps: grafico-1c-transformada.gnuplot
	octave 1c.m
	tail -n +6 1c-sintese.data | ./fix_data6pi.rb > 1c-sintese-fixed.data
	gnuplot $<

partial-clean:
	rm -f *.data *.{aux,log,dvi,eps}
	
clean: partial-clean
	rm -f *.pdf
	
	
