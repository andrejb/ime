
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
FO=2/(3*pi);

% Cria um vetor com 4*R*T amostras (4 periodos) com o valor constante FO
t=zeros(1,4*R*T)+FO;

% Adiciona multiplos inteiros da frequencia w
for n=1:Nharmonicos
  Fn=((1-exp(i*(pi-2*pi*n/3)))/(6*pi-4*n*pi))+((1-exp(-i*(pi+2*pi*n/3)))/(6*pi+4*n*pi))+(((-exp(-i*2*n*pi)-exp(-i*2*n*pi/3)))/(-i*2*n*pi))+((3*(-exp(-i*2*n*pi)+exp(-i*2*n*pi/3)))/(4*n*n*pi*pi));
  h=zeros(1,4*R*T);
  for j=1:4*R*T;
    h(j)=Fn*exp(i*n*w*(j/R))+(Fn')*exp(-i*n*w*(j/R));
    t(j)=t(j)+h(j);
  end;
end;
%plot(0:1/R:4*T-1/R,t);drawnow
a=t';
save 1b-sintese.data a;
