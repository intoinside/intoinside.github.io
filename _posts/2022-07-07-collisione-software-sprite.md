---
layout: post
title: Sprite collision
---

Ben trovati in questo nuovo post. Il filone degli sprite prosegue e questa
volta si parla di collisioni.

## Introduzione
Il C64, in tema di collisioni di sprite, mette a disposizione due registri sul
Vic-II: $d01e e $d01f.
Per entrambi i registri, ogni bit mappa uno sprite (da #0 a #7) ed è impostato 
a 1 se il relativo sprite partecipa ad una collisione.

Il primo registro mappa le collisioni tra sprite, il secondo riguarda le 
collisioni tra gli sprite e il background.
Dei due, in questo post, ci interessa (almeno in parte) il primo dei due.

Se sfruttiamo il primo registro, stiamo parlando di collisione *hardware*.
Guardando il registro, ci si rende conto che tante informazioni sulla 
collisione sono fuse insieme rendendoci impossibile, in molte situazioni, 
capire quali sprite sono stati coinvolti.

Se, leggendo il registro, viene restituito il valore %10000011, possiamo 
capire che lo sprite #0 e lo sprite #1 sono in collisione.
Fino a qui, è facile.

Se, invece, dopo la lettura riceviamo il valore %00000111, rileviamo che gli
sprite #2, #1 e #0 sono coinvolti in una collisione. La lettura sopraindicata
avviene per un insieme di sprite come in figura.

![Collisione a tre sprite](/resources/collisione-1.png)

La stessa lettura però può avvenire anche per una configurazione di sprite come
la seguente.

![Collisione a tre sprite](/resources/collisione-2.png)

Si può perciò evincere che, a fronte di una stessa lettura, non è possibile 
determinare con certezza tra quali sprite è avvenuta la collisione: se il bit 
di uno sprite è 1 vuol dire che quello sprite ha avuto una collisione, ma,
quando ci sono di mezzo più di due sprite, non c'è modo di sapere con quale
sprite è avvenuta la collisione.

Questo è un problema se la logica del nostro gioco/programma richiede questa
informazione.

## Funzionamento logico

Si può cercare una soluzione costruendosi le cose in casa, scegliendo una 
via completamente software oppure ibrida.

Ho avuto questo problema nel mio gioco
[ForestSaver](https://github.com/intoinside/ForestSaver), dove ci sono molti 
sprite contemporaneamente visibili e ho la necessità di sapere tra chi 
avvengono le collisioni.

Ho perciò scelto di implementare una subroutine per realizzare un rilevatore
*software* di collisioni.
La mia soluzione potrebbe essere anche *ibrida* se si appoggiasse
al registro del Vic-II per ottimizzare i tempi di esecuzione.

Sostanzialmente, l'idea di base della mia soluzione è verificare se un punto
di uno sprite (ad esempio, il vertice in alto a sinitra) si trova all'interno 
dell'area di un altro sprite.
Se è così allora la collisione è accertata altrimenti... no.

In questo post, ripropongo la subroutine utilizzata nel gioco, che consente di
verificare se lo sprite #0 (il ranger) ha avuto una collisione con uno degli 
altri sprite degli "omini" del gioco.

La soluzione si compone di una prima parte in cui si impostano gli sprite da
sottoporre a verifica e della subroutine che esegue tutto il lavoro.

## Implementazione

L'esempio che vedremo verificherà se lo sprite #1 è in collisione con il 
ranger (sprite #0).

Affrontiamo subito la prima parte, cioè quella di impostazione dei dati per
effettuare la verifica.

E' piuttosto semplice e consiste nell'assegnare a due variabili (*OtherX* e
*OtherY*) le coordinate dello sprite da controllare (nel nostro caso, lo
sprite #1).
La variabile *OtherX* è una word (16 bit) perché la coordinata X può andare 
oltre ai 255 pixel.

Per sapere se uno sprite si trova oltre questo limite, si fa uso del registro
$d010 che imposta i bit a 1 se il relativo sprite è al di là dei 255 pixel.
Quindi, visto che stiamo parlando dello sprite #1, è sufficiente usare la 
maschera %00000010 e metterla in *AND* con la lettura del registro $d010.

Se il risultato è diverso da zero allora siamo oltre i 255 pixel, pertanto la
parte alta di *OtherX* deve essere impostata a 1.

Questa impostazione è fatta con le prime righe del seguente snippet.

```
    lda $d010       // Leggi il registro
    and #%00000010  // applica la maschera per conoscere lo stato dello
    beq !+          // sprite #1, se il risultato (memorizzato in A) è 0 salta 
    lda #$1         // alla label ! altrimenti imposta in A il valore 1 
  !:
    sta SpriteCollision.OtherX + 1
    lda $d002
    sta SpriteCollision.OtherX
    lda $d003
    sta SpriteCollision.OtherY
    jsr SpriteCollision
```

Le righe successive impostano la parte bassa di *OtherX* con la coordinata
X del registro $d002 e la coordinata Y dal registro $d003 in *OtherY*.

L'ultima istruzione richiama la subroutine per effettuare la verifica, il cui 
codice è il seguente.

```
SpriteCollision: {
// Determino i bordi dello sprite del ranger
    lda $d010
    and #%00000001
    sta RangerX1 + 1
    sta RangerX2 + 1

    lda $d000
    sta RangerX1
    sta RangerX2
    add16value($0018, RangerX2)

    lda $d001
    sta RangerY1
    clc
    adc #21
    sta RangerY2

// La collisione avviene se le coordinate dell'altro sprite sono 
// all'interno del contenitore del ranger.
// Questo avviene se
// RangerX1 < OtherX < RangerX2
// RangerY1 < OtherY < RangerY2

// Se OtherX < RangerX1 allora salta fuori (no collisione)
    bmi16(OtherX, RangerX1)
    bmi NoCollisionDetected

// Se RangerX2 < OtherX allora salta fuori (no collisione)
    bmi16(RangerX2, OtherX)
    bmi NoCollisionDetected

// Se OtherY < RangerY1 allora salta fuori (no collisione)
    lda OtherY
    cmp RangerY1
    bmi NoCollisionDetected

// Se RangerY2 < OtherY allora salta fuori (no collisione)
    lda RangerY2
    cmp OtherY
    bmi NoCollisionDetected

  CollisionDetected:
    lda #$01
    jmp Done

  NoCollisionDetected:
    lda #$00

  Done:
    rts

// Contenitore del ranger
  RangerX1: .word $0000
  RangerX2: .word $0000
  RangerY1: .byte $00
  RangerY2: .byte $00

// Coordinate dell'altro sprite
  OtherX: .word $0000
  OtherY: .byte $00
}
```

Al ritorno dalla subroutine, nel registro *A* ci sarà 1 se la collisione è
stata rilevata, altrimenti 0.

Non c'è da spaventarsi di fronte ad alcune istruzioni presenti nel listato.
Il significato è il seguente:
* add16value(x, y): aggiunge il valore x alla variabile y e memorizza il
risultato (simile ad *adc* ma opera su valori a 16 bit)
* bmi16(x, y) effettua le comparazioni tra due variabili a 16 bit e imposta i 
flag per l'esecuzione di un'istruzione *bmi*.

### Note
* La collisione viene rilevata basandosi, come detto all'inizio,
sul vertice in alto a sinistra dello sprite #1. Se volessimo utilizzare il
centro dello sprite basta aggiungere 12 a *OtherX* e 10 a *OtherY* (attenzione 
a gestire correttamente la parte alta di *OtherX* qualora l'aggiunta dovesse
oltrepassare i 255).

* Lo sprite #0 può essere svincolato rendendo la subroutine più generica, basta
inserire le sue coordinate come parametri.

* L'impostazione iniziale dei parametri può essere trasfromata in una *macro*,
così si semplifica il codice.

* La rilevazione hardware verifica se gli sprite si sovrappongono nelle loro
parti colorate (la collisione non avviene se si sovrappongono le aree
trasparenti). Questa subroutine non è così raffinata.

## Sprite multiplexing
Entrando nell'argomento del multiplexing, l'utilizzo di una rilevatore software
diventa molto importante se non essenziale.

Dato che in questa subroutine, la verifica avviene tramite confronto di 
coordinate, può essere completamente svincolata dai registri del Vic-II.
Se consideriamo l'esempio di uno dei [precedenti post](https://intoinside.github.io/2022/06/20/sprite-multiplexing-organizzare/),
dove gli 8 sprite hardware mappano gli sprite "virtuali", è sufficiente 
sostituire le istruzioni che leggono i registri di posizione degli sprite con
la struttura che memorizza le posizioni degli sprite virtuali e il gioco è 
fatto.

## Conclusioni

Ho parlato di una soluzione strettamente legata ad un problema che ho avuto
in passato e si vede che è molto aderente alle necessità.

Ho dato qualche spunto per generalizzarla e adattarla a vari contesti, poi
ovviamente dipende dalla logica del gioco/programma.

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/sprite-multiplexing)!

Le discussioni più interessanti verranno aggiunte qui.

