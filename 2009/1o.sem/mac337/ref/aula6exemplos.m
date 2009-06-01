

# Exemplo de FFTs tomadas em momentos distintos de um mesmo sinal.
# O sinal considerado contém um fragmento de melodia com 3 sons
# consecutivos, cada um durando 1 segundo.

s = [sinetone(220,4096,1,1);sinetone(330,4096,1,1);sinetone(440,4096,1,1)];

# tomaremos FFTs com janelas de 1 segundo (4096 amostras),
# "deslizando" no tempo a cada 0.25s (1024 amostras).
# Observe como as janelas que cobrem dois sons diferentes
# apresentam em seus espectros os dois sons, com amplitudes
# proporcionais à fração de tempo que aquele som ocupa na
# janela.

for i=0:1024:2*4096
  plot(abs(fft(s(i+1:i+4096))));
  pause(0.25);
endfor;



# Função auxiliar, para o cálculo dos filtros, usada
# para "ler" um vetor s em índices que estão
# fora da faixa 1...length(s) (completando com 0).

function p = pad(s,i)
  if (i>0 && i<=length(s))
    p = s(i);
  else p = 0;
  endif
endfunction


# Primeiro exemplo: Filtro com equação y(n) = x(n) + K*x(n-1)

# calcularemos a resposta impulsiva numa janela de 1000 amostras
N = 1000;
# u é o impulso unitário
u = [1; zeros(N-1,1)];

# primeiro caso
K = 1;
# cálculo da resposta ao impulso unitário
for n=1:N
  h(n) = u(n) + K*pad(u,n-1);
endfor;
# espectro de magnitude do filtro:
plot(abs(fft(h)));
pause;
# espectro de fase:
plot(arg(fft(h)));
pause;

# segundo caso
K = -1;
# cálculo da resposta impulsiva
for n=1:N
  h(n) = u(n) + K*pad(u,n-1);
endfor;
# espectro de magnitude:
plot(abs(fft(h)));
pause;
# espectro de fase:
plot(arg(fft(h)));
pause



# Segundo exemplo: filtro recursivo y(n) = x(n) + K*y(n-1)

# primeiro caso
K = 0.9;
# cálculo da resposta impulsiva
for n=1:N
  h(n) = u(n) + K*pad(h,n-1);
endfor;
# espectro de magnitude:
plot(abs(fft(h)));
pause;
# espectro de fase:
plot(arg(fft(h)));
pause



# segundo caso
K = -0.9;
# cálculo da resposta impulsiva
for n=1:N
  h(n) = u(n) + K*pad(h,n-1);
endfor;
# espectro de magnitude:
plot(abs(fft(h)));
pause;
# espectro de fase:
plot(arg(fft(h)));
pause



