using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace aiv1
{
    class Program
    {
        static double Exp(double x) {
            return Math.Pow(Math.E,x);
        }

        static void Main(string[] args)
        {
            double lr = 2.0; //learning rate, arbitralnie ustawiony na 2.0 lr ma wplyw na szybkosc uczenia sieci
                             // duże lr to szybka zbieżność algorytmu, ale niekiedy brak stabilnosci metody
                             // małe lr to powolna zbieżność, ale stabilnosc algorytmu

            double[] d = new double[] { 23.90 / 25.05, 24.80 / 25.05, 24.97 / 25.05, 25.00 / 25.05 };  // wzorzec na wyjsciu z sieci

            int n = 100;     // liczba krokow obliczeniowych (epok) w procesie uczenia sieci


            double[] w111 = new double[100];   // waga pierwszej warstwy pierwszej jednostki, pierwsze wejscie
            double[] w112 = new double[100];   // waga pierwszej warstwy pierwszej jednostki, drugie wejscie
            double[] w121 = new double[100];   // waga pierwszej warstwy drugiej jednostki, pierwsze wejscie
            double[] w122 = new double[100];   // waga pierwszej warstwy drugiej jednostki, drugie wejscie

            double[] w21 = new double[100]; // waga drugiej warstwy pierwsze wejscie
            double[] w22 = new double[100];  //  waga drugiej warstwy drugie wejscie

            double[] beta = new double[100];   // wektory pomocnicze
            double[] beta21 = new double[100];
            double[] beta22 = new double[100];
            double[] bb = new double[100];
            double[] yy21 = new double[100];

            double[] w1s2 = new double[100];   // wektor dla wag skrosnych, wejscie 1 z jednostka 2
            double[] w2s2 = new double[100];   // wektor dla wag skrosnych, wejscie 2 z jednostka 2
            double[] w3s1 = new double[100];   // wektor dla wag skrosnych, wejscie 3 z jednostka 1
            double[] w4s1 = new double[100];   // wektor dla wag skrosnych, wejscie 4 z jednostka 1

            double[] dw111 = new double[100];  // wartosc o jaka zmieni sie waga w111 w danym kroku obliczeniowym,
            double[] dw112 = new double[100];  // wartosc o jaka zmieni sie waga w112 w danym kroku obliczeniowym,
            double[] dw121 = new double[100];  // wartosc o jaka zmieni sie waga w121 w danym kroku obliczeniowym,
            double[] dw122 = new double[100];  // poniewaz chcemy wyliczyc jak zmieniaja sie wszystkie wagi

            double[] dw1s2 = new double[100];  // jest to wektor do zmiennej wagi ktore laczy wejscie 1 z jednostka druga
            double[] dw2s2 = new double[100];  // jest to wektor do zmiennej wagi ktore laczy wejscie 2 z jednostka druga
            double[] dw3s1 = new double[100];  // jest to wektor do zmiennej wagi ktore laczy wejscie 3 z jednostka pierw.
            double[] dw4s1 = new double[100];  // jest to wektor do zmiennej wagi ktore laczy wejscie 4 z jednostka pierw.

            double[] dw21 = new double[100];   // wektor dla zmiany wagi w21
            double[] dw22 = new double[100];   // wektor dla zmiany wagi w22


            double[] blad = new double[100];   // blad sredniokwadratowy             blad = suma((d - u) * (d - u))

            // WEJŚCIA      WEJŚCIA        WEJŚCIA        WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA
            // WEJŚCIA      WEJŚCIA        WEJŚCIA        WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA

            /* TODO wektory wejściowe - trzeba coś z nimi zrobić, tak aby nie były wpisywane "z łapy", można 
             * np co 10 epok zaczytywać kolejne daty z tych samych spółek, kwestia przebadania jak program będzie się zachowywał
            */
            double[] u1 = new double[] {53.00/53.40, 1, 53.10/53.40, 52.5/53.4 }; // wektor wejsc spolki gieldowej BOGDANKA
            double[] u2 = new double[] {112/117.5 , 115.5/117.5 , 1, 1 }; // wektor wejsc spolki gieldowej DEBICA
            double[] u3 = new double[] {5.10/5.12 , 5.11/5.12 , 1 , 5.06/5.12 }; // wektor wejsc spolki gieldowej ECHO
            double[] u4 = new double[] {1, 11.50/11.60, 11.3/11.6, 10.85/11.6 }; // wektor wejsc spolki gieldowej HELIO

            // WEJŚCIA      WEJŚCIA        WEJŚCIA        WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA
            // WEJŚCIA      WEJŚCIA        WEJŚCIA        WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA     WEJŚCIA

            // początkowe wartości wag

            w111[0] = -0.8;
            w112[0] = 0.77;
            w121[0] = 0.82;
            w122[0] = -0.86;

            w1s2[0] = -0.9;
            w2s2[0] = 0.3;
            w3s1[0] = 0.5;
            w4s1[0] = -0.7;

            w21[0] = 0.95; // wartosci poczatkowe dla warstwy drugiej
            w22[0] = -0.92;


            for (int i = 0; i < n; i++) {
                dw111[i] = 0; // zerowanie przyrostow wag
                dw112[i] = 0;
                dw121[i] = 0;
                dw122[i] = 0;

                dw1s2[i] = 0; // zerowanie przyrostow wag skosnych
                dw2s2[i] = 0;
                dw3s1[i] = 0;
                dw4s1[i] = 0;

                dw21[i] = 0; // zerowanie przyrostow wag w warstwie drugiej
                dw22[i] = 0;

                bb[i] = 0;    // zerujemy wektor pomocnicze
                yy21[i] = 0;

                for (int j = 0; j < 4; j++) {
                    // zl1 to sygnal po sumowaniu w wezle sumacujnym, przed funkcja przejscia dla jednostki pierwszej
                    // zl2 to sygnal po sumowaniu w wezle sumacujnym, przed funkcja przejscia dla jednostki drugiej

                    double z11 = (u1[j] * w111[i] + u2[j] * w112[i] + u3[j] * w3s1[i] + u4[j] * w4s1[i]);
                    double s11 = 1 / (1 + Exp(-z11));  // to jest sygnal po funkcji przejscia, funkcja sigmoidalna
                    double z12 = (u3[j] * w121[i] + u4[j] * w122[i] + u1[j] * w1s2[i] + u2[j] * w2s2[i]);
                    double s12 = (1 / (1 + Exp(-z12)));  // to jest funkcja sigmoidalna dla drugiej jednostki pierwszej warstwy
                    double z21 = (s11 * w21[i] + s12 * w22[i]);  // te sume liczymy tylko raz ponieważ jest tylko jedna jednsotka w drugiej warstwie sieci
                    double s21 = (1 / (1 + Exp(-z21)));  // to jest sygnal na wyjsciu sieci zatem mozemy obliczac blad sredniokwadratowy,
                                                         // poprzez sumowanie bledu dla 4 wektorow wejsciowych, indeks j dla kazdej epoki indeks i
                                                         // blad sreddniokwadratowy okreslamy jako bb

                    bb[i] = bb[i] + 1 / 2 * (Math.Pow(s21 - d[j], 2)); // blad jako suma, to jest error na wyjsciu z sieci

                    // bedziemy obliczac zmiane wag metoda gradientowa, metoda gradientu prostego

                    yy21[i] = yy21[i] + s21 * (1 - s21);

                    beta[i] = s21 - d[j];   // pochodna bledu, bo blad jest siedniokwatratowy
                    // pochodna funkcji sigmoidalnej: (s21 * (1 - s21))
                    // s11 to sygnal z pierwszej jednostki


                    dw21[i] = dw21[i] + s11 * (s21 * (1 - s21)) * beta[i];
                    dw22[i] = dw22[i] + s12 * (s21 * (1 - s21)) * beta[i];

                    beta21[i] = w21[i] * (s21 * (1 - s21)) * beta[i]; // blad w srodku sieci, rzutowany w torze sygnalu wagi w21
                    beta22[i] = w22[i] * (s21 * (1 - s21)) * beta[i]; // w torze sygnalu wagi w22

                    // obliczanie zmiany wag w pierwszej warstwie - o jaka wartosc nalezy zmienic kazda z wag aby blad na wyjściu był jak najmniejszy

                    dw111[i] = dw111[i] + u1[j] * (s11 * (1 - s11)) * beta21[i];
                    dw112[i] = dw112[i] + u2[j] * (s11 * (1 - s11)) * beta21[i];
                    dw121[i] = dw121[i] + u3[j] * (s12 * (1 - s12)) * beta22[i];
                    dw122[i] = dw122[i] + u4[j] * (s12 * (1 - s12)) * beta22[i];

                    dw1s2[i] = dw1s2[i] + u1[0] * (s12 * (1 - s12)) * beta22[i];
                    dw2s2[i] = dw2s2[i] + u2[0] * (s12 * (1 - s12)) * beta22[i];
                    dw3s1[i] = dw3s1[i] + u3[0] * (s11 * (1 - s11)) * beta21[i];
                    dw4s1[i] = dw4s1[i] + u4[0] * (s11 * (1 - s11)) * beta21[i];

                    /* do optymalizacji zmiany wag stosujemy metode gradientu minimalizacji bledu pomiedzy sygnalem na wyjsciu sieci a zadanym wzorcem,
                     * tu jest dany wzorzec d stad obliczamy pochodne dla zmiany wagi. minimum wystepuje wtedy gdy zmiany wag daza do zera. 

*/

                }
                /*
* w kazdym sygnale wejsciowym bylo zawartych po 4 elementy wiec po zakonczeniu obliczenia zmiany wag dla kazdego z 4 sygnalow na wejsciu mozemy zmiwnic wagi
* zmiany wag to jedyna czynnosc ktora mozemy zrobic w trakcie uczenia sie. suma bledow jest dzielona przez dwa
                */
                blad[i] = bb[i];

                /* tu jest obliczana nowa waga - dotychczasowa wartosc wagi minus lerning rate
                * minus bierze się stąd, że liczymy antygradient a nie gradient poniewaz minimalizujemy błąd na wyjściu.
                * nowa waga to strata waga minus lr*dw21(i)
                * zmieniamy wartosci wszystkich wag
                */

                w21[i + 1] = w21[i] - lr * dw21[i];
                w22[i + 1] = w22[i] - lr * dw22[i];

                w111[i + 1] = w111[i] - lr * dw111[i];  // tu jest forsowanie procesu uczenia poprzez mnożenie przez Learning Rate
                w112[i + 1] = w112[i] - lr * dw112[i];  

                w121[i + 1] = w121[i] - lr * dw121[i];
                w122[i + 1] = w122[i] - lr * dw122[i];

                w1s2[i + 1] = w1s2[i] - lr * dw1s2[i];
                w2s2[i + 1] = w2s2[i] - lr * dw2s2[i];
                w3s1[i + 1] = w3s1[i] - lr * dw3s1[i];
                w4s1[i + 1] = w4s1[i] - lr * dw4s1[i];


            }         // koniec uczenia sieci // koniec uczenia sieci // koniec uczenia sieci // koniec uczenia sieci // koniec uczenia sieci
                      // koniec uczenia sieci // koniec uczenia sieci // koniec uczenia sieci // koniec uczenia sieci // koniec uczenia sieci

            double[] ut1 = new double[] { 23.9 / 25.05, 24.80/25.05, 24.97 / 25.05, 25 / 25.05 }; // wektor wejsc spolki gieldowej BOGDANKA
            double[] ut2 = new double[] { 112 / 117.5, 115.5 / 117.5, 1, 1 }; // wektor wejsc spolki gieldowej DEBICA
            double[] ut3 = new double[] { 5.10 / 5.12, 5.11 / 5.12, 1, 5.06 / 5.12 }; // wektor wejsc spolki gieldowej ECHO
            double[] ut4 = new double[] { 1, 11.50 / 11.60, 11.3 / 11.6, 10.85 / 11.6 }; // wektor wejsc spolki gieldowej HELIO


            ut2(1) = 115.50 / 118.90;
            ut2(2) = 118.00 / 118.90;
            ut2(3) = 118.90 / 118.90;
            ut2(4) = 116.50 / 118.90;

            ut3(1) = 296.50 / 310.80;
            ut3(2) = 304.90 / 310.80;
            ut3(3) = 310.80 / 310.80;
            ut3(4) = 307.45 / 310.80;

            ut4(1) = 57.23 / 59.82;
            ut4(2) = 59.16 / 59.82;
            ut4(3) = 59.82 / 59.82;
            ut4(4) = 58.50 / 59.82;



        }
    }
}
