
disp("# O exemplo a seguir pretende verificar os cálculos feitos à");
disp("# mão em sala de aula a respeito da decomposição de uma onda");
disp("# quadrada em harmônicos senoidais da forma");
disp("# a(j)*sen(j*w*t)+b(j)*cos(j*w*t). Foram obtidos os");
disp("# coeficientes a(j)=0 para j par e a(j)=4/(j*pi) para j ímpar,");
disp("# e b(j)=0 para todo j. Reconstruindo a onda com estes");
disp("# valores, e usando os harmônicos até ordem 99, teremos o");
disp("# seguinte gráfico.");

# A função a seguir é usada para plotar o vetor s usando
# uma escala vertical definida pelos limites ylo e yhi
function plotlim(s,ylo,yhi)
  plot(s);
  # define a faixa vertical dos valores nos gráficos
  set(gca(),"ylim",[ylo, yhi]);
  drawnow();
endfunction


# define um tamanho para o vetor contendo a forma de onda,
# que representará 1s de uma onda quadrada com frequência 1Hz.

N = 10000;
s = zeros(N,1);

for j=1:2:99
  # usamos taxa de amostragem N e amplitude 4/(j*pi) para o j-ésimo harmônico
  s += sinetone(j,N,1,4/(j*pi));
endfor

plotlim(s,-2,2);

disp("# Pressione qualquer tecla...");
pause;


disp("# ");
disp("# A aproximação ficará melhor com o uso de mais harmônicos, e");
disp("# só seria perfeita com a inclusão de todos os harmônicos.");
disp("# Usando os harmônicos até ordem 999, teremos o seguinte");
disp("# gráfico.");
disp("# Pressione qualquer tecla...");
pause;


s = zeros(N,1);
for j=1:2:999
  s += sinetone(j,N,1,4/(j*pi));
endfor

plotlim(s,-2,2);




disp("# ");
disp("# Poderíamos ter calculado os coeficientes automaticamente");
disp("# através das fórmulas, usando a soma dos vetores como");
disp("# aproximação para a integral. Faremos isso neste exemplo");
disp("# inicializando um vetor f com uma representação exata de um");
disp("# período de uma onda quadrada, conforme o gráfico exibido.");
disp("# Pressione qualquer tecla...");
pause;



# Define o número de amostras de um período
N = 10000;

# cria onda quadrada e plota o gráfico
s = [ones(N/2,1); -ones(N/2,1)];
plotlim(s,-2,2);



disp("# ");
disp("# Para calcular automaticamente a decomposição, utilizamos as");
disp("# equações de análise a(j) = (2/T)*integral(f.*sin(j*w*t)) e");
disp("# b(j) = (2/T)*integral(f.*cos(j*w*t)). A integral será");
disp("# aproximada pela soma do vetor, normalizada pelo número de");
disp("# amostras correspondente a 1 segundo.");
disp("# Pressione qualquer tecla...");
pause;


# dados da forma de onda
f = 1; # Hz
T = 1/f;
w = 2*pi*f;

# número de harmônicos a ser calculados
M = 100;

# inicialização do vetor de coeficientes
a = zeros(M,1);
b = zeros(M,1);

# coeficientes do harmônico 0
a0 = 0;
b0 = (1/T)*sum(s)*(T/N);

# valores de tempo associados às amostras utilizadas
t = linspace(0,1,N)';

# calcula equação de síntese
for j=1:M
  a(j) = (2/T)*sum(s.*sin(j*w*t))*(T/N);
  b(j) = (2/T)*sum(s.*cos(j*w*t))*(T/N);
endfor;

plotlim(a,-2,2);

disp("# ");
disp("# Os valores deste gráfico representam os coeficientes");
disp("# a(j). Observe os valores decrescentes nos índices ímpares e");
disp("# os valores nulos nos índices pares.");
disp("# Pressione qualquer tecla...");
pause;

plotlim(b,-2,2);

disp("# ");
disp("# Os valores deste gráfico representam os coeficientes");
disp("# b(j). Os valores são praticamente zero.");
disp("# ");
disp("# De posse dos coeficientes, podemos reconstruir a onda");
disp("# original somando os harmônicos. Para ilustrar o modo como os");
disp("# harmônicos senoidais aproximam a onda original, serão");
disp("# plotados os gráficos das somas parciais correspondendo aos");
disp("# primeiros k parciais, para k=1,2,...");
disp("# Pressione qualquer tecla...");
pause;

# Ressíntese

s = a0*sin(0.*t)+b0*cos(0.*t);
plotlim(s,-2,2);
pause(0.125);
for j=1:M
  s += a(j)*sin(j*w*t)+b(j)*cos(j*w*t);
  plotlim(s,-2,2);
  pause(0.125);
endfor





disp("# ");
disp("# O segundo exemplo mostra um período de uma onda periódica");
disp("# chamada de 'dente-de-serra'. Usaremos o mesmo código para");
disp("# analisar e reconstruir esta forma de onda a partir de");
disp("# harmônicos senoidais.");


N = 10000;

s = linspace(0,1,N)';
plotlim(s,-2,2);

disp("# Pressione qualquer tecla...");
pause;

# Análise

t = linspace(0,1,N)';
T = 1;
f = 1/T;
w = 2*pi*f;

M = 100;

a = zeros(M,1);
b = zeros(M,1);

a0 = 0;
b0 = (1/T)*sum(s)*(T/N);

for j=1:M
  a(j) = (2/T)*sum(s.*sin(j*w*t))*(T/N);
  b(j) = (2/T)*sum(s.*cos(j*w*t))*(T/N);
endfor;

plotlim(a,-2,2);
disp("# Estes são os valores dos coeficientes a(j).");
disp("# Pressione qualquer tecla...");
pause;

plotlim(b,-2,2);
disp("# E dos coeficientes b(j).");
disp("# Pressione qualquer tecla para ver a reconstrução da onda.");
pause;

# Ressíntese

s = a0*sin(0.*t)+b0*cos(0.*t);
plotlim(s,-2,2);
pause(0.125);
for j=1:M
  s += a(j)*sin(j*w*t)+b(j)*cos(j*w*t);
  plotlim(s,-2,2);
  pause(0.125);
endfor







disp("# ");
disp("# O último exemplo mostra um período de uma onda periódica");
disp("# arbitrária, formada por um trecho linear descendente, um");
disp("# pedaço de parábola e um trecho de uma curva cúbica. Mais uma");
disp("# vez usaremos o mesmo código para analisar e reconstruir esta");
disp("# forma de onda a partir de harmônicos senoidais.");


N = 10000;

s = [linspace(0,-1,N/4)'; linspace(-1,1,N/4)'.^2; linspace(-1,1,N/2)'.^3];
plotlim(s,-2,2);
disp("# Pressione qualquer tecla...");
pause;

# Análise

t = linspace(0,1,N)';
T = 1;
f = 1/T;
w = 2*pi*f;

M = 100;

a = zeros(M,1);
b = zeros(M,1);

a0 = 0;
b0 = (1/T)*sum(s)*(T/N);

for j=1:M
  a(j) = (2/T)*sum(s.*sin(j*w*t))*(T/N);
  b(j) = (2/T)*sum(s.*cos(j*w*t))*(T/N);
endfor;

plotlim(a,-2,2);
disp("# Estes são os valores dos coeficientes a(j).");
disp("# Pressione qualquer tecla...");
pause;

plotlim(b,-2,2);
disp("# E dos coeficientes b(j).");
disp("# Pressione qualquer tecla para ver a reconstrução da onda.");
pause;

# Ressíntese

s = a0*sin(0.*t)+b0*cos(0.*t);
plotlim(s,-2,2);
pause(0.125);
for j=1:M
  s += a(j)*sin(j*w*t)+b(j)*cos(j*w*t);
  plotlim(s,-2,2);
  pause(0.125);
endfor

disp("# Todos os exemplos ficarão mais precisos (e mais demorados)");
disp("# acrescentando-se mais harmônicos (aumentando o valor de M");
disp("# nos exemplos acima).");



