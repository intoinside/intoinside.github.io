---
layout: post
title: Sprite multiplexing - parte 1
tags: sprite sprite-multiplexing commodore assembly 6502
---

Il primo post (quello serio con i contenuti), riguarda lo sprite multiplexing sul Commodore 64.
E' una tecnica che consente di visualizzare un numero di sprite maggiore rispetto a quelli che
l'hardware può mostrare contemporaneamente.
In questa prima parte, farò un rapido passaggio per spiegare il concetto di sprite, nel prossimo post
passerò al multiplexing.

Il [C64](https://it.wikipedia.org/wiki/Commodore_64) produce il suo output su video tramite il
MOS 6569/8565/8566, meglio conosciuto come [VIC-II](https://it.wikipedia.org/wiki/MOS_VIC-II).
Si tratta di un componente, evoluzione del VIC-I utilizzato sul Vic-20, in grado di gestire,
tra le altre cose, la visualizzazione degli sprite.

Gli sprite sono degli elementi grafici di 24x21 pixel. Possono essere visualizzati in modalità
HiRes (1 colore + il colore di trasparenza) oppure Multicolor (3 colori + il colore della trasparenza).
Ci sono delle limitazioni nell'utilizzo dei 3 colori: due di questi sono in comune a tutti gli sprite, mentre
uno è specifico per il singolo sprite. Inoltre, in questa modalità, i pixel hanno dimensione doppia.

Il VIC-II riesce a gestire fino a 8 sprite contemporaneamente presenti sullo schermo e il loro comportamento
è regolato da una serie di registri di memoria che consentono di:
* muovere ogni sprite sullo schermo (indirizzi $d000-$d00f e indirizzo $d010 per muoversi oltre la coordinata x = 255)
* visualizzare o nascondere ogni sprite ([$d015](https://c128lib.github.io/Reference/D000#D015))
* raddoppiare l'altezza o la larghezza ([$d017](https://c128lib.github.io/Reference/D000#D017) e [$d01d](https://c128lib.github.io/Reference/D000#D01D))
* dichiarare gli sprite HiRes o Multicolor ([$d01c](https://c128lib.github.io/Reference/D000#D01C))
...e poi impostare i colori, rilevare le collisioni e tante altre proprietà.

In questo esempio farò uso di uno sprite creato a mano con [SpritePad](https://csdb.dk/release/?id=132081)
![Sprite](/resources/creazione-sprite.png)
Come si nota dall'immagine, è uno sprite HiRes con colore principale giallo (7) e colore trasparente blu (6).

Il seguente listato in Assembly (da usare con [KickAssembler](http://theweb.dk/KickAssembler/)) serve a impostare
tutti gli 8 sprite con la stessa immagine e colore, alla riga 150.

Nel primo blocco imposto il colore, nel secondo indico il riferimento in memoria dove trovare lo sprite da disegnare,
poi imposto la coordinata X e Y degli sprite, infine coloro lo schermo di nero e abilito tutti gli sprite.
In fondo al listato c'è la definizione dello sprite mappato a partire dalla locazione di memoria $0940.

```
:BasicUpstart2($0810)

* = $0810
Init:
// Colore degli sprite
      lda #YELLOW
      sta $d027
      sta $d028
      sta $d029
      sta $d02a
      sta $d02b
      sta $d02c
      sta $d02d
      sta $d02e

// Sprite pointer
      lda #$25
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

// Imposto la coordinata Y di tutti gli sprite
      lda #150
      sta $d001
      sta $d003
      sta $d005
      sta $d007
      sta $d009
      sta $d00B
      sta $d00D
      sta $d00F

// Coloro bordo e sfondo di nero
      lda #0
      sta $d020
      sta $d021

// Abilito tutti gli sprite
      lda #%11111111
      sta $d015

      rts

* = $0940
Sprites:

.byte $00,$00,$00,$00,$00,$00,$03,$f8,$00,$07,$f8,$00,$0f,$f8,$00,$1f
.byte $f8,$00,$1f,$07,$f0,$3e,$07,$e0,$3c,$07,$c0,$3c,$07,$80,$3c,$00
.byte $00,$3c,$07,$80,$3c,$07,$c0,$3e,$07,$e0,$1f,$07,$f0,$1f,$f8,$00
.byte $0f,$f8,$00,$07,$f8,$00,$03,$f8,$00,$00,$00,$00,$00,$00,$00,$07
```

L'esecuzione di questo programma produce il seguente output.
![Sprite](/resources/vice-8-sprite.png)

Ok, questo è il punto di partenza. Nel prossimo post, faremo le cose interessanti!

Vuoi fare un commento o discutere i contenuti di questo articolo? Ti aspetto su
[Gitter](https://gitter.im/intoinside/sprite-multiplexing)!

Le discussioni più interessanti verranno aggiunte qui.
