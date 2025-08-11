---
layout: post
title: Autoboot explained pt2
tags: commodore-128 autoboot boot autoboot-c64 commodore-64
---

Esempio pratico per capire come funziona l'autoboot in due modalità differenti:

* autoboot classico per C128
* autoboot che funziona per la modalità C64 del C128

Come detto nel [precedente articolo](/2024/04/07/autoboot-explained), l'autoboot
è una funzionalità introdotta nel Commodore 128. Pertanto non è possibile usufruirne nel C64...

In realtà è possibile, ma è utilizzabile solo nella modalità C64 offerta dal C128. L'usabilità
di questa funzione perciò risulta molto limitata ma è interessante vederla dal punto di vista tecnico.
Ora vedremo come si può implemetare l'autoboot sia nella modalità pura C128 che nella modalità C64.

# Autoboot C128

Come detto, il disco che consentirà l'autoboot deve essere modificato in modo che il C128,
dopo l'accensione (o quando si utilizza il comando BOOT), sia in grado di avviare il programma
desiderato.

{% include note.html note_content="Il codice qui presente è stato ottenuto modificando esempi disponibili in rete, in fondo alla pagina sono elencate le risorse" %}

La versione più semplice prevede la creazione di un disco con autoboot che avvia un programma.

L'autoboot dovrà essere generato con questa struttura:

<pre>
0000 43 42 4D 00 00 00 00 41   CBM....A
0008 55 54 4F 42 4F 4F 54 20   UTOBOOT 
0010 46 4F 52 20 43 31 32 38   FOR C128
0018 00 00 A2 20 A0 0B 4C A5   ........
0020 AF 52 55 4E 22 41 55 54   .RUN"AUT
0028 4F 42 4F 4F 54 2D 43 31   OBOOT-C1
0030 32 38 22 00 00 00 00 00   28".....
</pre>

Per generare il boot sector dobbiamo partire da un disco vuoto (con VICE lo si può creare
dal menu File) e successivamente possiamo utilizzare il programma BASIC/ML sottostante:

``` Basic
10 REM CREATE BOOT SECTOR
20 DCLEAR: OPEN 15, 8, 15: OPEN 2, 8, 2, "#": PRINT# 15, "B-P:2, 0"
30 READ D$: D = DEC(D$): IF D>255 THEN 50
40 PRINT# 2, CHR$(D); : GOTO 30
50 PRINT# 15, "U2;2, 0, 1, 0"
60 PRINT DS$ : CLOSE 2 : CLOSE 15
70 DATA 43, 42, 4D, 00, 00, 00, 00
80 DATA 41, 55, 54, 4F, 42, 4F, 4F, 54, 20, 46, 4F, 52, 20, 43, 31, 32, 38
90 DATA 00, 00, A2, 20, A0, 0B, 4C, A5, AF, 52, 55, 4E
100 DATA 22, 41, 55, 54, 4F, 42, 4F, 4F, 54, 2D, 43, 31, 32, 38, 22, 00
1000 DATA 100
```

## Descrizione

``` Basic
20 DCLEAR: OPEN 15, 8, 15: OPEN 2, 8, 2, "#": PRINT# 15, "B-P:2, 0"
```

* DCLEAR: azzera la directory buffer del drive (serve a partire da uno stato "pulito")
* OPEN 15, 8, 15: apre il canale di comando (15) verso il drive 8.
* OPEN 2, 8, 2, "#": apre il canale dati (2) verso il drive 8, modalità raw ("#" significa settore fisico).
* PRINT# 15, "B-P:2, 0": comando al drive per posizionare la testina al settore di boot.
  * "B-P" significa "Block Position".
  * Parametri 2, 0 = canale 2, settore 0 della traccia di boot (che di solito è traccia 1, settore 0 nel C128).

``` Basic
30 READ D$: D = DEC(D$): IF D>255 THEN 50
```

* READ D$: legge un valore dal DATA, come stringa (può contenere valori esadecimali o numerici).
* D = DEC(D$): converte da stringa (esadecimale o decimale) in numero decimale.
* IF D>255 THEN 50: se il valore è maggiore di 255 allora fine dei dati veri e propri, salta alla riga 50.

``` Basic
40 PRINT# 2, CHR$(D); : GOTO 30
```

Invia il byte convertito (CHR$(D)) al canale dati 2 (quindi lo scrive direttamente nel settore). Il punto e virgola ; evita l'inserimento del terminatore CR/LF. Poi torna alla riga 30 per leggere il prossimo byte.

``` Basic
50 PRINT# 15, "U2;2, 0, 1, 0"
```

* "U2" è il comando drive per scrivere un blocco (Block Write).
  * 2 = canale di dati aperto
  * 0, 1, 0 = traccia 1, settore 0 (boot sector standard per il C128)

In pratica qui il drive scrive fisicamente il settore con i dati appena inviati.

``` Basic
60 PRINT DS$ : CLOSE 2 : CLOSE 15
```

* PRINT DS$: Mostra lo stato del drive (DS$ contiene il messaggio di stato).
* CLOSE 2 / CLOSE 15: Chiude i canali aperti.

``` Basic
70 DATA 43, 42, 4D, 00, 00, 00, 00
```

43 42 4D in ASCII è "CBM", identificatore del boot block.
I quattro byte successivi a 00 sono:

* l'indirizzo (16bit) in cui memorizzare altri dati letti da disco
* il bank in cui memorizzare i dati
* il numero di settori da leggere

Dato che il numero di settori è 0, i tre byte precedenti non sono significativi.

``` Basic
80 DATA 41, 55, 54, 4F, 42, 4F, 4F, 54, 20, 46, 4F, 52, 20, 43, 31, 32, 38
```

ASCII: "AUTOBOOT FOR C128"

``` Basic
90 DATA 00, 00, A2, 20, A0, 0B, 4C, A5, AF, 52, 55, 4E
```

Contiene due byte zero usati come terminatore del boot message (definito in riga 80) e del program name (non utilizzato), poi codice macchina:

<pre>
A2 20     LDX #$20
A0 0B     LDY #$0B
4C A5 AF  JMP $AFA5
</pre>

I valori inseriti in .X e .Y rappresentano l'indirizzo immediatamente precedente alla stringa 
da scrivere (per questo esempio la stringa si trova a $0B21, in .Y c'è l'hi-byte $0B
e in .X c'è il lo-byte -1 cioè $20).

52 55 4E in ASCII è "RUN" (stringa di comando BASIC). Il nome del programma
da caricare è definito nella riga 100:

``` Basic
100 DATA 22, 41, 55, 54, 4F, 42, 4F, 4F, 54, 2D, 43, 31, 32, 38, 22, 00
```

ASCII: "AUTOBOOT-C128" tra virgolette, poi terminatore 00.

Mandando in esecuzione questo programma, il boot sector del disco viene modificato in modo da avviare il
programma "AUTOBOOT-C128". Adesso dobbiamo creare questo programma.

Trattandosi di un programma di esempio, è sufficiente digitare i comandi:

``` Basic
NEW
10 PRINT "AUTOBOOT LOADED SUCCESSFULLY!!"
DSAVE "AUTOBOOT-C128"
```

Per la parte di autoboot del C128, abbiamo finito, basta chiamare il comando BOOT oppure effettuare un reset della macchina. In questo caso, il risultato su monitor 80 colonne dovrebbe essere questo:

![Booting message](/resources/autoboot-pt2.png)

# Links

* [Atarimagazines.com - Boot 64 for 128](https://www.atarimagazines.com/compute/issue77/Boot_64_For_128.php)
* [Istennyila.hu - Writing Platform Independent Code on CBM Machines](https://istennyila.hu/dox/cbmcode.pdf)
* [Infinite-loop.at - Documentazione comandi floppy](https://www.infinite-loop.at/Power64/Documentation/Power64-Leggimi/AB-Comandi_Floppy.html)
