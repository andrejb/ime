


# Ressíntese do pulso quadrado, usando os coeficientes calculados
# em aula pela transformada (contínua) de Fourier.

# define um intervalo de tempo entre -10 e +10 segundos, sando 1000 pontos.
m = 1000;
t = linspace(-10,10,1000)';

# o pulso original era definido como valendo +1 entre -tau e +tau,
# 0 no resto. Neste exemplo usaremos tau = 2
tau = 2;

# wrange é a faixa de frequências que usaremos para reconstruir o
# pulso. A rigor, deveríamos usar todas as frequências reais entre
# -infty e +infty, mas esta é uma aproximação. Usaremos
# frequências da forma 0.1Hz, 0.2Hz, 0.3Hz, ..., 50Hz.
wrange = 0.1:0.1:50;
# a diferença entre duas frequências sucessivas é importante para
# aproximar o valor da integral de Fourier por uma somatória.
wstep = wrange(2)-wrange(1);

# inicializamos a função reconstruída com o harmônico 0
# onde F(0) era tau/(2*pi)
f = tau/(2*pi)*ones(m,1)*wstep;
# para cada frequência w utilizada...
for w = wrange
  # acrescenta o harmônico de w com amplitude
  # 2*[tau/(2*pi)]*[sen(w*tau/2)/(w*tau/2)]
  f += 1/(2*pi)*tau*(sin(w*tau/2)/(w*tau/2))*(2*cos(w.*t))*wstep;
  plot(t,f);title(num2str(w));drawnow;
endfor

pause;








# Exemplo do efeito da amostragem no tempo
# Usaremos uma onda senoidal amostrada em 44100Hz, que
# fará o papel de um sinal "contínuo", do qual extrairemos
# um sinal sub-sampleado a uma taxa de 44100/5 = 8820Hz.
# Em seguida observaremos o efeito desta "discretização"
# no espectro do sinal.

SR = 44100;
sig = sinetone(440,SR,1,1);

# As frequências que a FFT utiliza neste vetor de 1seg
# estarão espaçadas de 1Hz.
freq = 0:SR-1;
plot(freq,abs(fft(sig)));drawnow;
pause;

# O sinal reamostrado preservará apenas 1 valor a cada
# 5 amostras, as demais amostradas serão zeradas.
t = 1:length(sig);
resamp = sig.*(mod(1:length(sig),5)==0)';

# o sinal "discretizado"
plot(resamp(1:300));drawnow;
pause;

# o espectro do sinal "discretizado". Observe as múltiplas
# cópias do sinal original espaçadas de 8820Hz em 8820Hz:
plot(freq,abs(fft(resamp)));drawnow;
pause;






# Exemplo do janelamento no tempo
# Analogamente ao exemplo anterior, partiremos de uma
# senoide "pura", e observaremos o efeito do janelamento
# com janelas de tamanho 100, 200, 300, 400, ..., 44100.

SR = 44100;
sig = sinetone(440,SR,1,1);
freq = 0:SR-1;
# o espectro original
plot(freq,abs(fft(sig)));drawnow;
pause;

# para cada tamanho de janela
for N = 100:100:SR
  # redefine a faixa de frequências usada pela FFT correspondente
  freq = 0:SR/N:(N-1)*SR/N;
  # seleciona as frequências até 1000Hz (para vermos melhor o gráfico)
  ind = find(freq<1000);
  # plota a parte baixa do espectro
  plot(freq(ind),abs(fft(sig(1:N)))(ind)/N);title(num2str(N));drawnow;
  pause(0.5);
endfor











# Exemplo de janelamento no espectro
# Lembrando que recortar o espectro na faixa entre -fc Hz e +fc Hz
# corresponde a convoluir o sinal no tempo com uma função sinc.

# usaremos um ruido branco, que possui um espectro aproximadamente uniforme
ruido = rand(SR,1)-0.5;
plot(ruido(1:200));
pause;

# o espectro do ruido branco:
freq = 0:SR-1;
plot(freq,abs(fft(ruido))/SR);
pause;

# tentaremos "cortar este espectro preservando apenas as frequências
# até 5000Hz, convoluindo com a seguinte função sinc:
fc = 5000;
sinal = sinc(2*fc*linspace(-1,1,2*SR)');
plot(sinal(SR-50:SR+50));
pause;

# o sinal convoluido é:
sinal2 = conv(ruido,sinal);
plot(sinal2(1:200));
pause;

# calculando a FFT do sinal convoluido:
N = length(sinal2);
freq = 0:SR/N:(N-1)*SR/N;
plot(freq,abs(fft(sinal2))/N);
pause;

