---
layout: post
title: The bit trick
tags: opcode bit bit-trick commodore-64 commodore-128 assembly
---

Let's take this snippet:
``` Assembly
STEP1:  LDX #$10
        JMP END

STEP2:  LDX #$20
        JMP END

STEP3:  LDX #$30

END:    LDA #$12
        STA $1000,X

// Total bytes: 5 + 5 + 2 + 5 = 17
// Total cycles: 12
```
There are three entrypoint used for setting .X register as index for the
last <code>STA</code> instruction. These instructions uses 17 bytes and
requires 17 cycles (when jmuping on STEP1 or STEP2).

A first optimization consist in changing <code>JMP END</code>, which is
3by/3cy, with a BNE (because all there LDX don't set zero-flag)
which is 2by/2cy. Code is modified:

``` Assembly
STEP1:  LDX #$10
        BNE END

STEP2:  LDX #$20
        BNE END

STEP3:  LDX #$30

END:    LDA #$12
        STA $1000,X

Total bytes: 4 + 4 + 2 + 5 = 15
Total cycles: 10
```
A total of 2 bytes and 2 cycles were saved with this trick.
This is good but:
- when using <code>LDX</code> with #$0, BNE should be changed with BEQ
- branch can be up to 127 byte ahead

There is another particular trick that can be used to reduce size (but
increase cycles count). It's known as BIT trick and it's
often used in Kernal code to avoid jump.

From [C64-wiki](https://www.c64-wiki.com/wiki/BIT_(assembler)):
<cite>
BIT (short for "BIT test") is the mnemonic for a machine language instruction which tests specific bits in the contents of the address specified, and sets the zero, negative, and overflow flags accordingly, all without affecting the contents of the accumulator.
Bit 7 (weight 128/$80; the most sigificant bit) is transferred directly into the negative flag.
Bit 6 (weight 64/$40) is transferred directly into the overflow flag.
A bit-wise "and" is performed between the contents of the designated memory address and that of the accumulator; if the result of this is a zero byte, the zero flag is set.
</cite>

This is the code that use <code>BIT</code> instead of
<code>JMP</code> or <code>BNE</code>.

``` Assembly
STEP1:  LDX #$10
        .BYTE $2C

STEP2:  LDX #$20
        .BYTE $2C

STEP3:  LDX #$30

STEP4:  LDA #$12
        STA $1000,X

Total bytes: 3 + 3 + 2 + 5 = 13
Total cycles: 17
```
This can be quite difficult to understand. So let's assemble this code to
see how mnemonic is converted to opcode:
``` Opcode
A2 10     LDX #$10
2C        .BYTE $2C
A2 20     LDX #$20
2C        .BYTE $2C
A2 30     LDX #$30
A9 12     LDA #$12
9D 00 10  STA $1000,X
```
Ok, now let's see what's happens when a <code>JMP STEP1</code> is performed.
``` Assembly
A2 10     LDX #$10      // .X is loaded with $10

2C A2 20  BIT $20A2     // A2 20 is LDX #$20 but is interpreted as address for
                        // BIT. BIT won't affect .X value

2C A2 30  BIT $30A2     // A2 30 is LDX #$30 but is interpreted as address for
                        // BIT. BIT won't affect .X value

A9 12     LDA #$12      // .A is loaded with $12
9D 00 10  STA $1000,X   // .X is still $10
```

By using $2C (which correspond to <code>BIT $nnnn</code>) 2 bytes can be
skipped, but also $24 can be used (which correspond to <code>BIT $nn</code>) to
skip one byte.

This is a particular technique to avoid jumping but you must be aware that:
- some flags will be changed by <code>BIT</code> opcode
- it uses more cycle so speed should not be a requirement

As said before, this trick is heavily used in kernal, for example look at
**Handles Kernal I/O errors** at
[$F67C](https://c128lib.github.io/Reference/E000#F67C) in C128 Kernal.

This is a snippet:
```Opcode
// Print 'too many files'
F67C: A9 01	LDA #$01
F67E: 2C	.BYTE $2C

// Print 'file open'
F67F: A9 02	LDA #$02
F681: 2C	.BYTE $2C

// Print 'file not open'
F682: A9 03	LDA #$03
F684: 2C	.BYTE $2C

// Print 'file not found'
F685: A9 04	LDA #$04
F687: 2C	.BYTE $2C

// Print 'device not present'
F688: A9 05	LDA #$05
F68A: 2C	.BYTE $2C

// Print 'not input file'
F68B: A9 06	LDA #$06
F68D: 2C	.BYTE $2C

// Print 'not output file'
F68E: A9 07	LDA #$07
F690: 2C	.BYTE $2C

// Print 'missing file name'
F691: A9 08	LDA #$08
F693: 2C	.BYTE $2C

// Print 'illegal device no'
F694: A9 09	LDA #$09
F696: 2C	.BYTE $2C

// Error #0
F697: A9 10	LDA #$10
F699: 48	PHA
...
```
