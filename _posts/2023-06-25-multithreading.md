---
layout: post
title: Multi threading
---

Multithread a 8 bit? Beh si, può sorprendere ma anche sul processore 6502 è possibile ottenere una certa forma di multithreading. C'è qualche compromesso, ci sono forti limitazioni ma, si, tecnicamente è possibile.

## Show me the code, quickly!
Con lo snippet presente qui https://gist.github.com/intoinside/ff0d07e86685408c9b48ea8888e5cb4c
è possibile attivare un semplice sistema di multi threading.

La parte **Entry** inizializza la struttura, imposta lo stack e prepara
l'esecuzione del primo thread.

Successivamente viene definito il **content_switch** che viene invocato ad ogni
chiamata dell'IRQ e, agendo similmente a uno scheduler, decide il prossimo
thread da eseguire, predisponendone l'ambiente e sospendendo il precedente.

In seguito sono definiti i due thread.

Cominciamo intanto a dire che è un "finto" multithreading che rientra
nella categoria "interleaved" o "preemptive" (https://en.wikipedia.org/wiki/Temporal_multithreading).
Significa che non c'è mai più
di un blocco di codice in esecuzione ma la frequenza del passaggio da uno
all'altro dà l'illusione che ci sia un'esecuzione realmente concorrente. Non
potrebbe essere diversamente perché c'è un solo core di elaborazione.

Un altro scoglio è quello delle risorse, ne parliamo separatamente su due
fronti.

### Memoria
Stiamo parlando pur sempre di un processore a 8 bit che gestisce fino a 64Kib
di ram e l'apporccio multithread prevede:
* stack dedicato per ogni thread ovvero suddivisione dello stack esistente
tra tutti i thread da eseguire: la quantità di spazio per ogni thread che decresce
lineamente in proporzione al numero di thread presenti
* area di memoria disponibile per ogni thread

### Cpu
Il 6502, come noto, funziona a una velocità di 1 MHz (che raddoppiano nella
modalità FAST per il 8502 del C128). Che è pochissimo, non ci sarebbe bisogno di
dirlo.

Questa limitata quantità di cicli deve essere suddivisa tra più blocchi di codice
che si contendono il diritto di esecuzione. Inoltre, assieme alla mera esecuzione
del codice dei thread, c'è l'overhead della gestione dello scheduler, in quanto a
ogni rintocco dell'IRQ, lo scheduler deve valutare il prossimo thread da eseguire
e deve metterlo in condizione di partire (oltre a parcheggiare quello precedente).
Non è tantissimo ma comunque parliamo di qualche decina di cicli di clock.

### Miscellaneous
Ci sono inoltre tutte le altre risorse del sistema per le quali va decisa una
politica di gestione: accesso al disco, accesso ad aree di memoria 
condivisa, uso di funzionalità del sistema (schermo, suono, joystick...).

## E quindi?
Quindi, si, è possibile avere il multithreading anche sul C64/C128 ma gli scenari
d'uso sono fortemente limitati (se non annullati del tutto) dalle limitate risorse
complessive del sistema.

Ma comunque dal punto di vista emozionale, è veramente affascinante!
