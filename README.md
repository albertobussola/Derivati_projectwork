# Derivati_projectwork

Il progetto consiste nella calibrazione del modello di Vasicek visto in aula del corso di Derivati anno 2020/2021 presso l'Università degli Studi di Verona e la sua
implementazione per il calcolo del valore di un’opzione floor e di una cap attraverso una
simulazione Monte Carlo del tasso di interesse a breve.
I dati di AAA rated bonds sono stati estrapolati dal sito della European Central Bank il primo
giorno disponibile di dicembre per ogni anno. Una volta importati va costruita la funzione per
il calcolo del prezzo di uno ZCB nel modello di Vasicek.
Grazie alla funzione “vasicek_zcb” si riesce, scegliendo come input il parametro di mean
reversion alpha, il valore di lungo periodo gamma, la deviazione standard sigma e il valore
inziale r0, a determinare il prezzo per ogni maturità scelta come input.
Per la calibrazione abbiamo bisogno di una funzione obiettivo, nel nostro caso sono due
dato che sfruttiamo sia la funzione fminsearch che lsqnonlin per trovare i parametri che
minimizzino gli errori.
Utilizzando dati di 4 anni diversi possiamo vedere come il nostro modello si comporta più o
meno bene nel caso di curve meno regolari. Possiamo osservare come nel caso di curve con
punti di flesso il modello perda di efficacia, mentre in annate come il 2017, dove la struttura
per scadenza è sostanzialmente sempre concava, il modello si avvicina meglio ai dati. Nella
sua versione ad un fattore infatti il modello di Vasicek fa molta fatica a spiegare curve
concave e convesse a tratti, per questo esistono versioni del modello sviluppate in questo
senso in grado di catturare anche questi movimenti della curva.
Calibriamo i parametri sui dati del 2017 poiché, anche se più datati, risultano più adatti ad un
modello semplice come il nostro, possiamo anche notare come la funzione fminsearch riesca
ad avvicinarsi di più ai dati osservati. Scegliamo quindi i parametri per il 2017 ottenuti da
fminsearch e sono nell’ordine alpha, gamma, sigma, r0: 0,4418; 1,1880 %; 0,2099 %; -
2,2926 %.
Con questi parametri possiamo simulare il tasso a breve, sia per calcolare il payoff nelle varie
simulazioni delle opzioni e sia per costruire la struttura per scadenza per tutte le maturità.
Va implementata nel codice l’equazione:
𝑟𝑡 = 𝛾 + (𝑟0 − 𝛾) exp(−a𝑡) +s exp(−a𝑡)ò exp(a𝑠)𝑑𝑊𝑠
che definisce il tasso a qualsiasi maturità t in funzione del tasso a breve, nel nostro caso r0
sarà -2,2926% trovato con la calibrazione. Vengono fatte 1000 simulazioni per il tasso a
breve e viene costruita la struttura per scadenza che servirà per scontare i payoff dei
derivati. Quest’ultima viene calcolata 1000 volte insieme ai tassi associati estrapolando da
questi i tassi Euribor a 6m e salvandoli nella matrice “i6m” (2520x1000). Si noti come i tassi,
partendo tutti da un valore negativo si avvicinino al valore 1,1880% che è il tasso di lungo
periodo, questo viene anche confermato dal calcolo di R∞ che è 1,1869%. Notiamo anche
che il valore di alpha è <1 come è giusto aspettarsi dal termine di mean-reversion.
Ora abbiamo tutti gli strumenti per calcolare il prezzo di due derivati, un floor e un cap in 0
simulando i loro payoff futuri in funzione del tasso Euribor a 6 mesi.
Per il valore di un floor con maturità 10 anni, tenor semestrale, strike 0,28%, nozionale di
100.000 € e sottostante Euribor 6 mesi costruiamo il vettore dei tassi “euribor1” da
confrontare con lo stike e con un doppio ciclo for calcoliamo i payoff per ogni simulazione
del tasso a breve come:
𝑆𝑘 = 100.000 € ∗ 0,5 ∗ 9𝑘 − 𝑖6𝑚(𝑡𝑘 − 1, 𝑡𝑘)= +∗ 𝑝(0, 𝑡𝑘)
Dove S è il k-esimo flusso, 100.000 è il nozionale, 0,5 è il tenor, k è lo strike price e i è il
Euribor a 6 mesi. Sfruttando il metodo Monte Carlo per calcolare il valore del floor facciamo
la media della somma dei payoff scontati.
Per il valore di un cap con nozionale 100.000 €, tenor semestrale e strike 0,22% il
procedimento è molto simile senonchè i payoff vengono calcolati in maniera diversa:
𝑆𝑘 = 100.000 € ∗ 0,5 ∗ (𝑖6𝑚(𝑡𝑘 − 1, 𝑡𝑘) − 𝑘) +∗ 𝑝(0, 𝑡𝑘)
ossia come parte positiva della differenza tra il tasso Euribor e lo strike moltiplicata per il
tenor (1) e per il nozionale vengono poi scontati con i prezzi della struttura per scadenza
ricavata dalle simulazioni del tasso a breve. Viene infine fatta la somma dei flussi scontati per
ogni simulazione e calcolando il valore medio troviamo il prezzo del cap.


Fonte dati
https://www.ecb.europa.eu/stats/financial_markets_and_interest_rates/euro_area_yield_curv
es/html/index.en.html
