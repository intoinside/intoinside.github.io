---
layout: post
title: Ambiente di sviluppo - parte 1
---

Ciao a tutti! Vi propongo un post che forse doveva arrivare ben prima...
ma tant'è...

Oggi descriverò il mio personale ambiente di sviluppo, col quale creo tutte le
applicazioni e giochi per il C64 e col quale creo i listati degli altri post.

Non ci saranno descrizioni tecniche dei singoli applicativi, per quelle rimando
alle numerose documentazioni disponibili in rete che spiegano bene e in modo
esaustivo (sicuramente più di quanto potrei fare io) come installare e
configurare i software.

In questa guida, quindi, saranno elencati solo i vari software che utilizzo, 
divisi tra software indispensabili e consigliati, con eventuali descrizioni per 
farli funzionare insieme.

Nell'elenco sottostante ci sono anche dei punti indicati con *[TBD]* (cioè To 
Be Done), verranno discussi in un altro post e non sono fondamentali per lo
sviluppo di base.

Potrei dedicare (FORSE) un ulteriore post su come solitamente strutturo le mie
applicazioni, cioè impostazione e suddivisione dei file, trattamento delle 
risorse e cose di questo tipo, più eventualmente altre info sulla gestione tipo 
di un progetto (issue, bug, Kanban board, branching con Git ecc...).

Questi ultimi elementi possono sembrare una sovraingegnerizzazione (e in
effetti per progetti molto piccoli e/o semplici lo è) ma mi sembra interessante
esporre qualche regola minima per organizzare il lavoro, poi ognuno in coscienza
valuta quali elementi mettere in atto.

## Introduzione

Gli elementi che utilizzo nello sviluppo delle mie applicazioni sono:
* Visual Studio Code &#x1F534;
* JDK &#x1F534;
* Kick Assembler &#x1F534;
* Kick Assembler 8-Bit Retro Studio Extension &#x1F534;
* Vice emulator &#x1F534;
* C64Debugger &#x1F535;
* SpritePad Free &#x1F7E0;
* CharPad Free &#x1F7E0;
* SidSfx Editor &#x1F7E0;
* Account GitHub &#x1F7E1; *[TBD]*
* GitHub Pull Requests and Issues Extension &#x1F7E1; *[TBD]*
* Account Circle.Ci &#x1F7E2; *[TBD]*
* Gradle Build &#x1F7E2; *[TBD]*

Gli elementi con il simbolo &#x1F534; sono da considerarsi come il minimo
necessario per l'ambiente di sviluppo. L'unico elemento con classificazione
&#x1F535; è consigliato ma, dato che è piuttosto ostico, benché utile, non
lo inserisco tra gli elementi necessari.

Gli elementi del gruppo &#x1F7E0; sono utili per la creazione delle risorse 
grafiche e sonore utilizzate nel progetto.

Gli elementi del gruppo &#x1F7E1; consentono di interfacciare l'ambiente con
GitHub al fine di poter gestire il versionamento (ed eventualmente la
condivisione del codice sorgente in pubblico, gestione delle issue ecc...).

Gli elementi del gruppo &#x1F7E2; consentono di collegare la repository su
GitHub ad una pipeline CI/CD su Circle.Ci.

## Ambiente di lavoro base &#x1F534;

L'ambiente di lavoro base per lo sviluppo si compone di un editor (VS Code), 
di un assembler (KickAssembler, che a sua volta necessita di un JDK per
funzionare), l'estensione Kick Assembler 8-Bit Retro Studio che facilita la
scrittura del codice e aggiunge alcune scorciatoie molto utili per lo sviluppo 
e, infine, di un emulatore su cui vedere i frutti del proprio lavoro (Vice).

A questa serie di elementi, aggiungo anche un debugger (C64Debugger che ho 
indicato con &#x1F535;) che, ammetto essere un applicativo piuttosto complicato
da digerire, può tornare utile per capire come si sta comportando il nostro
programma. Scaricabile da [qui](https://sourceforge.net/projects/c64-debugger/).

### Visual Studio Code
Per prima cosa si procede all'installazione, per chi non lo avesse già, 
dell'IDE, cioè di Visual Studio Code (https://code.visualstudio.com/). 
L'IDE (Integrated Development Environment) è il software che consente di 
scrivere il codice sorgente della nostra applicazione.

![Visual Studio Code da Wikipedia](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/VS_Code_%28Insiders%29.png/640px-VS_Code_%28Insiders%29.png)

In precedenza ho utilizzato Sublime Text ma ho cambiato da un po' per la 
migliore facilità di utilizzo data dalle estensioni disponibili.

### KickAssembler
Al termine dell'installazione dell'IDE, possiamo procedere a installare 
l'assembler che prende il nostro codice sorgente e genera i file da lanciare
nell'emulatore. Il nostro assembler si chiama KickAssembler ma, per funzionare,
è prima necessario installare Java. 

Quindi, come prima cosa, si installa il JDK scaricabile a [questo indirizzo](https://www.oracle.com/java/technologies/downloads/).

Successivamente si può procedere all'installazione di KickAssembler,
da [questo link](http://theweb.dk/KickAssembler/KickAssembler.zip)
si scarica l'ultima versione disponibile.
Dopo aver scaricato l'archivio, lo si deve decomprimere in una cartella, ad 
esempio *C:\\C64\\Tools\\KickAssembler\\*.
Per verificare che l'operazione è stata eseguita correttamente, nella cartella
sopraindicata, dovrà essere presente il file KickAss.jar - e altri file).

Se l'installazione di KickAssembler è andata a buon fine, si può procedere con
l'estensione per Visual Studio Code. 
E' sufficiente ricercare l'estensione *Kick Assembler 8-Bit Retro Studio* nello store

![Estensione per VisualStudio Code](/resources/kick-assembler-extension.png)

Successivamente è necessario modificare alcune opzioni dell'estensione:
* Kickassembler › Assembler: Jar, deve puntare al file kickass.jar, installato
in precedenza.
* Kickassembler › Assembler Library Paths, contiene la lista dei path in cui
sono installate le eventuali librerie. Inizialmente è vuoto.
* Kickassembler › Debugger: Runtime, punta all'eseguibile del debugger, se
è stato installato
* Kickassembler › Emulator: Runtime, punta all'eseguibile dell'emulatore Vice,
lo installeremo tra poco quindi si può inserire questo dato successivamente.
* Kickassembler › Java: Runtime, punta al file java.exe del JDK.

### Vice emulator

Vice è uno tra gli emulatori più conosciuti, supporta diverse macchine Commodore
(64, Vic20, 128 ecc...). Scaricabile [qui](https://vice-emu.sourceforge.io/)

Ricordarsi di impostare il path di installazione di Vice tra le opzioni
dell'estensione di Kickassembler.

### Test

Con questa serie di opzioni impostate, si può eseguire un piccolo programma di 
test per assicurarsi che tutto, fino a qui, sia definito correttamente.

Quindi, all'interno di VS Code, inserire questo piccolo codice dentro un file
.asm.

```
BasicUpstart2($0810)

* = $0810 "Entry"
Entry: {
    lda #RED
    sta $d020
    rts
}
```

Se tutto è impostato correttamente, la scrittura del listato qui sopra e la 
sua successiva compilazione tramite la pressione del tasto F6, produrrà un file
*.prg, che verrà lanciato in Vice e, come risultato, si vedrà il bordo
colorato di rosso.

## Risorse del progetto &#x1F7E0;

Di seguito ho indicato tre applicazioni per creare autonomamente le risorse da
utilizzare nel progetto.
Nessuno vieta ovviamente di cercare delle risorse già realizzate e di adattarle
alle proprie necessità, non entro nel merito di questa soluzione.
Le applicazioni sono le seguenti:
* CharPad Free
* SpritePad Free
* SidSfx Editor

### CharPad Free

E' il software che consente di creare charset personalizzati e mappe.

![CharPad Free](/resources/charpad-main-screen.png)

La versione Free è scaricabile a
[questo indirizzo](https://subchristsoftware.itch.io/charpad-free-edition)
e risulta sufficiente per la maggior parte delle necessità.

### SpritePad Free

Consente la creazione degli sprite da utilizzare nel progetto. Permette anche 
l'organizzazione di gruppi di sprite per produrre le animazioni.

![SpritePad Free](/resources/spritepad-main-screen.png)

Anche in questo caso, la versione Free è sufficiente per l'utilizzo base ed è
scaricabile [qui](http://csdb.dk/release/download.php?id=163858).

### SidSfx Editor

Ho scoperto questo software da poco ed è una figata mostruosa! Permette di creare
dei brevi effetti audio da associare al progetto. Non sto parlando delle colonne 
sonore, per quello vi rimando ad altri software, tipo GoatTracker.

![SidSfx Editor](/resources/sidsfx-main-screen.png)

Solitamente creo l'effetto che mi interessa e poi lo esporto come file asm e lo
integro nel progetto.
Scaricabile [qui](https://agpx.itch.io/sid-sfx-editor).

## Conclusione

Come scritto nell'introduzione, volutamente NON ho inserito tutorial su come 
utilizzare questi software.
Sto semplicemente esponendo come è composto il mio ambiente di
sviluppo. Per informazioni di questo tipo vi invito a leggere la (tanta)
documentazione a riguardo.

Per ora mi fermo qui, nel prossimo post vedremo i software non necessari, 
marchiati con &#x1F7E1; e &#x1F7E2;.

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/community)!

Le discussioni più interessanti verranno aggiunte qui.
