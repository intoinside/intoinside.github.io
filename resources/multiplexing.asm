
//==============================================================================
//C64 Sprite multiplexing example  
//
//All credit to Lasse Oorni (loorni@student.oulu.fi) for the original code  
//                                                                             
//This routine can run over 32 sprites (change value of 'MAXSPR', and increase 
//the number of entries in the 'Sprite' tables to match).
//                                                                                                      
//First IRQ 'Sorts' the sprites at the bottom of the screen, the second IRQ
//displays them.
//
//Why sorted top-bottom order of sprites is necessary for multiplexing,        
//because raster interrupts are used to "rewrite" the sprite registers         
//in the middle of the screen and raster interrupts follow the                 
//top->bottom movement of the TV/monitor electron gun as it draws each         
//frame.                                                                       
//    
//Formatted to run in the CBM prgStudio IDE -> MARVIN HARDY 2018
//
//==============================================================================



// SYS Call to $1000:

*=$0801

        .byte    $0E, $08, $0A, $00, $9E, $20, $28,  $34, $30, $39, $36, $29, $00, $00, $00

*=              $0fc0
//The Sprite DATA (Enter any single colour sprite code here, to apply to ALL generated sprites):
  .byte 0,0,0
  .byte 124,241,1
  .byte 253,251,1
  .byte 193,131,3
  .byte 193,243,99
  .byte 193,251,246
  .byte 193,155,246
  .byte 253,248,100
  .byte 124,240,100
  .byte 0,0,0
  .byte 12,241,224
  .byte 13,251,240
  .byte 12,27,48
  .byte 12,251,240
  .byte 13,249,224
  .byte 13,131,48
  .byte 13,251,240
  .byte 13,249,224
  .byte 0,0,0
  .byte 0,0,0
                .byte 0,0,0

*=$1000                         //Program start address, first define some constants:

.label IrqSortingLine        = $fc           //This is the place on screen where the sorting
                                //IRQ happens
.label IRQ2Line        = $2a           //This is where sprite displaying begins...

.label MAXSPR          = 16            //Number of sprites

.label numsprites      = $02           //Number of sprites that the main program wants
                                //to pass to the sprite sorter
.label SpriteUpdateFlag   = $03           //Main program must write a nonzero value here
                                //when it wants new sprites to be displayed
.label SortedSprites   = $04           //Number of sorted sprites for the raster
                                //interrupt
.label tempvariable    = $05           //Just a temp variable used by the raster
                                //interrupt
.label sprirqcounter   = $06           //Sprite counter used by the interrupt

.label sortorder       = $10           //Order-table for sorting. Needs as many .bytes
.label sortorderlast   = $2f           //as there are sprites.

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

//Main program
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

  WaitLoop:        
    lda SpriteUpdateFlag
    bne WaitLoop        
    ldx #MAXSPR-1
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

// Routine to init the raster interrupt system
InitRaster: {    
    sei
    lda #<IrqSorting
    sta $0314
    lda #>IrqSorting
    sta $0315
    lda #$7f                        //CIA interrupt off
    sta $dc0d
    lda #$01                        //Raster interrupt on
    sta $d01a
    lda #27                         //High bit of interrupt position = 0
    sta $d011
    lda #IrqSortingLine                   //Line where next IRQ happens
    sta $d012
    lda $dc0d                       //Acknowledge IRQ (to be sure)
    cli
    rts
}

// Routine to init the sprite multiplexing system
InitSprites: { 
    lda #$00
    sta SortedSprites
    sta SpriteUpdateFlag
    ldx #MAXSPR-1
  is_orderlist:
    txa 
    sta sortorder,x
    dex
    bpl is_orderlist
    rts
}

//Raster interrupt 1. This is where sorting happens.
IrqSorting: {
    dec $d019                       //Acknowledge raster interrupt
    lda #RED
    sta $d020
    lda #$ff                        //Move all sprites
    sta $d001                       //to the bottom to prevent
    sta $d003                       //weird effects when sprite
    sta $d005                       //moves lower than what it
    sta $d007                       //previously was
    sta $d009
    sta $d00b
    sta $d00d
    sta $d00f

    lda SpriteUpdateFlag               //New sprites to be sorted?
    beq irq1_nonewsprites
    lda #$00
    sta SpriteUpdateFlag
    lda numsprites                  //Take number of sprites given
                                    //by the main program
    sta SortedSprites               //If itïs zero, donït need to
    bne irq1_beginsort              //sort

  irq1_nonewsprites:
    ldx SortedSprites
    cpx #$09
    bcc irq1_notmorethan8
    ldx #$08
  irq1_notmorethan8:
    lda d015tbl,x                   //Now put the right value to
    sta $d015                       //$d015, based on number of
    beq irq1_nospritesatall         //sprites
                                    //Now init the sprite-counter
    lda #$00                        //for the actual sprite display
    sta sprirqcounter               //routine
    lda #<IrqDisplay                //Set up the sprite display IRQ
    sta $0314
    lda #>IrqDisplay
    sta $0315
    jmp IrqDisplay.irq2_direct         //Go directly// we might be late
  irq1_nospritesatall:
    lda #BLACK
    sta $d020

    jmp $ea81                       //Continue IRQs

  irq1_beginsort: 
    ldx #MAXSPR
    dex
    cpx SortedSprites
    bcc irq1_cleardone
    lda #$ff                        //Mark unused sprites with the
  irq1_clearloop: 
    sta spry,x                       //lowest Y-coordinate ($ff)//
    dex                             //these will "fall" to the
    cpx SortedSprites               //bottom of the sorted table
    bcs irq1_clearloop
  irq1_cleardone: 
    ldx #$00
  irq1_sortloop:  
    ldy sortorder+1,x                //Sorting code. Algorithm
    lda spry,y                      //ripped from Dragon Breed -)
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
    lda #$ff                       //$ff is the endmark for the
    sta sortspry,x                 //sprite interrupt routine
    ldx #$00
  irq1_sortloop3:  
    ldy sortorder,x                 //Final loop
    lda spry,y                     //Now copy sprite variables to
    sta sortspry,x                 //the sorted table
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

//Raster interrupt 2. This is where sprite displaying happens

IrqDisplay: {          
    dec $d019                       //Acknowledge raster interrupt
    lda #GREEN
    sta $d020
  irq2_direct:     
    ldy sprirqcounter               //Take next sorted sprite number
    lda sortspry,y                  //Take Y-coord of first new sprite
    clc
    adc #$10                        //16 lines down from there is
    bcc irq2_notover                //the endpoint for this IRQ
    lda #$ff                        //Endpoint canït be more than $ff
  irq2_notover:   
    sta tempvariable
  irq2_spriteloop: 
    lda sortspry,y
    cmp tempvariable                //End of this IRQ?
    bcs irq2_endspr
    ldx physicalsprtbl2,y           //Physical sprite number x 2
    sta $d001,x                     //for X & Y coordinate
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
    ldx physicalsprtbl1,y            //Physical sprite number x 1
    lda sortsprf,y
    sta $07f8,x                     //for color & frame
    lda sortsprc,y
    sta $d027,x
    iny
    bne irq2_spriteloop
  irq2_endspr:    
    cmp #$ff                         //Was it the endmark?
    beq irq2_lastspr
    sty sprirqcounter
    sec                             //That coordinate - $10 is the
    sbc #$10                        //position for next interrupt
    cmp $d012                       //Already late from that?
    bcc irq2_direct                 //Then go directly to next IRQ
    sta $d012
    lda #BLACK
    sta $d020
    jmp $ea81

  irq2_lastspr:  
    lda #<IrqSorting                       //Was the last sprite,
    sta $0314                       //go back to IrqSorting
    lda #>IrqSorting                      //(sorting interrupt)
    sta $0315
    lda #IrqSortingLine
    sta $d012
    lda #BLACK
    sta $d020
    jmp $ea81                       //Continue IRQs
}

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

// SPRITE TABLES:

// Unsorted sprite table
// X position
sprx:           .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// Y position
spry:           .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// Color
sprc:           .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// Frame
sprf:           .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

sortsprx:       .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                   //Sorted sprite table
sortspry:       .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0                //Must be one .byte extra for the
sortsprc:       .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
sortsprf:       .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

// CONSTANTS

d015tbl:        
                .byte  %00000000                  //Table of sprites that are "on"
                .byte  %00000001                  //for $d015
                .byte  %00000011
                .byte  %00000111
                .byte  %00001111
                .byte  %00011111
                .byte  %00111111
                .byte  %01111111
                .byte  %11111111

physicalsprtbl1:
                .byte 0,1,2,3,4,5,6,7            //Indexes to frame & color
                .byte 0,1,2,3,4,5,6,7            //registers
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7
                .byte 0,1,2,3,4,5,6,7

physicalsprtbl2:
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14
                .byte 0,2,4,6,8,10,12,14

andtbl:          .byte 255-1

ortbl:           .byte 1
                .byte 255-2
                .byte 2
                .byte 255-4
                .byte 4
                .byte 255-8
                .byte 8
                .byte 255-16
                .byte 16
                .byte 255-32
                .byte 32
                .byte 255-64
                .byte 64
                .byte 255-128
                .byte 128