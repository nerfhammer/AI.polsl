lr=2.0;  %learning rate arbitralnie jako 2, lr ma wplyw na szybkosc uczenia sieci
         %duże lr to szybka zbieżność algorytmu, ale niekiedy brak stabilnosci metody
		 %małe lr to powolna zbieżność, ale stabilnosc algorytmu

d=[23.90/25.05 24.80/25.05 24.97/25.05 25.00/25.05]
		% wzorzec na wyjsciu z sieci,

n=100;
		% liczba krokow obliczeniowych w procesie uczenia sieci,
		% jeden krok nazywa sie epoka
		% to kryterium zatrzymania programu zmienimy na kryterium dokladnosci metody

w111=[1:101];	% waga pierwszej warstwy pierwszej jednostki, pierwsze wejscie
w112=[1:101];	% waga pierwszej warstwy pierwszej jednostki, drugie wejscie
w121=[1:101];	% waga pierwszej warstwy drugiej jednostki, pierwsze wejscie
w122=[1:101];	% waga pierwszej warstwy drugiej jednostki, drugie wejscie

w21=[1:101]; % waga drugiej warstwy pierwsze wejscie
w22=[1:101]; % waga drugiej warstwy drugie wejscie

beta=[1:100];	% wektory pomocnicze
beta21=[1:100]; 
beta22=[1:100];	
bb=[1:100];		

w1s2=[1:101];	% wektor dla wag skrosnych, wejscie 1 z jednostka 2
w2s2=[1:101];	% wektor dla wag skrosnych, wejscie 2 z jednostka 2
w3s1=[1:101];	% wektor dla wag skrosnych, wejscie 3 z jednostka 1 
w4s1=[1:101];	% wektor dla wag skrosnych, wejscie 4 z jednostka 1

dw111=[1:100];	% wartosc o jaka zmieni sie waga w111 w danym kroku obliczeniowym,
dw112=[1:100];	% wartosc o jaka zmieni sie waga w112 w danym kroku obliczeniowym,
dw121=[1:100];	% wartosc o jaka zmieni sie waga w121 w danym kroku obliczeniowym,
dw122=[1:100];	% poniewaz chcemy wyliczyc jak zmieniaja sie wszystkie wagi

dw1s2=[1:100];	% jest to wektor do zmiennej wagi ktore laczy wejscie 1 z jednostka druga 
dw2s2=[1:100]; % jest to wektor do zmiennej wagi ktore laczy wejscie 2 z jednostka druga 
dw3s1=[1:100]; % jest to wektor do zmiennej wagi ktore laczy wejscie 3 z jednostka pierw. 
dw4s1=[1:100]; % jest to wektor do zmiennej wagi ktore laczy wejscie 4 z jednostka pierw.

dw21=[1:100];	% wektor dla zmiany wagi w21
dw22=[1:100];	% wektor dla zmiany wagi w22

blad=[1:100];	% blad sredniokwadratowy 
				% blad= suma ((d-u)*(d-u))

u1=[1:4]; % wektor wejsc spolki gieldowej BOGDANKA
u2=[1:4]; % wektor wejsc spolki gieldowej DEBICA
u3=[1:4]; % wektor wejsc spolki gieldowej ECHO
u4=[1:4]; % wektor wejsc spolki gieldowej HELIO

u1(1)=53,00/53,40; %sygnaly wejsc BOGDANKA
u1(2)=1;
u1(3)=53,10/53,40;
u1(4)=52,50/53,40;

u2(1)=112,00/117,50; %sygnaly wejsc DEBICA
u2(2)=115,50/117,50;
u2(3)=1;
u2(4)=1;

u3(1)=5,10/5,12; %sygnaly wejsc ECHO
u3(2)=5,11/5,12;
u3(3)=1;
u3(4)=5,06;

u4(1)=1;%sygnaly wejsc HELIO
u4(2)=11,50/11,60;
u4(3)=11,30/11,60;
u4(4)=10,85/11,60;

%poczatkowe wartosci wag

w111(1)=-0.8; 
w112(1)=0.77;
w121(1)=0.82;
w122(1)=-0.86;

w1s2(1)=-0.9; 
w2s2(1)=0.3;
w3s1(1)=0.5;
w4s1(1)=-0.7; 

w21(1)=0.95; %wartosci poczatkowe dla warstwy drugiej
w22(1)=-0.92; 

	% schemat ktory zostal zaproponowany to "warstwa jednostka wejscie" dla
	% notacji indeksow
	% warstwa, mamy dwie warstwy
	% jednostka, mamy trzy jednostki
	% wejscie, dla pierwszej warstwy mamy cztery wejscia
	
	% w tym miejscu rozpoczyna sie uczenie sieci neuronowej 
	% uczenia jest prowadzone metoda back propagation, to znaczy wstecznej 
	% propagacji bledu, jest to metoda optymalizacji statycznej
	% uczenie sieci jest przewidziane na 100 krokow czyli epok dla metody optymalizacji
	% uczenie sieci polega na takim dobrze wag, aby blad sredniokwadtratowy
	% na wyjsciu sieci byl minimalny 
	
for i=1:n,	% tu jest wielokrotnie wykonanie algorytmu uczenia dla n=100 krokow
			% obliczeniowych czyli epok, n-100 jest podane arbitralnie
		
dw111(i)=0; % zerowanie przyrostow wag 
dw112(i)=0;
dw121(i)=0;
dw122(i)=0;

dw1s2(i)=0; % zerowanie przyrostow wag skosnych  
dw2s2(i)=0; 
dw3s1(i)=0;
dw4s1(i)=0;

dw21(i)=0; % zerowanie przyrostow wag w warstwie drugiej
dw22(i)=0;

bb(i)=0;	% zerujemy wektor pomocnicze
yy21(i)=0;	% zerujemy drugi wektor pomocniczy

% dla kazdego kroku obliczeniowego (epoki) na wejscie sieci podajemy 4 wartosci
% sygnalow wejsciowych, w postaci liczbowej
% po 4 wartosci dla kazdego wejscia
% w glownej petli programu tej od 1 do n jest dodatkowa petla dla kazdego sygnalu

for j=1:4,	% zl1 to sygnal po sumowaniu w wezle sumacujnym, przed funkcja przejscia
			% dla jednostki pierwszej
			% zl2 to sygnal po sumowaniu w wezle sumacujnym, przed funkcja przejscia
			% dla jednostki drugiej

z11=(u1(j).*w111(i)+u2(j).*w112(i)+u3(j).*w3s1(i)+u4(j).*w4s1(i));
s11=(1/(1+exp(-z11))); 	% to jest sygnal po funkcji przejscia, funkcja sigmoidalna
z12=(u3(j).*w121(i)+u4(j).*w122(i)+u1(j).*w1s2(i)+u2(j).*w2s2(i));
s12=(1/(1+exp(-z12)));	% to jest funkcja sigmoidalna dla drugiej jednostki pierwszej warstwy 
z21=(s11.*w21(i)+s12.*w22(i));	%te sume liczymy tylko raz ponieważ jest tylko jedna
								% jednsotka w drugiej warstwie sieci
s21=(1/(1+exp(-z21)));	% to jest sygnal na wyjsciu sieci zatem mozemy 

% obliczac blad sredniokwadratowy, poprzez sumowanie bledu dla 4 wektorow
% wejsciowych, indeks j dla kazdej epoki indeks i
% blad sreddniokwadratowy okreslamy jako bb

bb(i)=bb(i)+1/2*((s21-d(j))^2);	% blad jako suma, to jest error na wyjsciu z sieci

% bedziemy obliczac zmiane wag metoda gradientowa, metoda gradientu prostego

yy21(i)=yy21(i)+s21*(1-s21);	
																
% obliczymy zmiany kazdej wagi dla kazdej jednostki
% Zaczynamy od warstwy drugiej poniewaz stosujemy algorytm wstecznej
% backpropagation bp propagacji bleldu
% obliczymy wspolczynnik beta jako pochodna bledu sredniokwadratowego

% s21 to sygnal który jest na wyjsciu sieci
% d(j) to sygnal podany na wyjscie sieci jako wzorzec wartosci, która oczekujemy
% na wyjsciu sieci

% zmiana wagi dw21 okreslona wzorem wynikajacym z obliczenia pochodnej
% sygnalu wzgledem wagi, gdy chcemy zmienic wage w21 obliczamy pochodna
% wzgledem tej wagi jest dana wzorem
% dla dociekliwych prosze wyprowadzic ten wzor

beta(i)=s21-d(j);	% pochodna bledu, bo blad jest siedniokwatratowy
					% pochodna funkcji sigmoidalnej: (s21*(1-s21))
					% s11 to sygnal z pierwszej jednostki

dw21(i)=dw21(i)+s11*(s21*(1-s21))*beta(i);
dw22(i)=dw22(i)+s12*(s21*(1-s21))*beta(i);

beta21(i)=w21(i)*(s21*(1-s21))*beta(i); % blad w srodku sieci, rzutowany
										% w torze sygnalu wagi w21
beta22(i)=w22(i)*(s21*(1-s21))*beta(i);	% w torze sygnalu wagi w22

% mozemy teraz obliczyc zmiany wag w pierwszej warstwie
% liczymy tu o jaka wartosc nalezy zmienic kazda z wag aby blad na wyjsciu sieci

dw111(i)=dw111(i)+u1(j)*(s11*(1-s11))*beta21(i);
dw112(i)=dw112(i)+u2(j)*(s11*(1-s11))*beta21(i);
dw121(i)=dw121(i)+u3(j)*(s12*(1-s12))*beta22(i);
dw122(i)=dw122(i)+u4(j)*(s12*(1-s12))*beta22(i);

dw1s2(i)=dw1s2(i)+u1(1)*(s12*(1-s12))*beta22(i);
dw2s2(i)=dw2s2(i)+u2(1)*(s12*(1-s12))*beta22(i);
dw3s1(i)=dw3s1(i)+u3(1)*(s11*(1-s11))*beta21(i);
dw4s1(i)=dw4s1(i)+u4(1)*(s11*(1-s11))*beta21(i);

% do optymalizacji zmiany wag stosujemy metode gradientu
% minimalizacji bledu pomiedzy sygnalem na wyjsciu sieci a zadanym
% wzorcem, tu jest dany wzorzec d
% stad obliczamy pochodne dla zmiany wagi
% minimum wystepuje wtedy gdy zmiany wag daza do zera !!!!
% poniewaz warunek konieczny na minimum to jest zerowanie pochodnej
% tu sa obliczane wartosci pomocnicze

end % koniec petli indekoswanej indeksem j czyli od 1 do 4

% dlatego ze w kazdym sygnale wejsciowym bylo zawartych po 4 elementy
% po zakonczeniu obliczenia zmiany wag dla
% kazdego z 4 sygnalow na wejsciu mozemy zmiwnic wagi
% zmiany wag to jedyna czynnosc ktora mozemy zrobic w trakcie uczenia sie
% suma bledow jest dzielona przez dwa

blad(i)=bb(i);

% tu jest obliczana nowa waga
% nowa waga to jest dotychczasowa wartosc wagi minus lerning rate
% wspolczynnik forsowania uczenia sieci razy
% obliczona wartosc zmiany wagi
% minus bo liczymy antygradient a nie gradient poniewaz minimalizujemy
% wartosc funkcji bledu sredniokwadratowego

% minus bierze sie stad, ze mamy problem minimalizacji
% gdyby byl problem maksymalizacji bledu znak bylby plus
% liczymy antygradient dla zmiany wagi stad znak minus
% nowa waga to strata waga minus lr*dw21(i)
% zmianiamy wartosci wszystkich wag, czyli tu 10 wag w tym przykladzie

w21(i+1)=w21(i)-lr*dw21(i);
w22(i+1)=w22(i)-lr*dw22(i);

w111(i+1)=w111(i)-lr*dw111(i); 	% tu jest forsowanie procesu uczenia, wspolczynnik
w112(i+1)=w112(i)-lr*dw112(i);	% lr to jest lerning rate
								% lr jest dobierany arbiralnie
								% ani zaduzy ani zamaly

w121(i+1)=w121(i)-lr*dw121(i);	
w122(i+1)=w122(i)-lr*dw122(i);

w1s2(i+1)=w1s2(i)-lr*dw1s2(i);
w2s2(i+1)=w2s2(i)-lr*dw2s2(i);
w3s1(i+1)=w3s1(i)-lr*dw3s1(i);
w4s1(i+1)=w4s1(i)-lr*dw4s1(i);

	% czyli zmieniamy 10 wartosci wag w jednym kroku obliczeniowym
	% tu jest zakonczenie (end) petli dla kolejnych epok

end	% to jest zakonczenie dla epoki, tu mamy 100 epok bo n=100
	% tu jest koniec obliczen
	% koniec algorytmu uczenia sieci
	
	% Mozna przystapic do pokazania rezultatow obliczenia w procesie uczenia
	% bedzie jeden rysunek zawierajacy 4 podrysunki
	% na kazdym podrysunku bedzie pewna liczba wykresow
	% zapis (221) oznacza ze bedzie 4 rysunki w dwoch wierszach i dwoch kolumnach
	% i ze to bedzie 1 rysunek dotyczacy wielkosci beta, to pochodna bledu na wyjsciu z sieci
	% a beta21 i beta22 to pochodne bledow wewnatrz struktury sieci
	% pomiedzy pierwsza a druga warstwa

subplot(221), plot(beta); title('beta beta21 beta22'); hold on;
subplot(221), plot(beta22); hold on;
subplot(221), plot(beta21); hold on;

	% na rysunku drugim zmiany wag od dw111 do dw122

subplot(222), plot(dw111); title('od dw111 do dw122 do w22'); hold on;
subplot(222), plot(dw112); hold on;
subplot(222), plot(dw121); hold on;
subplot(222), plot(dw122); hold on;
subplot(222), plot(dw21); hold on;
subplot(222), plot(dw22); hold on;
subplot(222), plot(dw1s2); hold on;
subplot(222), plot(dw2s2); hold on;
subplot(222), plot(dw3s1); hold on;
subplot(222), plot(dw4s1); hold on;

	% na trzecim rysunku beda wyrysowane wartosci wag (10 wag)

subplot(223), plot(w111); title('od w111 do w22'); hold on;
subplot(223), plot(w112); hold on;
subplot(223), plot(w121); hold on;
subplot(223), plot(w122); hold on;
subplot(223), plot(w21); hold on;
subplot(223), plot(w22); hold on;
subplot(223), plot(w1s2); hold on;
subplot(223), plot(w2s2); hold on;
subplot(223), plot(w3s1); hold on;
subplot(223), plot(w4s1); hold on;

	% na rysunku 4 bedzie wyrysowany blad

subplot(224), plot(blad);
title('blad czyli error na wyjsciu sieci');
	
pause;

% t oznacza test
	
wt111=w111(n+1)	% wartosci wagi w kroku 101 bo n=100, 100 epok

wt112=w112(n+1)
wt121=w121(n+1)
wt122=w122(n+1)

wt1s2=w1s2(n+1)
wt2s2=w2s2(n+1)
wt3s1=w3s1(n+1)
wt4s1=w4s1(n+1)

wt21=w21(n+1)
wt22=w22(n+1)

% trzeba podac wektor danych do testu
% tak jak w procesie uczenia bedzie ich 43/7

ut1=[1:4];	
ut2=[1:4];	
ut3=[1:4];	
ut4=[1:4];	

% wprowadzimy wrtosci z bazy danych dla wektorow ut, t oznacza tekstu
% z uwagi na zastosowanie sigmoidy jako funkcji przejscia dokonamy ich skalowania
% musimy skalowac bo sigmoida jest ograniczona do wartosci z przedzialu 0 1 

ut1(1)=23.90/25.05;
ut1(2)=24.80/25.05;
ut1(3)=24.97/25.05;
ut1(4)=25.00/25.05;

ut2(1)=115.50/118.90;
ut2(2)=118.00/118.90;
ut2(3)=118.90/118.90;
ut2(4)=116.50/118.90;

ut3(1)=296.50/310.80;
ut3(2)=304.90/310.80;
ut3(3)=310.80/310.80;
ut3(4)=307.45/310.80;

ut4(1)=57.23/59.82;
ut4(2)=59.16/59.82;
ut4(3)=59.82/59.82;
ut4(4)=58.50/59.82;

% liczymy pierwsza sume
% 111111111111111111111

zt11=ut1(1)*wt111+ut2(1)*wt112+ut3(1)*wt3s1+ut4(1)*wt4s1;
st11=(1/(1+exp(-zt11)));
zt12=ut3(1)*wt121+ut4(1)*wt122+ut1(1)*wt1s2+ut2(1)*wt2s2;
st12=(1/(1+exp(-zt12)));

zt21=st11*wt21+st12*wt22;
st21=(1/(1+exp(-zt21)));

% to jest sygnal na wyjsciu sieci, zatem mozemy obliczyc blad

% dla drugiego wektora
% 22222222222222222222

zt11=ut1(2)*wt111+ut2(2)*wt112+ut3(2)*wt3s1+ut4(2)*wt4s1;
st11=(1/(1+exp(-zt11)));

zt12=ut3(2)*wt121+ut4(2)*wt122+ut1(2)*wt1s2+ut2(2)*wt2s2;
st12=(1/(1+exp(-zt12)));

zt21=st11*wt21+st12*wt22;
st21=(1/(1+exp(-zt21)));

% dla trzeciego wketora
% 333333333333333333333

zt11=ut1(3)*wt111+ut2(3)*wt112+ut3(3)*wt3s1+ut4(3)*wt4s1;
st11=(1/(1+exp(-zt11)));

zt12=ut3(3)*wt121+ut4(3)*wt122+ut1(3)*wt1s2+ut2(3)*wt2s2;
st12=(1/(1+exp(-zt12)));

zt21=st11*wt21+st12*wt22;
st21=(1/(1+exp(-zt21)));

% dla 4 wektora danych testowych
% 444444444444444444444444444444
% w tym przypadku interesuje nas tylko wynik dla 4 wektora danych
% testowych, czyli st21 ktorego wartosc obliczamy ponizej

zt11=ut1(4)*wt111+ut2(4)*wt112+ut3(4)*wt3s1+ut4(4)*wt4s1;
st11=(1/(1+exp(-zt11)));

zt12=ut3(4)*wt121+ut4(4)*wt122+ut1(4)*wt1s2+ut2(4)*wt2s2;
st12=(1/(1+exp(-zt12)));

zt21=st11*wt21+st12*wt22;
st21=(1/(1+exp(-zt21))); 
st21=st21*25.05 %odpowiedz sieci przeskalowana do normalnego przedzialu
