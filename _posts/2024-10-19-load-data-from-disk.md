---
layout: post
title: Load data or code from disk
tags: 8-bit computer load kernal commodore commodore-128 commodore-64
---

Reading code from disk can be useful when you want to develop a project of a certain size.
Often you find yourself not having all the memory space necessary for the project so it is necessary to break it up.
At the right time, a routine can be called to read the code from disk and load it into memory.
Subsequently the new code will be called and the program execution can continue.
It is necessary to design the program structure and the memory areas involved well, preserving any portions of code or data that must always be present during execution.

It all revolves around the Kernal <code>JLOAD</code> call that does the actual loading. Before calling it, however, you need to make some preliminary calls and set several parameters.

The first call to make is to the <code>JSETNAM</code> routine that sets the name of the file on disk to load.

The routine expects parameters in the three registers .A, .X, .Y.

In .A you must enter the length of the file name to load.
In .X and .Y you must enter the memory address that contains the name of the file to load (in .X goes the low-byte while in .Y goes the hi-byte).

``` Assembly
    lda #$ff
    ldx #$be
    ldy #$ef
    jsr $FFBD
```

Next, you need to call the <code>JSETBNK</code> routine that sets the memory bank used to provide the parameters and to receive the read code.
In .A, you need to insert the number of the bank for the parameters, while in .X, you need to insert the number of the bank where the data will be written.

``` Assembly
    lda #00
    tax
    jsr $FF68
```

The last preparatory routine to call is <code>JSETLFS</code> which is used to specify the logical file number, the device number and the secondary address for I/O operations.
In .A you enter the logical file number, in .X you enter the device number and in .Y you enter the secondary address for I/O operations.

``` Assembly
    lda #00
    ldx #08
    ldy #01
    jsr $FFBA
```

Finally, it is possible to call the <code>JLOAD</code> routine that performs the disk reading.
The routine can perform a read or a check and this option must be specified via the .A register
In .A the value 0 must be inserted, any other value would activate the check function.

``` Assembly
    lda #00
    jsr $FFD5
```

The routine will now read the specified file and write it to memory. But where will it be written? First, the first two bytes of the file will be read, which contain the absolute address to load. After that, the reading will continue with the rest of the file, and all the contents will be positioned starting from the address read before.

Note that <code>JLOAD</code> returns the result of the reading in the Carry bit: if it is set, it means that an error occurred during the reading or that <code>RUN/STOP</code> was pressed to stop the operation. In this case, the .A register contains the error code.

Below is the entire routine and a macro I use to set parameters more conveniently and to make the code reusable.
The self-modifying code technique is widely used, which explains the abundance of labels within the routine and the use of the $be and $ef values ​​(for debugging enthusiasts who use $beef to understand whether the self-modifying code has been activated or not).

``` Assembly
.macro LoadFile(Level1FileNameLength, Level1FileName) {
    lda #Level1FileNameLength
    sta LoadFile.FilenameSize + 1
    lda #<Level1FileName
    sta LoadFile.FilenameLowByte + 1
    lda #>Level1FileName
    sta LoadFile.FilenameHighByte + 1
    jsr LoadFile
}

LoadFile: {
  FilenameSize:
    lda #$ff
  FilenameLowByte:
    ldx #$be
  FilenameHighByte:
    ldy #$ef
    jsr $FFBD
    lda #00
    tax
    jsr $FF68
    lda #00
    ldx #08
    ldy #01
    jsr $FFBA
    lda #00
    jsr $FFD5
}
```

As a final note, remember to transfer control to the loaded code. A simple <code>JMP</code> will do.

``` Assembly
    LoadFile(Level1FileNameLength, Level1FileName)
    JMP $4000   // Supposing that $4000 is the absolute address of the code loaded
```

A coupling problem is highlighted that requires knowing in advance the absolute address on which the code will be read and inserted. This address is read by the JLOAD but is not exposed so it is necessary to follow a different approach.

Instead of the JLOAD, it is necessary to read the first two bytes to build the absolute address. Then, one byte at a time must be read until the end of the file, writing the read code in the address read before each time.
It is a longer procedure to write and subject to errors but it allows us to obtain the absolute address and make it available externally.
