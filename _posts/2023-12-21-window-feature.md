---
layout: post
title: Window feature on C128
tags: window commodore-128 assembly
---

This post will explain windowing feature of C128, how to use it
and to survive.

Window is an interesting new features on the 128 screen output.
Printing and cursor movement can be confined to the boundaries of a window
rather than the whole screen.

To understand what windows are, let's start with a simple example.

With a fresh-started C128, let's fill screen with a Basic program like
this to fill screen:

``` Basic
10 PRINT CHR$(205.5+RND(1)); : GOTO 10
```

By running this program you'll get an output similar to this screenshot.

![Maze](/resources/c128-maze.png)

With a full filled screen, WINDOW command can be called to create an
internal window inside 40-column screen. WINDOW command use four required and
one optional argument:

``` Basic
WINDOW left-boundary, top-boundary, right-boundary, bottom-boundary[, clear-screen]
```
First two argument are needed to select column and row which will be top left boundary.
Third and forth argument are needed to select bottom right boundary.
Last argument is optional and if it's set to 1 then window will be cleared.

Note that all these coordinates should be compliant with screen width and height
(WINDOW can be used both on 40 or 80 column screen).

So stop execution of filling screen program and run window command:

``` Basic
WINDOW 2, 2, 20, 10, 1
```

![Maze](/resources/c128-maze-with-window.png)

As you can see, a new internal empty window has been created, starting from (2,2)
to (20,10).
Every action will happen inside this new window, external content will not be touched.

Remember that third and forth parameter are not width/height of window and you'll
get an error if your parameters are out of current screen boundaries.

To get a more complete example, you can copy/paste this example on Vice (taken from
C128 System Guide):

``` Basic
10 scnclr : color 5,5
20 color 5,5
30 window 0, 0, 39, 24
40 color 0,13 : color 4,13
50 a$="abcdefghijklmnopqrst"
60 color 5,5
70 for i = 1 to 25
80 print a$;a$ : next i
90 window 1,1,7,20
100 color 5,3
110 print chr$(18);a$;
120 window 15,15,39,20,1
130 color 5,7
140 for i = 1 to 6 : print a$; : next i
150 window 30,1,39,22,1
160 color 5,8 : list
170 window 5,5,33,18,1
180 color 5,2
190 print a$ : list
200 end
```

There are 5 window defined in this program:

* whole screen filled with a string (10-80)
* (1,1)-(7,20) with a reversed string printed (90-110)
* (15,15)-(39,20) (empty) with a reversed string printed 6 times (120-140)
* (30,1)-(39,22) (empty) with a list of current program (150-170)
* (5,5)-(33,18) (empty) with a reversed string (not visible) and a list of
current program (180-190)

By running this program you'll get

![Example 40-cols](/resources/c128-window-40cols.png)

In this example, there are 5 windows created on line 30, 90, 120, 150 and 170. In
every window, some text is written using different color so it's quite clear to see
boundaries

This Basic program can be used also on 80-column screen without modification:

![Example 80-cols](/resources/c128-window-80cols.png)

Original full-screen window can be restored by using:

``` Basic
WINDOW 0, 0, 39, 24
```
