# 🌄 🚀 SkyRocket.spoon

There is a variety of tools to resize and move windows on macOS using the mouse and a modifier key, saving the time of having to painstakingly get a hold of edges and corners of windows. However, none of these tools have satisfied me, be it for the lack of fluency or for functional limitations. 

The original tool by dbalatero, which ingeniously uses a transparent canvas for addressing the already mentioned lack of fluency other tools are hampered with, came close to what I wanted. What I found limiting, though, was the limitation of balatero's tool to resize windows only down/right. Therefore, I have extended his tool with the the possibility to resize windows all directions. Aditionally, an area can be defined where windows are limited to being resized only horizontally and vertically, i.e., four directions. A huge thanks goes to dbalatero for his excellent tool. 

The animated GIF below doesn't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Nevertheless, the animation still shows what you can do with this tool.

<img alt="SkyRocket move and resize demo" src="https://github.com/franzbu/SkyRocket.spoon/blob/master/doc/SkyRocket.gif" />

## Installation

This tool requires [Hammerspoon](https://www.hammerspoon.org/) to be installed and running.

To install SkyRocket.spoon, after downloading and unzipping, move the folder to ~/.hammerspoon/Spoons and make sure the name of the folder is 'SkyRocket.spoon'. 

Alternatively, you can simply run the following terminal command:

```lua

mkdir -p ~/.hammerspoon/Spoons && git clone https://github.com/franzbu/SkyRocket.spoon.git ~/.hammerspoon/Spoons/SkyRocket.spoon

```

## Usage

Once you've installed it, add this to your `~/.hammerspoon/init.lua` file:

```lua
local SkyRocket = hs.loadSpoon("SkyRocket")

SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,

  -- How much space (in percent) in the middle of each of the four borders of the windows do you want to reserve for limiting 
  -- resizing windows only horizontally and vertically? 0 disables this function, 100 disables diagonal resizing.
  margin = 30,

  -- Which modifiers to hold to move a window?
  moveModifiers = {'cmd', 'shift'},

  -- Which mouse button to hold to move a window?
  moveMouseButton = 'left',

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'ctrl', 'shift'},

  -- Which mouse button to hold to resize a window?
  resizeMouseButton = 'left',
})
```
I can recommend using CapsLock as hyper key (with Karabiner Elements, CapsLock can be reconfigured that if pressed alone it acts as CapsLock and if used in combination with another key or a mouse button it acts as modifier key). I have set up Hammerspoon to move a window pressing CapsLock in combination with the left mouse button and to resize a window pressing CapsLock in combination with the right mouse button.

In case of using CapsLock as hyper key, add the following lines to your `~/.hammerspoon/init.lua` file:

```lua
local SkyRocket = hs.loadSpoon("SkyRocket")

sky = SkyRocket:new({
  -- Opacity of resize canvas
  opacity = 0.3,

  -- How much space (in percent) in the middle of each of the four window-margins do you want to reserve for limiting 
  -- resizing windows to horizontally and vertically? 0 disables this function, 100 disables diagonal resizing.
  margin = 30,

  -- Which modifiers to hold to move a window?
  -- moveModifiers = {'ctrl', 'shift'},
  moveModifiers = {'shift', 'ctrl', 'alt', 'cmd'},

  -- Which mouse button to hold to move a window?
  moveMouseButton = 'left',

  -- Which modifiers to hold to resize a window?
  resizeModifiers = {'shift', 'ctrl', 'alt', 'cmd'},

  -- Which mouse button to hold to resize a window?
  resizeMouseButton = 'right',
})
```


### Moving

To move a window, hold your `moveModifiers` down, then click `moveMouseButton` and drag the window.

### Resizing

To resize a window, hold your `resizeModifiers` down, then click `resizeMouseButton` and drag the window.

To resize windows only horizontally and vertically, enable this functionality by adjusting the option 'margin' to your liking: '30' signifies that 30 percent of the window (15 precent left and right around the middle of each border) is reserved for horizontal-only and vertical-only resizing.

This horizontal-only and vertical-only resizing has been enabled because there are use scenarios where such a fine tuned resizing is desirable. At the same time this is not a loss as placing the cursor in the remainig parts of the window enables you to resize your windows all directions.

On a side note: at the very center of the window there is an erea, the size of which depends on the size of the margin, where you can move the window by pressing the same modifier key and the same mouse button as for resizing. If the margin is set to 0, also this area becomes non-existent.

### Disabling move/resize for apps

You can disable move/resize for any app by adding it to the `disabledApps` option:

```lua
sky = SkyRocket:new({
  -- For example, if you run your terminal in full-screen mode you might not
  -- to accidentally resize it:
  disabledApps = {"Alacritty"},
})
```

