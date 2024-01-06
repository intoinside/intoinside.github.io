---
layout: post
title: Sprite editor survival guide
tags: commodore-128 sprite sprite-editor
---

Designing sprite with the Commodore 64 was done using a grid similar to this one.

![](/resources/sprite-grid.jpg)

Each row is encoded with 3 bytes, each representing the value of 8 columns. By encoding
every row, you'll get (3 * 21) = 63 bytes which defines the entire sprite.
Things are similar in case of multicolor sprite, where every pixel is defined with
2 byte (so there are 3 colour available + background).

This method continues to be valid with the C128 but there are other more convenient
possibilities for defining sprites.

### Using sprite editor

C128 has a Basic command called **SPRDEF** which activates the internal sprite
editor.

<figure>
<img src="https://www.c64-wiki.com/images/e/e3/SPRDEF.png" alt="SPRDEF">
<figcaption>Sprite selection screen - from <a href="https://www.c64-wiki.com/wiki/File:SPRDEF.png">c64-wiki</a></figcaption>
</figure>

Cursor is represented as '+' for hi-res sprite or '++' for multicolor sprite.
You can type from 1 to 8 to select which sprite to edit. Otherwise you can press
<span class="keystroke">RETURN</span> to exit from editor.

When sprite is selected, working mode is active and there are some command to edit
sprite.

|Key|Description|
|-|-|
|<span class="keystroke">SHIFT</span> + <span class="keystroke">RETURN</span>|Saves the designed sprite and returns to the sprite selection|
|<span class="keystroke">RUN/STOP</span>|Discards changes and returns to sprite selection|
|<span class="keystroke">CRSR</span>|Moves the cursor in the workspace|
|<span class="keystroke">RETURN</span>|Places cursor at the beginning of the next line (except for the last line, where it is positioned only at the 1st column)|
|<span class="keystroke">CLR/HOME</span>|Places the cursor in the upper left corner of the workspace|
|<span class="keystroke">SHIFT</span> + <span class="keystroke">CLR/HOME</span>|Clears the sprite grid and positions the cursor in the upper left corner|
|<span class="keystroke">1</span>|Deletes point|
|<span class="keystroke">2</span>|Sets point in foreground color|
|<span class="keystroke">3</span>|Sets point in additional color 1 (for multicolor sprite)|
|<span class="keystroke">4</span>|Sets point in additional color 2 (for multicolor sprite)|
|<span class="keystroke">A</span>|Enables/disables automatic cursor movement (to the right) for pixel change keys 1 to 4|
|<span class="keystroke">C</span>|Copies pattern from another sprite. 1 to 8 selects the sprite, RETURN cancels the action|
|<span class="keystroke">CTRL</span> + <span class="keystroke">1</span> to <span class="keystroke">CTRL</span> + <span class="keystroke">8</span>|Selects one of the foreground colors from 1 to 8|
|<span class="keystroke">![](/resources/cmd-key.png)</span> + <span class="keystroke">1</span> to <span class="keystroke">![](/resources/cmd-key.png)</span> + <span class="keystroke">8</span>|Selects one of the foreground colors from 9 to 16|
|<span class="keystroke">X</span>|Turns double width sprite on/off|
|<span class="keystroke">Y</span>|Turns double height sprite on/off|
|<span class="keystroke">M</span>|Turns multicolor mode on/off|

<figure>
<img src="https://www.c64-wiki.com/images/6/62/SPRDEF-Smiley.png" alt="SPRDEF">
<figcaption>Example of defined hi-res sprite - from <a href="https://www.c64-wiki.com/wiki/File:SPRDEF-Smiley.png">c64-wiki</a></figcaption>
</figure>

Once sprite is defined, you can quit working mode (with
<span class="keystroke">SHIFT</span> + <span class="keystroke">RETURN</span>)
and sprite will be saved in memory. By exiting from editor
(with <span class="keystroke">RETURN</span>), it can be saved to disk with
**BSAVE** command

``` Assembly
BSAVE "FILENAME",B0,P3584 TO P4096
```
Where:
* B0 means the bank (from B0 to B15)
* P3584 means the starting address
* P4096 means the ending address + 1

Starting address and end address are in decimal format.

Memory area from 3584 to 4096 contains all 8 sprites so if you don't want to save them
all, you can start from 3854 up to 3584 + (num-sprite-to-save * 64).

Saved sprites can be loaded with **BLOAD** command:

``` Assembly
BLOAD "FILENAME", B0, P3584
```
Where:
* B0 means the bank (from B0 to B15)
* P3584 means the starting address where the save begins

Starting address and end address is in decimal format.

Note: bank 0 to 15 are predefined, look at the [reference](https://c128lib.github.io/Reference/MemoryMap).

### Drawing bitmap

Sprite can also be defined by drawing graphics on bitmap screen. Let's take a simple
Basic listing:
``` Basic
100 graphic 1,1
110 draw 1,0,0 to 23,20
120 draw 1,0,20 to 23,0
125 box 1,0,0,23,20
130 circle 1,12,10,10
140 sshape a$,0,0,23,20
150 sprsav a$,1
160 sprite 1,1,11,0,1,1,0
170 movspr 1,160,100
180 movspr 1,120#7
190 getkey k$
200 graphic 0: movspr 1,0#0
```
* Line 100 activates high resolution graphic screen and clears it.
* Line 110 to 130 creates a simple graphic object in top left corner.
* Line 140 copies a 24x21 area to string called a$
* Line 150 saves data inside string a$ to sprite 1
* Line 160 activates sprite 1 with color 11 (light red) and some other params
* Line 170 moves sprite 1 to (160, 100)
* Line 180 sets autonomous movement for sprite 1 with angle of 120 and speed 7
* Line 190 waits for a keypress (while sprite 1 is still moving)
* Line 200 sets text mode and stops sprite 1 movement

Important lines are:
* 140, bitmap area is converted to string and copied into a variable
* 150, defines a sprite with string content of a variable

It's possible to "paint" a string to bitmap area, it'a just the reverse of **SSHAPE**:

``` Basic
GSHAPE <var>, [[<x>, <y>], <mode>]
```
where
* var is the variable that contains the string
* (x, y) is the coordinate for painting (if omitted, current cursor position will
be used)
* mode is the painting mode used (default, inverted, OR-ed, AND-ed, XOR-ed)
