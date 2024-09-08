# 🌄 🚀 SkyRocket.spoon

There is a variety of tools to resize and move windows on macOS using the mouse and a modifier key, saving the time of having to painstakingly get a hold of the edge of the window. None of these tools have satisfied me, be it for the lack of fluency or functional limitations. 

The original tool SkyRocket (v1.0.2) by dbalatero, which ingeniously uses a transparent canvas for addressing the already mentioned lack of fluency other tools are hampered with, came close to what I wanted. balatero's tool only lacked the ability to resize windows all directions (it can resize windows down/right). Therefore, I have extended his tool with the functionality to do exactly that. Huge thanks to dbalatero for laying all the groundwork and this making my part simple. 

This animated GIF doesn't capture the mouse cursor correctly; in real life the cursor moves along with moving and resizing the window as expected. Nevertheless, the animation still shows what you can do with this tool.

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

  -- Which modifiers to hold to move a window?
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

To move a window, hold your `moveModifiers` down, then click `moveMouseButton` and drag a window.

### Resizing

To resize a window, hold your `resizeModifiers` down, then click `resizeMouseButton` and drag a window.

### Disabling move/resize for apps

You can disable move/resize for any app by adding it to the `disabledApps` option:

```lua
sky = SkyRocket:new({
  -- For example, if you run your terminal in full-screen mode you might not
  -- to accidentally resize it:
  disabledApps = {"Alacritty"},
})
```

