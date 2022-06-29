---
layout: post
title: Calcolo carattere da coordinate
---

Eccoci qui con un nuovo post dedicato agli sprite, molto più semplice dei
precedenti, ma che riguarda una situazione che spesso mi è capitato di gestire:
come calcolare la posizione del carattere a partire dalle coordinate x,y?


## Introduzione
Iniziamo mostrando uno schema della schermata tipica del C64, in cui ho
posizionato uno sprite nel punto più in alto-sx in modo da renderlo
completamente visibile.

![Coordinate base](/resources/coordinate-schermo-c64.png)

Le coordinate di questo sprite sono (24, 50). Lo sprite è visibile per intero,
nel quattro angoli ho volutamente messo un punto luminoso per indicare il
vertice.

Lo scopo di questo post è calcolare la posizione del carattere sottostante
(in questo caso, è il carattere in posizione 0,0) e rilevare di quale 
carattere si tratta.

### Funzionamento logico
Il modo per ottenere questa informazione è rapportare la posizione dello sprite
all'area caratteri.
La formula è banale e per la coordinata x è:

Colonna carattere = (X - 50) / 8

Riga carattere = (Y - 24) / 8

I due valori 8 delle formule sono le dimensioni in pixel del singolo carattere.

Per chiarezza, la formula consente di trovare il carattere sotto il punto in 
alto a sinistra dello sprite.

Supponiamo di voler calcolare quale sia il carattere sulla griglia a partire
dalle coordinate x,y. Possiamo immaginare, per esempio, che queste x,y 
appartengano ad uno sprite che ha effettuato una collisione con un carattere
sullo schermo.

La collisione può essere rilevata con tecniche diverse, una di queste è 
monitorare lo stato del registro del Vic-II raggiungibile all'indirizzo $d01f
(si, come ho detto, esistono altri modi più efficienti, più eleganti, più più 
più...).

Bene, da questo indirizzo, è possibile rilevare quale sprite ha generato la
collisione, per semplicità supponiamo che sia lo sprite #0.

### Codice
Ok dai, ora un pezzo alla volta e con un po' di strutture di supporto andiamo
a trovare il carattere sottostante.

![Posizione sprite iniziale](/resources/coordinate-schermo-c64-1.png)

Consideriamo la situazione qui sopra, abbiamo lo sprite #0 che viene definito 
con queste istruzioni:

```
    lda #$28
    sta $07f8

    lda #68
    sta $d000
    lda #80
    sta $d001

    lda #1
    sta $d015
```

Codice già visto in precedenza: impostazione della forma dello sprite, 
posizionamento sulle coordinate (68, 80) e attivazione. E' minimale, ho
inserito il minimo indispensabile per l'esempio.

Con questa condizione di partenza, procediamo al calcolo del carattere. 
Valutiamo la coordinata Y:

```
    lda $d001
    sec
    sbc #50
    lsr
    lsr
    lsr
```
La prima istruzione legge la coordinata Y dello sprite e inserisce il valore
nel registro A. Subito dopo, eseguo la sottrazione di 50 (pari al bordo
superiore). Di seguito ci sono tre istruzioni *lsr*. Ogni istruzione *lsr* 
esegue uno spostamento logico di bit verso destra del contenuto del registro A.

![Triplo lsr per y](/resources/triplo-lsr-y.png)

Come si può notare, lo spostamento a destra dei bit genera un valore binario
che è la metà del precedente. Equivale perciò ad una divisione intera, con
perdita del resto. Replicando tre volte la divisione, si ottiene la divisione 
per 8.

L'intento iniziale inizia a manifestarsi, la coordinata Y del carattere è 3
(proprio come ci aspettavamo). Ma procediamo oltre con il calcolo di X.

```
    lda $d000
    sec
    sbc #24
    lsr
    lsr
    lsr
```

Similmente a quanto visto sopra, prima viene recuperato la coordinata X dello
sprite e inserita nel registro A. Poi si prepara il terreno per la sottrazione
di 24 (dimensione in pixel del bordo destro). Nuovamente si esegue la divisione
per 8, ottenuta con tre istruzioni *lsr* consecutive.

![Triplo lsr per x](/resources/triplo-lsr-x.png)

In questo caso il risultato è 5, che corrisponde alla posizione X del
carattere che stiamo cercando.

Mettendo insieme i due snippet di codice, otteniamo che a fronte di uno sprite
in posizione (68, 80), riusciamo a rilevare le coordinate del carattere dello
schermo che sono (5, 3).

Per rilevare il carattere presente a queste coordinate, inseriamo questi
snippet in un blocco più complesso.

```
    lda $d001
    sec
    sbc #50
    lsr
    lsr
    lsr

    tay
    lda ScreenMemTableL, y
    sta ScreenPositionAddress
    lda ScreenMemTableH, y
    sta ScreenPositionAddress + 1

    lda $d000
    sec
    sbc #24
    lsr
    lsr
    lsr
    clc
    adc ScreenPositionAddress
    sta ScreenPositionAddress
    lda ScreenPositionAddress + 1
    adc #0
    sta ScreenPositionAddress + 1
```

Per rilevare il carattere presente ad una determinata coordinata, dobbiamo
cercare individuare l'indirizzo di memoria nella ScreenRam e, da lì, eseguire
una lettura. L'indirizzo è un valore a 16 bit quindi per gestirlo useremo una 
variabile così definita:

```
    ScreenPositionAddress: .word $0000
```

Il primo blocco di codice, come già visto si incarica di trovare la coordinata
Y del carattere su schermo. Dopo aver trasferito il valore dal registro A a Y,
lo si utilizza come indice per accedere a due tabelle di appoggio che, a fronte
di una coordinata Y restituiscono gli hi-byte (ScreenMemTableH) e i lo-byte
(ScreenMemTableL) della coordinata nella screen ram relativa alla riga di
interesse.

Dopo, con il codice già visto, si calcola la coordinata X del carattere. Il
valore, presente nel registro A, viene sommato alla variabile
ScreenPositionAddress (il primo adc fa la somma, il secondo adc, aggiunge un
eventuale riporto all'hi-byte).

Al termine di queste istruzioni, dentro ScreenPositionAddress abbiamo la
locazione di memoria nella screen ram del carattere che ci interessa. Per
recuperarlo sarà sufficiente fare:

```
    lda ScreenPositionAddress
```

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/sprite-multiplexing)!

Le discussioni più interessanti verranno aggiunte qui.

