---
layout: post
title: Sprite multiplexing - parte 3
tags: sprite sprite-multiplexing assembly
---

## Altri esempi

### Raddoppio dimensione in hardware
Spulciando tra i registri del Vic-II troviamo il $d017 e il $d01d che permettono
di duplicare, rispettivamente l'altezza e la larghezza degli sprite. L'effetto
è quello di uno sprite "tirato" similmente a quanto accade quando ingrandiamo
un'immagine in un programma di grafica.

Se aggiungiamo queste tre istruzioni nella routine Irq dopo l'impostazione del
colore
```
      lda #%00000000
      sta $d017
      sta $d01d
```
e queste tre nella routine Irq2
```
      lda #%11111111
      sta $d017
      sta $d01d
```
otterremo questo risultato
![Sprite](/resources/vice-16-sprite-dimensioni-doppie.png)

La prima porzione in Irq disattiva il raddoppio hardware di altezza e larghezza
per tutti gli sprite, mentre la porzione in Irq2 attiva la funzionalità.

Ogni bit è legato ad uno sprite: il bit #0 (quello più a destra) comanda lo sprite #0,
l'ultimo bit (quello più a sinistra) comanda lo sprite #7.
Chiaramente si può attivare la funzionalità per il singolo sprite, per la sola altezza o per la sola larghezza.

### Cambio colore singolo sprite
Nel post precedente abbiamo visto che possiamo impostare colori diversi agli sprite
nelle due scanline, ma nessuno ci vieta di impostare colori diversi per ogni singolo sprite.

Se ad esempio nella routine Irq inseriamo il codice
```
      lda #WHITE
      sta $d027
      lda #RED
      sta $d028
      lda #CYAN
      sta $d029
      lda #PURPLE
      sta $d02a
      lda #GREEN
      sta $d02b
      lda #BLUE
      sta $d02c
      lda #YELLOW
      sta $d02d
      lda #ORANGE
      sta $d02e
```
e nella routine Irq2 inseriamo il codice
```
      lda #BROWN
      sta $d027
      lda #LIGHT_RED
      sta $d028
      lda #DARK_GRAY
      sta $d029
      lda #GREY
      sta $d02a
      lda #LIGHT_GREEN
      sta $d02b
      lda #LIGHT_BLUE
      sta $d02c
      lda #LIGHT_GRAY
      sta $d02d
      lda #WHITE
      sta $d02e
```
(in entrambi i casi sostituendo la parte di codice che assegna il colore) otteniamo
questo effetto
![Sprite](/resources/vice-16-sprite-colori-indipendenti.png)

### Cambio sprite
Finora abbiamo lavorato sempre con lo stesso sprite, la cui definizione è in fondo
al file sorgente. E' possibile anche cambiare lo sprite tra due scanline, e lo
vediamo subito con un esempio. Innanzitutto, in fondo al file, forniamo la definizione
di un secondo sprite, subito dopo la definizione del primo:
```
* = $0a00
Sprites:
.byte $00,$00,$00,$00,$00,$00,$03,$f8,$00,$07,$f8,$00,$0f,$f8,$00,$1f
.byte $f8,$00,$1f,$07,$f0,$3e,$07,$e0,$3c,$07,$c0,$3c,$07,$80,$3c,$00
.byte $00,$3c,$07,$80,$3c,$07,$c0,$3e,$07,$e0,$1f,$07,$f0,$1f,$f8,$00
.byte $0f,$f8,$00,$07,$f8,$00,$03,$f8,$00,$00,$00,$00,$00,$00,$00,$07

Baloon:
.byte $00,$7f,$00,$01,$ff,$c0,$03,$ff,$e0,$03,$e7,$e0,$07,$d9,$f0,$07
.byte $df,$f0,$02,$d9,$f0,$03,$e7,$e0,$03,$ff,$e0,$03,$ff,$e0,$02,$ff
.byte $a0,$01,$7f,$40,$01,$3e,$40,$00,$9c,$80,$00,$9c,$80,$00,$49,$00
.byte $00,$49,$00,$00,$3e,$00,$00,$3e,$00,$00,$3e,$00,$00,$1c,$00
```
Ricordo, come scritto nel [post 1](/2022/06/02/sprite-multiplexing-parte1/),
lo sprite può essere generato con [SpritePad](https://csdb.dk/release/?id=132081),
esportato in Raw, inserito come sequenza di byte (come in questo esempio) oppure incluso tramite direttiva *.import*
(vedere [qui](http://www.theweb.dk/KickAssembler/webhelp/content/ch03s09.html) il riferimento
alla guida di Kick Assembler).

Poi, supponiamo di voler mostrare questo nuovo sprite nella seconda scanline quindi
in Irq2, modifichiamo la linea da
```
      lda #$28
```
in
```
      lda #$29
```
mantenendo anche la definizione colori del punto precedente otterremo questo
output:
![Sprite](/resources/vice-16-sprite-pointer-diverso-con-glitch.png)

Se aguzzate un po' la vista, noterete che sulla cupola delle ultime due mongolfiere
ci sono due strisce di colore diverso e, guardacaso, dello stesso colore dello sprite
soprastante.
Perché?

Beh è un problema legato all'ultimo Q/A del post precedente ovvero: sulla seconda
scanline, il Vic-II ha iniziato a disegnare la mongolfiera prima che venisse completato
il comando di cambio colore per lo sprite #6 e #7. Il ridisegno del Vic è stato
più veloce dell'esecuzione delle istruzioni sul processore, pertanto una porzione
è stata disegnata con il colore vecchio.

Come ovviare a questo problema? La soluzione è dare maggior tempo al processore
di completare il suo lavoro. Quindi, o si spostano gli sprite più in basso o si
lancia l'interrupt con qualche linea di anticipo.
Se proviamo a lanciare gli interrupt su 145 e 195 (che è un anticipo abbondante),
il problema non c'è più.
![Sprite](/resources/vice-16-sprite-pointer-diverso-senza-glitch.png)

Non è semplice avere un buon controllo, quindi è necessario fare molte prove per
verificare se si riesce ad ottenere un risultato in linea con le aspettative.

## Conclusioni
Dai pochi esempi, potete notare che con l'interrupt raster si possono fare diverse
cose per manipolare gli sprite e aggirare i limiti fisici. La contropartita è che
ciò che non può fornire l'hardware deve essere gestito "manualmente" dal programma.
Queste sono le basi per capire come funziona il flusso e, grossolanamente, quali
sono le potenzialità. A voi l'invito a prendere questi esempi e a sperimentare.

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/sprite-multiplexing)!

Le discussioni più interessanti verranno aggiunte qui.
