---
layout: post
title: Sprite multiplexing - organizzare
---

## Premessa
Ho fatto un po' di ricerche e analizzato varie soluzioni. Quello che propongo è
un'interpretazione di una possibile soluzione per gestire più di 8 sprite a video,
**non è LA soluzione** ma solo una delle tante. Prendete spunto, elaborate o
ignorate ciò che vedrete d'ora in poi. Si tratta del mio punto di vista, nulla
di più. Detto questo, vi invito a inviare suggerimenti o controproposte.

Ho preso del codice su GitHub (a breve il link) e l'ho un po' analizzato
cercando di renderlo più semplice da comprendere, spero di esserci riuscito.

## Idea di base
Come esposto nelle conclusioni dei post precedenti, se vogliamo andare oltre ai
canonici 8 sprite hardware, si deve ingannare l'utente sfruttando le capacità
grafiche del sistema.

Il risultato è ottenuto utilizzando l'interrupt raster in prossimità della
coordinata Y a cui vogliamo disegnare gli sprite. Di fatto lo stesso sprite 
viene spostato continuamente da una posizione all'altra durante il disegno di
ogni immagine.
Il meccanismo diventa complesso perché il nostro programma deve farsi carico di
tenere traccia di tutti gli sprite da visualizzare (che d'ora in poi 
chiameremo sprite "virtuali"), non potendo fare affidamento ai registri 
destinati a tracciare gli 8 in hardware.

Si tratta quindi di fare un lavoro di collaborazione tra il main program e 
l'interrupt (d'ora in poi irq) raster:
* il main si deve occupare della logica del programma e del posizionamento (ma 
anche colore, dimensioni, forma ecc... insomma, qualunque aspetto di qualunque 
sprite del programma).
Deve sostanzialmente specificare come devono funzionare le cose.
* l'interrupt raster si deve occupare della visualizzazione, in particolare 
della mappatura degli sprite virtuali sugli 8 sprite hardware.

Il main farà l'init di tutte le variabili utilizzate, degli sprite e preparerà
il lancio dell'irq raster. Inoltre, a scopo didattico, nel corso del 
programma, muoverà gli sprite in modo casuale.

Saranno presenti due routine legate agli irq raster:
* una si occuperà di ordinare gli sprite in base alla coordinata Y (nel corso 
del post spiegheremo perché)
* un'altra si occuperà di visualizzare gli sprite e partirà su più scanline in
base agli sprite da visualizzare.

Bene, con il sufficiente grado di casino generato da queste righe, iniziamo a 
dire qualcosa sul main program.

## Funzioni accessorie

Definiamo intanto la subroutine che prepara il lancio dell'irq raster, molte 
delle cose sono già state viste nelle puntate precedenti. Notimo solo la 
scanline di lancio impostata a *IrqSortingLine* (una label pari a $fc => 252):
```
InitRaster: {    
    sei
    lda #<IrqSorting
    sta $0314
    lda #>IrqSorting
    sta $0315
    lda #$7f           
    sta $dc0d
    lda #$01           
    sta $d01a
    lda #27            
    sta $d011
    lda #IrqSortingLine
    sta $d012
    lda $dc0d          
    cli
    rts
}
```

Definiamo inoltre una macro e una subroutine per la generazione di numeri casuali:
```
.macro GetRandomNumberInRange(minNumber, maxNumber) {
    lda #minNumber
    sta GetRandom.GeneratorMin
    lda #maxNumber
    sta GetRandom.GeneratorMax
    jsr GetRandom
}

GetRandom: {
  Loop:
    lda $d012
    eor $dc04
    sbc $dc05
    cmp GeneratorMax
    bcs Loop
    cmp GeneratorMin
    bcc Loop
    rts

    GeneratorMin: .byte $00
    GeneratorMax: .byte $00
}
```
La subroutine *GetRandom* genera un numero casuale (leggendo la scanline corrente)
e si assicura che sia tra due valori limite. La macro permette di impostare i
due valori limite prima di richiamare la subroutine.

Di seguito un'altra macro per impostare lo stato iniziale degli sprite virtuali:
```
.macro InitSpritesData() {
    ldy #1
    dex
  initloop:
    GetRandomNumberInRange(25, 255)
    sta sprx,x
    jsr GetRandom
    sta spry,x
    lda #$3f
    sta sprf,x
    tya
    sta sprc,x
    iny
    cpy #16
    bne nextcolorok
    ldy #1
  nextcolorok:
    dex
    bpl initloop
}
```
Come vedere qui si fa uso della subroutine *GetRandom* vista prima. Qui si 
impostano le posizioni iniziali x e y degli sprite virtuali inserendole nei
vettori *sprx* e *spry*. Poi si imposta la struttura degli sprite recuperandola
dall'area di memoria in cui è definito ($3f) e inserendola in *sprf*
Infine si imposta il colore di ogni sprite in *sprc*. Il colore deve essere 
diverso da nero altrimenti si confonde con lo sfondo.

## Main program

Ed ecco finalmente il main in tutto il suo splendore:
```
Start: {
    jsr InitSprites
    jsr InitRaster
    lda #00
    sta $d020
    sta $d021
    ldx #MAXSPR    
    stx numsprites

    InitSpritesData()

  MainLoop:        
    inc SpriteUpdateFlag

  MoveLoop:
    txa
    lsr
    lsr
    lsr
    adc sprx,x
    sta sprx,x

    lda Direction
    eor #$ff
    bpl rewind
    inc spry,x
    jmp EndLoop

  rewind:
    dec spry,x

  EndLoop:
    sta Direction
    dex
    bpl MoveLoop

    jmp MainLoop

  Direction:  .byte 0
}
```
Come si può notare, tutta la parte precedente a *MainLoop* è dedicata 
all'inizializzazione del programma. La label *MAXSPR* indica il numero massimo
di sprite da generare.
Terminata la parte di init, inizia il *MainLoop* del programma che viene 
ripetuto all'infinito.

La prima cosa che viene fatta all'inizio di un nuovo loop è assicurarsi
del corretto ordinamento degli sprite nel vettore. Non è questo il posto dove 
viene eseguita questa operazione bensì nel *IrqSorting*. Perciò, al main, non 
resta che richiedere un'ordinamento (impostando a 1 la variabile "guardia" 
*SpriteUpdateFlag*) e attendere che questo venga fatto nell'apposito irq (che
provvederà a resettare la guardia a lavori terminati).

Supponendo di aver ottenuto il via libera per procedere, ora il main si 
incarica di muovere gli sprite, e lo fa:
* per x, aggiungendo un valore pari a x / 8
  * trasferisco x su a, eseguo tre volte *lsr* (shift logico a destra che 
  equivale a dividere per 2)
* per y, aggiungendo o togliendo 1 alla coordinata y precedente
Il procedimento viene ripetuto per tutti gli sprite dopodichè si ritorna a
*MainLoop* e si ricomincia da capo.

In un programma serio e non didattico come questo, il posizionamento può essere 
determinato da una funzione più raffinata, oppure può dipendere da cosa viene
premuto sulla tastiera o da come viene utilizzato il joystick. Inoltre ci sarebbe
tutta la logica di funzionamento. Qui ovviamente non c'è niente di tutto ciò,
l'importante è capire la suddivisione del codice e quali parti hanno i diversi compiti.

Bene, ora veniamo ai due pezzi più importanti nonché complicati. Il primo dei
due è la subroutine del Irq raster di ordinamento degli sprite e parte sulla
scanline 252, ben oltre lo spazio visibile.

## Ragionamenti teorici su ordinamento e visualizzazione
E perché mai si rende necessario riordinare gli sprite?
Innanzitutto diciamo che con "ordinamento degli sprite" si indende la lettura
degli sprite dagli array che ne contengono la posizione (*spry*, *sprx* ecc.) e
la creazione di altrettanti array ordinando per la posizione y.
La subroutine inserirà gli sprite in ordine da quelli che si trovano più in
alto a quelli che si trovano più in basso.

![Sprite](/resources/irq-sprite-disegnato.png)

Questo ordinamento serve a semplificare il lavoro della subroutine che disegnerà
gli sprite sullo schermo.
La subroutine di disegno ha poco tempo per lavorare (circa 63 cicli di clock per
ogni scanline - se volete capire il perchè di questo numero vi lascio il link
di questo post su [Lemon64](https://www.lemon64.com/forum/viewtopic.php?t=71390&sid=a0e7eca10fd18beae6e00a8e63cb8152))
e perciò deve avere già tutto pronto per visualizzare.

Nel suo scorrere dall'alto al basso, la subroutine di disegno deve solo 
disegnare gli sprite che si trovano sulla scanline corrente. Se non ci fosse la
fase di ordinamento, ad ogni scanline dovrebbe verificare quale sprite, tra tutti
quelli presenti, deve essere disegnato nella scanline corrente. Ci vuole tempo
per questa verifica, tempo che non c'è, quindi l'ordinamento è necessario.

Il lavoro di ordinamento quindi viene eseguito quando la scanline è oltre lo 
schermo visibile, partendo quindi come detto prima sulla linea 252.
Anche qui non c'è tutto il tempo del mondo ma sicuramente possiamo fare le cose
con relativa calma in modo da essere pronti al prossimo rendering.

Naturalmente, l'ordinamento gestirà oltre alla posizione y (nell'array *sortspry*)
anche la posizione x (*sortsprx*), terrà traccia del colore (*sortsprc*)
e del puntatore all'immagine da mostrare (*sortsprf*).
Nel codice del irq c'è anche l'impostazione della scanline a cui deve essere
lanciato l'irq raster, che raccoglierà gli array ordinati e disporrà la 
visualizzazione.

### Ordinamento
```
IrqSorting: {
    dec $d019
    lda #RED
    sta $d020
    lda #$ff                        // Spostamento di tutti gli sprite
    sta $d001                       // in un'area invisibile per evitare
    sta $d003                       // strani/brutti effetti visivi
    sta $d005
    sta $d007
    sta $d009
    sta $d00b
    sta $d00d
    sta $d00f

    lda SpriteUpdateFlag            // Sprite da ordinare?
    beq irq1_nonewsprites
    lda #$00
    sta SpriteUpdateFlag
    lda numsprites                  // Prendiamo il numero di sprite
    sta SortedSprites               // Se zero non c'è bisogno di 
    bne irq1_beginsort              // ordinare

  irq1_nonewsprites:
    ldx SortedSprites
    cpx #$09
    bcc irq1_notmorethan8
    ldx #$08
  irq1_notmorethan8:
    lda d015tbl,x                   // Abilita gli sprite da mostrare
    sta $d015
    beq irq1_nospritesatall
    lda #$00                        // Preparazione dell'irq di display
    sta sprirqcounter
    lda #<IrqDisplay 
    sta $0314
    lda #>IrqDisplay
    sta $0315
    jmp IrqDisplay.irq2_direct      // Se non c'è niente da ordinare vado
                                    // subito alla routine di display
  irq1_nospritesatall:
    lda #BLACK
    sta $d020

    jmp $ea81

  irq1_beginsort: 
    ldx #MAXSPR
    dex
    cpx SortedSprites
    bcc irq1_cleardone
    lda #$ff                        // Imposta gli sprite inutilizzati con
  irq1_clearloop: 
    sta spry,x                      // la coordinata Y $ff
    dex                             // finiranno così in fondo all'array
    cpx SortedSprites               // ordinato
    bcs irq1_clearloop
  irq1_cleardone: 
    ldx #$00
  irq1_sortloop:  
    ldy sortorder+1,x               // Codice di ordinamento, algoritmo
    lda spry,y                      // preso da Dragon Breed -)
    ldy sortorder,x
    cmp spry,y
    bcs irq1_sortskip
    stx irq1_sortreload+1
  irq1_sortswap:   
    lda sortorder+1,x
    sta sortorder,x
    sty sortorder+1,x
    cpx #$00
    beq irq1_sortreload
    dex
    ldy sortorder+1,x
    lda spry,y
    ldy sortorder,x
    cmp spry,y
    bcc irq1_sortswap
  irq1_sortreload: 
    ldx #$00
  irq1_sortskip:   
    inx
    cpx #MAXSPR-1
    bcc irq1_sortloop
    ldx SortedSprites
    lda #$ff                       // $ff è l'indicatore di fine per 
    sta sortspry,x                 // la routine
    ldx #$00
  irq1_sortloop3:  
    ldy sortorder,x                // Giro finale
    lda spry,y                     // Copia delle variabili nell'array
    sta sortspry,x                 // ordinato
    lda sprx,y
    sta sortsprx,x
    lda sprf,y
    sta sortsprf,x
    lda sprc,y
    sta sortsprc,x
    inx
    cpx SortedSprites
    bcc irq1_sortloop3
    jmp irq1_nonewsprites
}
```
Devo essere onesto, l'algoritmo è complesso e non ci ho dedicato molto tempo per
capirlo e sviscerarlo. Se, come me, preferite restarne fuori e prenderlo come
un dogma, basta sapere che al termine dell'elaborazione, troveremo gli array
di sort (cioè tutti quelli che iniziano con sort*) pronti per essere utilizzati
nella fase di visualizzazione.

Nello sviluppo di un gioco, tendenzialmente, questa subroutine e quella 
successiva di display non ne farei oggetto di modifiche. Mi concentrerei 
piuttosto sulla logica e sulle regole che governano tutto.

### Visualizzazione
```
IrqDisplay: {          
    dec $d019
    lda #GREEN
    sta $d020
  irq2_direct:     
    ldy sprirqcounter               // Legge il numero del prossimo sprite
    lda sortspry,y                  // Legge la coordinata y
    clc
    adc #$10                        // Calcola 16 linee a partire dalla y
    bcc irq2_notover                // che saranno il termine di questo irq
    lda #$ff                        // Il termine deve essere entro $ff
  irq2_notover:   
    sta tempvariable
  irq2_spriteloop: 
    lda sortspry,y
    cmp tempvariable                // Irq terminato?
    bcs irq2_endspr
    ldx physicalsprtbl2,y
    sta $d001,x          
    lda sortsprx,y
    asl
    sta $d000,x
    bcc irq2_lowmsb
    lda $d010
    ora ortbl,x
    sta $d010
    jmp irq2_msbok
  irq2_lowmsb:    
    lda $d010
    and andtbl,x
    sta $d010
  irq2_msbok:     
    ldx physicalsprtbl1,y     
    lda sortsprf,y
    sta $07f8,x               
    lda sortsprc,y
    sta $d027,x
    iny
    bne irq2_spriteloop
  irq2_endspr:    
    cmp #$ff                        // Raggiunto il termine?
    beq irq2_lastspr
    sty sprirqcounter
    sec                             // L'ultima coordinata - $10 è lo start
    sbc #$10                        // del nuovo irq
    cmp $d012                       // Se siamo in ritardo, andiamo subito
    bcc irq2_direct                 // al prossimo irq
    sta $d012
    lda #BLACK
    sta $d020
    jmp $ea81

  irq2_lastspr:  
    lda #<IrqSorting                // Gestito l'ultimo sprite
    sta $0314                       // Si prepara un nuovo sort
    lda #>IrqSorting                
    sta $0315
    lda #IrqSortingLine
    sta $d012
    lda #BLACK
    sta $d020
    jmp $ea81
}
```
Questo è il listato della subroutine che esegue la visualizzazione degli sprite.
C'è tanta roba quindi analizziamola con calma.

La prima istruzione esegue la conferma del lancio del Irq, segue poi un cambio 
di colore bordo in verde.
Serve a indicare a video, a scopo di debug, quando l'irq è partito. Lo stesso
meccanismo era presente nella subroutine di ordinamento.

Il funzionamento in generale è quello di posizionare, ad ogni scanline, tutti 
gli sprite che si trovano nelle vicinanze. Una volta che il gruppo di sprite
vicini è stato disegnato, l'algoritmo valuta se lanciare un irq su una nuova 
scanline più in basso o se lanciare un irq di sorting (nel caso in cui tutti
gli sprite siano già stati disegnati).

Il primo blocco prende lo sprite che deve essere disegnato (il cui indice è 
*sprirqcounter*) e ne recupera la coordinata y. A questa coordinata aggiunge il
valore 16 e il risultato sarà la linea a cui terminerà l'irq. Subito dopo ci si
assicura che la coordinata finale dell'irq non sia oltre 255.

Se lo sprite da disegnare non è oltre alla coordinata finale dell'irq, si 
procede al disegno recuperando coordinate, colori e forma dagli array.
Questo avviene nella parte da *irq2_spriteloop* a *irq2_endspr*.
In questo blocco:
* il registro x "punta" agli sprite fisici (consente quindi di accedere alle
coordinate, al colore e alla forma)
* il registro y contiene l'indice dello sprite virtuale da disegnare

Di seguito (a partire da *irq2_endspr*) si aggiornano gli indici e si verifica
le prossime attività da fare (terminare la subroutine, impostare il prossimo
irq ecc...)

Se la routine ha completato l'ultimo sprite, imposta l'avvio di un nuovo
sorting.

### Ed infine il listato completo

Il programma completo [lo potete trovare qui](/resources/multiplexing.asm).

## Link utili

Vi lascio alcuni link interessanti:
* https://kodiak64.com/blog/toggleplexing-sprites-c64 riguarda uno sviluppatore
che spiega alcune tecniche molto interessanti per gestire tanti sprite 
mostrando la resa grafica delle soluzioni.
* https://codebase64.org/doku.php?id=base:sprite_multiplexing documentazione 
su sprite multiplexing
* https://forums.tigsource.com/index.php?topic=69477.20 thread su un forum 
dove si spiegano gli avanzamenti di un gioco scritto in TRSE, in cui si spiega
la logica per affrontare il multiplexing (quindi applicabile anche ai programmi
in asm).

Se volete chiarimenti su qualche punto di questo post, scrivetemi su
[Gitter](https://gitter.im/intoinside/sprite-multiplexing)!

Le discussioni più interessanti verranno aggiunte qui.
