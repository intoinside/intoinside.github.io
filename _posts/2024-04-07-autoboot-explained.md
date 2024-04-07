---
layout: post
title: Autoboot explained
tags: commodore-128 autoboot boot
---

C128 has a particular feature for autoboot.

{% include note.html note_content="Autoboot feature is for C128 only, not supported on C64" %}

When the c128 starts up, it performs a series of checks to decide
the operating mode. In particular, it checks in the following order:
* the presence of a cartridge
* the request to start in C64 mode (if the Commodore button was pressed)
* starting the machine language monitor

If you want to see how cold start is performed, see [this page on Reference](https://c128lib.github.io/Reference/StartupSequence).

If none of these conditions are met, the C128 checks whether a disk is
inserted in the drive and searches for the boot sector by reading
track 1 sector 0 into buffer at $B00.

Then the process is handled by Kernal subroutine called BOOTCALL at
[$FF53](https://c128lib.github.io/Reference/FF47#FF53).

{% include note.html note_content="BOOTCALL requires parameters to be set, check documentation" %}

|Byte|Content|Description|
|-|-|-|
|$00 $01 $02|Signature|Autoboot signature "CBM"|
|$03 $04|Address low Address high|Address at which the contents of additional boot sectors are to be stored|
|$05|Bank|Bank for additional sector|
|$06|Count|Number of additional sectors to load|
|$07|Boot message|Booting message to show null terminated|
|$08 + (boot-message-length)|Program name|Program to load null terminated|
|$09 + (boot-message-length) + (program-name-length) .. $ff|Loader code|Loader code padded with $00|

Subroutine checks if there is a valid signature (which is "CBM"), if not a `rts` is performed.
The test is performed using the [$E2C4](https://c128lib.github.io/Reference/E000#E2C4)
location which contains the pattern to be tested.

A "BOOTING" string is printed on screen then some bytes are read from boot sector:
* $03, $04 are stored in [$AC-$AD](https://c128lib.github.io/Reference/0000#AC) (load address for additional boot sector)
* $05 is stored in [$AE](https://c128lib.github.io/Reference/0000#AE) (bank number)
* $06 is stored in [$AF](https://c128lib.github.io/Reference/0000#AF) (additional boot sector to load)

Subsequent bytes are printed to screen until a null char is found or until
the end of the sector is reached. Following the message, three dots are
printed.

![Booting message](/resources/booting-message.png)

The bank number for boot data is transferred into the working bank
number location [$C6](https://c128lib.github.io/Reference/0000#C6).

If the value in $AF is non zero, then additional data is read sequentially
from boot sector in the specified bank at the address specified by $AC-$AD,
starting from sector 1 of track 1.

After all bytes are read, the drive is reset. The routine
then searches the buffer from the zero byte marking the end
of the message until another byte containing a zero is found.
The characters, if any, between the zero bytes are taken to be
the name of a file to be loaded, and the drive number and a
colon are placed immediately before the name in the buffer. If
a filename is found, the routine attempts to load a file with
that name into bank 0. Because the Kernal
[LOAD](https://c128lib.github.io/Reference/FF47#FFD5)
routine is used, this file must be PRG (program) type. This file is always
loaded into bank 0, regardless of the bank number specified
for boot sectors.

After the file is loaded (or if no filename is specified), the
[JSRFAR](https://c128lib.github.io/Reference/FF47#FF6E) address pointer
([$03-$04](https://c128lib.github.io/Reference/0000#03))
holds the address of the buffer location following the end-of-filename zero
byte, and the JSRFAR bank ([$02](https://c128lib.github.io/Reference/0000#02))
is set for bank 15. The JSRFAR routine is then used to execute the machine
language subroutine following the filename in the boot sector buffer.
Some machine language code must be present, even if it's only an
`rts` opcode. Finally, the routine exits with the status register
carry bit clear.
