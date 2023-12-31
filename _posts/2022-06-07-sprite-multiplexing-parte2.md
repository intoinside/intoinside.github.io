---
layout: post
title: Sprite multiplexing - parte 2
tags: sprite sprite-multiplexing assembly
---

Ok, bene, compreso il concetto di sprite e ribadito che il C64 non può mostrarne più di 8
contemporaneamente, cerchiamo di capire come se ne possono aggiungere di più. Per farlo,
è necessario introdurre lo strumento alla base della tecnica. Si chiama interrupt raster.

Una delle particolarità del Vic-II è la capacità di generare
un "segnale" verso il processore in grado di interrompere (da qui la parola *interrupt*)
l'esecuzione del programma nel momento in cui l'immagine viene fisicamente generata sullo
schermo.
E' un po' come se il Vic-II dicesse al processore: "Ehi, finisci l'istruzione che stai
eseguendo in questo momento, poi dedicami del tempo".
Il processore, diligentemente, completa l'istruzione in corso poi trasferisce il
controllo su una locazione di memoria nota che contiene uno script.

Al termine di questo script, il processore riprende l'esecuzione da dove aveva interrotto.
In realtà ci sono altre fasi e attività svolte per rendere possibile questo processo ma,
semplificando, il flusso è questo.

La griglia dello schermo su cui viene disegnata l'immagine è detta raster, le righe
orizzontali sono dette *scanline* e i componenti della griglia sono detti *pixel*.
Tramite alcune sequenze di comandi, è possibile indicare al Vic-II di generare un
interrupt quando è in procinto di disegnare una determinata scanline.

Tutto bello, ma qual è l'idea di base del meccanismo del multiplexing? Si tratta di sfruttare
gli 8 sprite a disposizione, illudendo chi sta guardando l'immagine di averne di più, semplicemente
spostandoli durante il disegno della schermata.

Per capirci, se voglio disegnare 8 sprite alla riga 150 e altrettanti alla riga 200, ottenendo
perciò 16 sprite visibili nello stesso momento, sarà opportuno seguire i seguenti passi:
* Impostare un interrupt alla riga 149
* Muovere gli sprite sulla riga 150
* Impostare un interrupt alla riga 199
* Muovere gli sprite sulla riga 200
* Ricominciare da capo

Perciò, entrando più in dettaglio:
* il programma viene interrotto quando sta iniziando il disegno della riga 149
* la routine eseguita durante l'interruzione sposta tutti gli sprite alla riga 150
* si imposta un nuovo interrupt alla riga 199
* riprende l'esecuzione normale del programma
nel frattempo gli sprite sono stati disegnati alla riga 150
* il programma viene interrotto quando sta iniziando il disegno della riga 199
* la routine eseguita durante l'interruzione (diversa dalla precedente) sposta tutti
gli sprite alla riga 200
* si imposta nuovamente un interrupt alla riga 149
nel frattempo gli sprite sono stati disegnati alla riga 200 (assieme a quelli della
riga 150)

Q: Perchè l'interrupt viene impostato sulla riga 149 e gli sprite sono posizionati
sulla riga 150?

A: Il posizionamento degli sprite su una determinata area deve avvenire prima che
quell'area venga disegnata. Se l'interrupt venisse impostato dopo la riga 150, l'area
di schermo precedente alla scanline è già stata disegnata e un riposizionamento degli
sprite in quell'area non avrebbe effetto.
Non è possibile nemmeno impostare l'interrupt sulla scanline 150 perchè ci deve
essere del tempo per concludere le operazioni di spostamento e si rischia di avere
un disegno parziale degli sprite.

## Come impostare un interrupt
Le attività per indicare a quale linea il Vic-II deve lanciare un interrupt sono:
```
      lda #149
      sta $d012

      lda #<Irq
      sta $0314
      lda #>Irq
      sta $0315
```
Le prime due istruzioni caricano il valore 149 (la scanline dell'interrupt che vogliamo)
nell'accumulatore e, da qui, nell'indirizzo $d012 (è l'indirizzo del Vic-II preposto
a questo scopo).
Le successive 4 istruzioni caricano l'indirizzo della routine che deve essere eseguita
al lancio dell'interrupt. E' un indirizzo a 16 bit da caricare in due locazioni da
8 bit, pertanto in $0314 ci sarà la parte bassa dell'indirizzo (meno significativa)
della routine e in $0315 ci sarà la parte alta (più significativa).
Nel nostro esempio, la routine è etichettata con Irq.

## Listato completo
Di seguito il listato completo seguito da un po' di spiegazioni.
```
:BasicUpstart2($0810)

* = $0810
Init:
// Set Interrupt bit, impedisce alla Cpu di rispondere agli interrupt
// Evita che, mentre stiamo definendo le cose, il programma venga
// interrotto
      sei

// Sprite pointer
      lda #$28
      sta $07f8
      sta $07f9
      sta $07fa
      sta $07fb
      sta $07fc
      sta $07fd
      sta $07fe
      sta $07ff

// Imposto la coordinata X di tutti gli sprite
      lda #31
      sta $d000
      lda #62
      sta $d002
      lda #93
      sta $d004
      lda #124
      sta $d006
      lda #155
      sta $d008
      lda #186
      sta $d00a
      lda #217
      sta $d00c
      lda #248
      sta $d00e

// Coloro bordo e sfondo di nero
      lda #0
      sta $d020
      sta $d021

// Disattiva gli interrupt che possono arrivare dalla CIA-1
      lda #%01111111
      sta $dc0d

// Azzera il bit 7 del registro raster del Vic-II
      and $d011
      sta $d011

// Conferma per gli interrupt generati da CIA-1 e CIA-2
      lda $dc0d
      lda $dd0d

// Imposto il primo interrupt alla riga 149
      lda #149
      sta $d012

// Imposto la routine all'indirizzo Irq
      lda #<Irq
      sta $0314
      lda #>Irq
      sta $0315

// Abilita il Vic-II a lanciare gli interrupt
      lda #%00000001
      sta $d01a

// Abilito tutti gli sprite
      lda #%11111111
      sta $d015

// Consente alla Cpu di rispondere agli interrupt che arrivano
      cli
      rts

Irq:
// Spostamento degli sprite sulla riga 150
      lda #150
      sta $d001
      sta $d003
      sta $d005
      sta $d007
      sta $d009
      sta $d00B
      sta $d00D
      sta $d00F

// Coloro tutti gli sprite di verde
      lda #GREEN
      sta $d027
      sta $d028
      sta $d029
      sta $d02a
      sta $d02b
      sta $d02c
      sta $d02d
      sta $d02e

// Imposto il prossimo interrupt alla riga 199
      lda #199
      sta $d012

// Imposto la routine all'indirizzo Irq2
      lda #<Irq2
      sta $0314
      lda #>Irq2
      sta $0315

// Confermiamo al Vic-II l'esecuzione della routine
      asl $d019

// Avvia una routine del KERNAL per ripristinare lo stato precedente al
// lancio dell'interrupt, gestire il blink del cursore...altre n-mila cose
// e riprende la normale esecuzione del programma
      jmp $ea81

Irq2:
      lda #200
      sta $d001
      sta $d003
      sta $d005
      sta $d007
      sta $d009
      sta $d00B
      sta $d00D
      sta $d00F

      lda #RED
      sta $d027
      sta $d028
      sta $d029
      sta $d02a
      sta $d02b
      sta $d02c
      sta $d02d
      sta $d02e

      lda #149
      sta $d012

      lda #<Irq
      sta $0314
      lda #>Irq
      sta $0315

      asl $d019

// Avvia una routine del KERNAL per ripristinare lo stato precedente al
// lancio dell'interrupt, simile alla precedente ma più leggera
      jmp $ea31

* = $0a00
Sprites:

.byte $00,$00,$00,$00,$00,$00,$03,$f8,$00,$07,$f8,$00,$0f,$f8,$00,$1f
.byte $f8,$00,$1f,$07,$f0,$3e,$07,$e0,$3c,$07,$c0,$3c,$07,$80,$3c,$00
.byte $00,$3c,$07,$80,$3c,$07,$c0,$3e,$07,$e0,$1f,$07,$f0,$1f,$f8,$00
.byte $0f,$f8,$00,$07,$f8,$00,$03,$f8,$00,$00,$00,$00,$00,$00,$00,$07
```
Rispetto al listato precedente, si può osservare che nella parte di Init sono
state eliminate le parti che impostano il colore degli sprite e il posizionamento
sulla riga. Il colore è stato tolto perchè viene impostato dinamicamente
sulle due routine di interrupt, che dopo vedremo in dettaglio.
Il posizionamento verticale non è più presente sulla Init perchè è diventato
superfluo in quanto ogni sprite viene riposizionato su due righe diverse ad
ogni refresh dello schermo.

Subito dopo l'impostazione del colore bordo/sfondo ci sono alcune istruzioni di
contorno per attivare correttamente il sistema al lancio degli interrupt.
Prendiamole così come sono, non sono rilevanti per la tecnica.

Arriviamo quindi alla routine Irq. Da come è stato impostato il programma,
sappiamo che verrà lanciata sulla scanline 149. A questo punto possiamo spostare
gli sprite sulla riga 150, impostiamo il colore in verde e prepariamo il prossimo
interrupt. Fine.

Subito dopo c'è la routine Irq2. Partirà alla scanline 199 quindi, come per la
precedente, spostiamo gli sprite in riga 200 e aggiorniamo il colore.

Il risultato del listato è il seguente.
![Sprite](/resources/vice-16-sprite.png)

Q: ma si può fare anche altro nelle routine di interrupt?

A: beh... si... vedremo qualche esempio nella prossima puntata

Q: si deve impostare la scanline pari a un pixel in meno rispetto agli sprite?

A: no, basta che sia precedente alla posizione degli sprite. Talvolta è necessario
usare un margine maggiore di 1 perché se la routine è complessa potrebbe impiegare
più tempo per essere eseguita... mentre nel frattempo il disegno procede spedito.

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/sprite-multiplexing)!

Le discussioni più interessanti verranno aggiunte qui.
