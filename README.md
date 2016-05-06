# MatlabGameLibrary
A library created for easing game development in MATLAB. 

The aim of this project is to simplify the implementation of 2D graphics on a matlab figure object. Also Keyboard input and mouse events have been implemented. As with MATLAB, do not expect the possibility to build fancy games. It is good enough for simple 2D games though, as well as quickly drawing something on a 2D canvas.

## Window Class
The main class is the Window class. This class transforms a MATLAB figure into a drawing canvas that spans the whole figure window. The toolbars are removed. 

Keyboard character detection has been implemented, only characters though. (Future plans to implement a function to catch all keys instead of characters)

Several mouse events are implemented: mouse motion, mouse button down and mouse click. Matlab only recognises 1 button down, meaning that pressing any mouse button results in the same action.

The window has the following functions:
- isCloseRequestedflag (Pressing the X does not close the window)
- destroying the window
- set background clear color
- set resizable
- set target FPS

## Button Class
This class implements a button that can detect mouseover and mouse click.

## ButtonList Class
List for Buttons. In the future this will contain more functions on the buttons.
