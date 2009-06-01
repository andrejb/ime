
printf("\nSíntese de uma função periódica a partir da série de Fourier\n");
fflush(stdout);

% Numero de harmonicos
Nharmonicos=100;

% Periodo
T=3;

% Taxa de amostragem
R=50;

% Frequencia angular fundamental
w=2*pi/T;

% Valor do coeficiente em n=0
FO=(1/T)*3;

% Cria um vetor com 4*R*T amostras (4 periodos) com o valor constante FO
t=zeros(1,4*R*T)+FO;

% Adiciona multiplos inteiros da frequencia w
for n=1:Nharmonicos
  Fn=(-1/(3*i*n*w))*(exp(-i*n*w)*(2*exp(-i*n*w)-1)-1);
  h=zeros(1,4*R*T);
  for j=1:4*R*T;
    h(j)=Fn*exp(i*n*w*(j/R))+(Fn')*exp(-i*n*w*(j/R));
    t(j)=t(j)+h(j);
  end;
end;
%plot(0:1/R:4*T-1/R,t);drawnow
a=t';
save 1a-sintese.data a;

