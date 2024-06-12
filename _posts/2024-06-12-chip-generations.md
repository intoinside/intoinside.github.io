---
layout: post
title: Chip generations
tags: 6800 6809 68000 68008 6502 6510 8502 processor microprocessor
---

This is a non-complete exposition of the CPUs that were protagonists in the 70-80s. We will see the connections and evolutions of the different architectures and the main computers that have adopted them.

# Motorola/Mos path
<img src="./resources/8bit-comparison-motorola.png" align="left" alt="Motorola path" style="padding: 10px" />

## Motorola 6800
It is the main competitor of the 8080, with equal performance, but with a completely different design philosophy.

## Motorola 6809
The 6809 is an evolution of the 6800, with a more advanced architecture. The 6809 is a CISC processor, with two 8-bit accumulators and a 16-bit address bus. The 6809 is the first microprocessor to have a 16-bit index register.

The 6809 has been used in various systems, including the TRS-80 Color Computer, the Dragon 32 and 64, and the Tandy 1000.

## Motorola 68000
The 68000 derives from 6800, is a processor with 8 32-bit general-purpose registers and a 16-bit address bus. The 68000 is the first microprocessor to have an on-chip memory management unit.

The 68000 has been used in various systems, including the Apple Lisa, the Commodore Amiga, and the Atari ST.

## Motorola 68008
The 68008 is an evolution of the 68000, with a more advanced architecture. The 68008 is a RISC processor, with 8 32-bit general-purpose registers and a 24-bit address bus.

The 68008 has been used in various systems, including the Sinclair QL.

## MOS 6502
The 6502 is a processor with a simple instruction set, it has 3 registers, 8-bit accumulator, 8-bit index register, and 8-bit stack pointer. It was used in the Commodore Vic-20 and PET, Atari 2600, BBC Micro, Nintendo Nes. It's also used on Terminator T-101 and Bender from Futurama.

It's not compatible with 6800.

## MOS 6510
The 6510 is an evolution of the 6502 with an I/O port and a pin for clock. It was used in the Commodore 64.

## MOS 8502
The 8502 is an evolution of the 6510, it's capable to run at 1 or 2 MHz. It was used in the Commodore 128.

# Intel path

<img src="./resources/8bit-comparison-intel.png" align="left" alt="Intel path" style="padding: 10px" />

## Intel 4004
Designed to replace a large number of TTL ICs, the 4004 was a very simple chip that could only handle data in 4-byte groups. It had a 12-bit address bus and addressed up to 640 bytes.

## Intel 8008
The Intel 8008 is an 8-bit microprocessor that was released in 1972. It was the successor to the Intel 4004 and offered significant improvements in terms of performance and capabilities. The 8008 had an 8-bit data bus and a 14-bit address bus, allowing it to address up to 16KB of memory. It also introduced a more advanced instruction set, with support for more complex operations and addressing modes.

Compared to the Intel 4004, the 8008 had a higher clock speed and could execute instructions at a faster rate. It also had a larger addressable memory space, making it more suitable for a wider range of applications. Additionally, the 8008 featured more general-purpose registers, allowing for more efficient data manipulation.

## Intel 8080
The Intel 8080 is an 8-bit microprocessor that was released in 1974. It is the successor to the Intel 8008 and offers several improvements in terms of performance and capabilities. The 8080 has an 8-bit data bus and a 16-bit address bus, allowing it to address up to 64KB of memory. It also introduced a more advanced instruction set, with support for more complex operations and addressing modes.

Compared to the Intel 8008, the 8080 has a higher clock speed and can execute instructions at a faster rate. It also has more general-purpose registers, allowing for more efficient data manipulation. Additionally, the 8080 features improved interrupt handling and supports a wider range of input/output devices.

It was used on Altair 8800.

## Intel 8085
The Intel 8085 is an 8-bit microprocessor that was released in 1976 as an improved version of the Intel 8080.

The 8085 features a higher clock speed and improved instruction execution time compared to the 8080. It also introduces new instructions and addressing modes, providing more flexibility in programming. Additionally, the 8085 includes a built-in serial I/O port, making it easier to interface with external devices.

In terms of compatibility, the 8085 is backward compatible with the 8080, meaning that programs written for the 8080 can run on the 8085 without modification. However, the 8085 offers additional features and improved performance, making it a more advanced choice.

It was used on TRS-80 Model 100.

## Intel 8086
The Intel 8086 is a 16-bit microprocessor that was released in 1978 as an enhanced version of the Intel 8085. It introduced a new architecture known as x86, which became the foundation for modern computer systems.

Compared to the Intel 8085, the 8086 offers several significant improvements. Firstly, it has a wider data bus, allowing it to process data in 16-bit chunks instead of 8-bit. This results in faster data processing and improved performance. Additionally, the 8086 has a larger addressable memory space, supporting up to 1MB of memory compared to the 64KB limit of the 8085.

Another key difference is the introduction of segmented memory addressing in the 8086. This allows for more efficient memory management and enables the use of larger programs. The 8086 also features a more advanced instruction set, including support for complex operations and addressing modes.

## Intel 8088
The Intel 8088 is a variant of the Intel 8086 microprocessor. It was released in 1979 and is commonly referred to as the "brain" of the original IBM PC.

The 8088 is a 16-bit microprocessor with an 8-bit external data bus. This means that it can process data in 16-bit chunks internally, but can only transfer data to and from memory in 8-bit increments. It has a clock speed of 4.77 MHz.

Compared to the 8086, the 8088 has a narrower data bus, which affects its overall performance. The 8088's 8-bit data bus limits its data transfer rate and can result in slower execution of certain operations. However, this design choice was made to reduce the cost of the system, as it allowed for the use of cheaper 8-bit memory chips.

It was the core of the Ibm Pc.
