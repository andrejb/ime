
printf("\nSíntese de um pulso a partir da transformada de Fourier Contínua\n");
fflush(stdout);

% Numero de frequencias utilizadas
Nparciais=100;

% Taxa de amostragem
R=50;

% Frequencia "fundamental" para os parciais utilizados na aproximacao
wO=1;

% Valor da transformada em w=0
FO=1;

% Cria um vetor com 4*R amostras com o valor constante FO/(2*pi)
t=zeros(1,4*R)+(FO)/(2*pi);

% Adiciona multiplos inteiros da frequencia wO
for n=1:Nparciais
  w=n*wO;
  % Expressao para o coeficiente da transformada de Fourier para a frequencia w
  % edite esta expressao para testar a resposta de seus exercícios da lista 2
  Fw=sin(w/2)/(w/2);
  h=zeros(1,4*R);
  for j=1:4*R;
    % sao usados 4*R pontos no intervalo -4:4
    x=-4+2*j/R;
    h(j)=(Fw*exp(i*w*x)+(Fw')*exp(-i*w*x))/(2*pi);
    t(j)=t(j)+h(j);
  end;
  plot(-4:(2/R):4-(2/R),t);
end;

