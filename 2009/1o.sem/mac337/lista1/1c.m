
printf("\nSíntese de uma função periódica a partir da série de Fourier\n");
fflush(stdout);

% Periodo
T=2*pi;

% Taxa de amostragem
R=50;

% Frequencia angular fundamental
w=2*pi/T;

% Valor do coeficiente em n=0
FO=0;

% Cria um vetor com 4*R*T amostras (4 periodos) com o valor constante FO
t=zeros(1,4*R*T)+FO;

% Adiciona multiplos inteiros da frequencia w

F5=3/2;
h=zeros(1,4*R*T);
for j=1:4*R*T;
  h(j)=F5*exp(i*5*w*(j/R))+(F5')*exp(-i*5*w*(j/R));
  t(j)=t(j)+h(j);
end;

%plot(0:1/R:4*T-1/R,h);drawnow
%pause;

F8=-i
h=zeros(1,4*R*T);
for j=1:4*R*T;
  h(j)=F8*exp(i*8*w*(j/R))+(F8')*exp(-i*8*w*(j/R));
  t(j)=t(j)+h(j);
end;

% plot(0:1/R:4*T-1/R,h);drawnow
% pause;

% plot(0:1/R:4*T-1/R,t);drawnow
% pause;


%h=zeros(1,4*R*T);
%for j=1:4*R*T;
%  h(j)=3*cos(5*w*j/R)+2*sin(8*w*j/R);
%end;

%plot(0:1/R:4*T-1/R,h);drawnow
a=real(t)'
save 1c-sintese.data a
