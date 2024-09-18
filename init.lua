local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end

local LattinMellon = {}

LattinMellon.author = "Franz B. <csaa6335@gmail.com>"
LattinMellon.homepage = "https://github.com/franzbu/LattinMellon.spoon"
LattinMellon.license = "MIT"
LattinMellon.name = "LattinMellon"
LattinMellon.version = "0.7.1"
LattinMellon.spoonPath = scriptPath()

local dragTypes = {
  move = 1,
  resize = 2,
}

local function tableToMap(table)
  local map = {}
  for _, value in pairs(table) do
    map[value] = true
  end
  return map
end

local function getWindowUnderMouse()
  local _ = hs.application
  local my_pos = hs.geometry.new(hs.mouse.absolutePosition())
  local my_screen = hs.mouse.getCurrentScreen()
  return hs.fnutils.find(hs.window.orderedWindows(), function(w)
    return my_screen == w:screen() and my_pos:inside(w:frame())
  end)
end

-- Usage:
--   resizer = LattinMellon:new({
--     margin = 30,
--     standardModifier = { 'alt' },
--     OMmodifier = { 'alt', 'ctrl' },
--     TATmodifier = { 'alt', 'ctrl', 'cmd' },
--     SATmodifier = { 'alt', 'ctrl', 'cmd', 'shift' },
--   })

local function buttonNameToEventType(name, optionName)
  if name == 'left' then
    return hs.eventtap.event.types.leftMouseDown
  end
  if name == 'right' then
    return hs.eventtap.event.types.rightMouseDown
  end
  error(optionName .. ': only "left" and "right" mouse button supported, got ' .. name)
end

function LattinMellon:new(options)
  options = options or {}
  margin = options.margin or 30
  m = margin / 2
  OMmodifier = options.OMmodifier -- or { 'alt', 'ctrl' }
  TATmodifier = options.TATmodifier or { 'alt', 'ctrl', 'cmd' }
  SATmodifier = options.SATmodifier or { 'alt', 'ctrl', 'cmd', 'shift' } -- hyper key

  local resizer = {
    disabledApps = tableToMap(options.disabledApps or {}),
    dragging = false,
    dragType = nil,
    moveStartMouseEvent = buttonNameToEventType('left', 'moveMouseButton'),
    moveModifiers = options.standardModifier or { 'alt' },
    resizeStartMouseEvent = buttonNameToEventType('right', 'resizeMouseButton'),
    resizeModifiers = options.standardModifier or { 'alt' },
    targetWindow = nil,
  }

  setmetatable(resizer, self)
  self.__index = self

  resizer.clickHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDown,
      hs.eventtap.event.types.rightMouseDown,
    },
    resizer:handleClick()
  )

  resizer.cancelHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseUp,
      hs.eventtap.event.types.rightMouseUp,
    },
    resizer:handleCancel()
  )

  resizer.dragHandler = hs.eventtap.new(
    {
      hs.eventtap.event.types.leftMouseDragged,
      hs.eventtap.event.types.rightMouseDragged,
    },
    resizer:handleDrag()
  )

  resizer.clickHandler:start()

  return resizer
end

function LattinMellon:stop()
  self.dragging = false
  self.dragType = nil
  self.cancelHandler:stop()
  self.dragHandler:stop()
  self.clickHandler:start()
end

function LattinMellon:isResizing()
  return self.dragType == dragTypes.resize
end

function LattinMellon:isMoving()
  return self.dragType == dragTypes.move
end

local sumdx = 0
local sumdy = 0
function LattinMellon:handleDrag()
  return function(event)
    if not self.dragging then return nil end

    local dx = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaX)
    local dy = event:getProperty(hs.eventtap.event.properties.mouseEventDeltaY)

    if self:isMoving() then
  
      local point = win:topLeft()
      local frame = win:size() -- win:frame
      --win:move(hs.geometry.new(point.x + dx, point.y + dy, frame.w, frame.h), nil, false, 0)
      win:move({ dx, dy }, nil, false, 0)
      sumdy = sumdy + dy
      sumdx = sumdx + dx
      movedNotResized = true
      return true
    elseif self:isResizing() then
      movedNotResized = false
      local currentSize = win:size() -- win:frame
      local current = win:topLeft()
      if mH <= -m and mV <= m and mV > -m then -- 9 o'clock
        win:move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h), nil, false, 0)
      elseif mH <= -m and mV <= -m then -- 10:30
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false,
              0)
          end
        else
          win:move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > -m and mH <= m and mV <= -m then -- 12 o'clock
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
          end
        else
          win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV <= -m then -- 1:30
        if dy < 0 then -- prevent extension of downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
          end
        else
          win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV > -m and mV <= m then -- 3 o'clock
        win:move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h), nil, false, 0)
      elseif mH > m and mV > m then -- 4:30
        win:move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h + dy), nil, false, 0)
      elseif mV > m and mH <= m and mH > -m then -- 6 o'clock
        win:move(hs.geometry.new(current.x, current.y, currentSize.w, currentSize.h + dy), nil, false, 0)
      elseif mH <= -m and mV > m then -- 7:30
        win:move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h + dy), nil, false, 0)
      else -- middle
        local point = win:topLeft()
        local frame = win:frame()
        win:move({ dx, dy }, nil, false, 0)
        movedNotResized = true
      end
      return true
    else
      return nil
    end
  end
end

function LattinMellon:handleCancel()
  return function()
    if not self.dragging then return end
    self:doMagic()
    self:stop()
  end
end

function LattinMellon:doMagic() -- automatic positioning and adjustments, for example, prevent window from moving/resizing beyond screen boundaries
  if not self.targetWindow then return end
  local win = hs.window.focusedWindow()
  local frame = win:frame()
  local point = win:topLeft()
  local max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height without menu bar
  local xNew = point.x
  local yNew = point.y
  local wNew = frame.w
  local hNew = frame.h

  if movedNotResized then
    -- window moved past left screen border
    if tableComp(flags,self.moveModifiers) then
      gridX = 2
      gridY = 2
    elseif tableComp(flags, OMmodifier) then
      gridX = 3
      gridY = 3
    elseif tableComp(flags, TATmodifier) then
      gridX = 4
      gridY = 4
    elseif tableComp(flags, SATmodifier) then
      gridX = 5
      gridY = 5
    end

    if tableComp(flags, self.moveModifiers) then
      if point.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
        if math.abs(point.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
          xNew = 0
        -- window moved past left screen border
        else -- automatically resize and position window within grid
          for i = 1, gridY, 1 do
            -- middle third of left border
            if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment
              xNew = 0
              yNew = heightMB
              wNew = max.w / 2
              hNew = max.h
            elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
              xNew = 0
              yNew = heightMB
              wNew = max.w / 2
              hNew = max.h / 2
            else -- bottom third
              xNew = 0
              yNew = heightMB + max.h / 2
              wNew = max.w / 2
              hNew = max.h / 2
            end
          end
        end
      -- moved window past right screen border
      elseif point.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
        if max.w - point.x > math.abs(max.w - point.x - wNew) * 9 then -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
          wNew = frame.w
          xNew = max.w - wNew
        else -- automatical positioning and resizing of window
          for i = 1, gridY, 1 do
            -- middle third of left border
            if hs.mouse.getRelativePosition().y + sumdy > max.h / 3 and hs.mouse.getRelativePosition().y + sumdy < max.h * 2 / 3 then
              xNew = max.w / 2
              yNew = heightMB
              wNew = max.w / 2
              hNew = max.h
            elseif hs.mouse.getRelativePosition().y + sumdy <= max.h / 3 then -- upper third
              xNew = max.w / 2
              yNew = heightMB
              wNew = max.w / 2
              hNew = max.h / 2
            else -- bottom third
              xNew = max.w / 2
              yNew = heightMB + max.h / 2
              wNew = max.w / 2
              hNew = max.h / 2
            end
          end
        end
      -- moved window below bottom of screen
      elseif point.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
        if max.h - point.y > math.abs(max.h - point.y - hNew) * 9 then -- and flags:containExactly(self.moveModifiers) then -- move window as is back within boundaries
          yNew = maxWithMB.h - hNew
        else -- get window to full height in corresponding x-grid
          for i = 1, gridX, 1 do
            if hs.mouse.getRelativePosition().x + sumdx > max.w / 3 and hs.mouse.getRelativePosition().x + sumdx < max.w * 2 / 3 then -- middle
              xNew = 0
              yNew = heightMB
              wNew = max.w
              hNew = max.h
              break
            elseif hs.mouse.getRelativePosition().x + sumdx <= max.w / 3 then -- left
              xNew = 0
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h
              break
            else -- right
              xNew = max.w - max.w / gridX -- for gridX = 2 the same as max.w / 2
              yNew = heightMB
              wNew = max.w / gridX
              hNew = max.h
              break
            end
          end
        end
      end
    elseif tableComp(flags, OMmodifier) then
      if point.x < 0 and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- left and not bottom
        if math.abs(point.x) < wNew / 10 then -- moved past border by 10 or less percent: move window as is back within boundaries of screen
          xNew = 0
        -- window moved past left screen border
        else -- automatically resize and position window within grid
          -- 3 standard areas
          if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
            for i = 1, gridY, 1 do
              -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment             
              if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                xNew = 0
                yNew = heightMB + (i - 1) * max.h / gridY
                wNew = max.w / gridX
                hNew = max.h / gridY
                break
              end
            end
          -- first (upper) double area
          elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
            xNew = 0
            yNew = heightMB
            wNew = max.w / gridX
            hNew = max.h / gridY * 2
          else -- second (lower) double area
            xNew = 0
            yNew = heightMB + max.h / 5 * 2
            wNew = max.w / gridX
            hNew = max.h / gridY * 2
          end
        end

      -- moved window past right screen border
      elseif point.x + frame.w > max.w and hs.mouse.getRelativePosition().y + sumdy < max.h + heightMB then -- right and not bottom
        if max.w - point.x > math.abs(max.w - point.x - wNew) * 9 then  -- 9 times as much inside screen than outside = 10 percent outside; move window back within boundaries of screen (keep size)
          wNew = frame.w
          xNew = max.w - wNew
        else -- automatical positioning and resizing of window
           -- getRelativePosition() returns mouse coordinates where moving process starts, not ends, thus sumdx/sumdy make necessary adjustment                     
          if (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 2 and hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 3) or (hs.mouse.getRelativePosition().y + sumdy > max.h / 5 * 4) then
            -- 3 standard areas
            for i = 1, gridY, 1 do
              if hs.mouse.getRelativePosition().y + sumdy < max.h - (gridY - i) * max.h / gridY then 
                xNew = max.w - max.w / gridX
                yNew = heightMB + (i - 1) * max.h / gridY
                wNew = max.w / gridX
                hNew = max.h / gridY
                break
              end
            end
          -- first (upper) double area
          elseif (hs.mouse.getRelativePosition().y + sumdy > max.h / 5) and (hs.mouse.getRelativePosition().y + sumdy <= max.h / 5 * 2) then
            xNew = max.w - max.w / gridX
            yNew = heightMB
            wNew = max.w / gridX
            hNew = max.h / gridY * 2
          else -- second (lower) double area
            xNew = max.w - max.w / gridX
            yNew = heightMB + max.h / 5 * 2
            wNew = max.w / gridX
            hNew = max.h / gridY * 2
          end
        end

      -- moved window below bottom of screen
      elseif point.y + hNew > maxWithMB.h and hs.mouse.getRelativePosition().x + sumdx < max.w and hs.mouse.getRelativePosition().x + sumdx > 0 then
        if max.h - point.y > math.abs(max.h - point.y - hNew) * 9 then -- and flags:containExactly(self.moveModifiers) then -- move window as is back within boundaries
          yNew = maxWithMB.h - hNew
        else -- get window to full height in corresponding x-grid
          if (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 2 and hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 3) or (hs.mouse.getRelativePosition().x + sumdx > max.w / 5 * 4) then
            -- 3 standard areas
            for i = 1, gridX, 1 do
              if hs.mouse.getRelativePosition().x + sumdx < max.w - (gridX - i) * max.w / gridX then 
                xNew = (i - 1) * max.w / gridX 
                yNew = heightMB + (i - 1) * gridX
                wNew = max.w / gridX
                hNew = max.h
                break
              end
            end
          -- first (left) double width
          elseif (hs.mouse.getRelativePosition().x + sumdx > max.w / 5) and (hs.mouse.getRelativePosition().x + sumdx <= max.w / 5 * 2) then
            xNew = 0
            yNew = heightMB
            wNew = max.w / gridX * 2
            hNew = max.h
          else -- second (right) double width
            xNew = max.w - max.w / gridX * 2
            yNew = heightMB
            wNew = max.w / gridX * 2
            hNew = max.h
          end
        end
      end
    end
  else -- if window has been resized (and not moved)
    if point.x < 0 then -- window resized past left screen border
      wNew = frame.w + point.x
      xNew = 0
    elseif point.x + frame.w > max.w then -- window resized past right screen border
      wNew = max.w - point.x
      xNew = max.w - wNew
    end
    if point.y < heightMB then -- if window has been resized past beginning of menu bar, height of window is corrected accordingly
      hNew = frame.h + point.y - heightMB
      yNew = heightMB
    end
  end
  self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
  --hs.spaces.moveWindowToSpace(hs.window.focusedWindow(), getIDSpaceLeft(), true) -- fb: move to different space 
  sumdx = 0
  sumdy = 0
end

function LattinMellon:handleClick()
  return function(event)
    if self.dragging then return true end
    flagsOrg = event:getFlags()
    local eventType = event:getType()

    flags = {}
    
---[[ -- flagsOrg looks like this: {'alt' true}; the following loop turns it into a table comparable to the one initiated in Hammerspoon's init.lua
    k = 1
    for i,v in pairs(flagsOrg) do
      flags[k] = i
      k = k + 1
    end
--]]

---[[
    
    -- local isResizing = eventType == self.resizeStartMouseEvent and flags:containExactly(self.resizeModifiers)
    -- local isMoving = eventType == self.moveStartMouseEvent and (flags:containExactly(self.moveModifiers) or flags:containExactly(OMmodifier) or flags:containExactly(TATmodifier) or flags:containExactly(SATmodifier))
    local isMoving = eventType == self.moveStartMouseEvent and (tableComp(flags, self.moveModifiers) or tableComp(flags, OMmodifier) or tableComp(flags, TATmodifier) or tableComp(flags, SATmodifier))
    local isResizing = eventType == self.resizeStartMouseEvent and (tableComp(flags, self.moveModifiers) or tableComp(flags, OMmodifier) or tableComp(flags, TATmodifier) or tableComp(flags, SATmodifier))
--]]

   --[[
    if tableComp(flags, OMmodifier) then
      print "true---------"
    else
      print "false----------"
    end

    print("OMmodifier: ------")
    for i,v in pairs(OMmodifier) do
      print(i,v)
    end
    print("flags: ------")
    for i,v in pairs(flags) do
      print(i,v)
    end

    if tableComp(OMmodifier, flags) then
      print("same")
    else
      print("not same")
    end
  --]]

    if isMoving or isResizing then
  
      local currentWindow = getWindowUnderMouse()
      if self.disabledApps[currentWindow:application():name()] then
        return nil
      end

      self.dragging = true
      self.targetWindow = currentWindow
      

      if isMoving then
        self.dragType = dragTypes.move
      else
        self.dragType = dragTypes.resize
      end

      win = getWindowUnderMouse():focus()
      local point = win:topLeft()
      local frame = win:frame()
      local max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height
      maxWithMB = win:screen():fullFrame()
      heightMB = maxWithMB.h - max.h   -- height menu bar
      local xOrg = point.x
      local yOrg = point.y
      local wOrg = frame.w
      local hOrg = frame.h

      local mousePos = hs.mouse.absolutePosition()
      local mx = wOrg + xOrg - mousePos.x -- distance between right border of window and cursor
      local dmah = wOrg / 2 - mx -- absolute delta: mid window - cursor
      mH = dmah * 100 / wOrg -- delta from mid window: -50(left border of window) to 50 (left border)

      local my = hOrg + yOrg - mousePos.y
      local dmav = hOrg / 2 - my
      mV = dmav * 100 / hOrg -- delta from mid window in %: from -50(=top border of window) to 50 (bottom border)

      self.cancelHandler:start()
      self.dragHandler:start()
      self.clickHandler:stop()

      -- Prevent selection
      return true
    else
      return nil
    end
  end
end

-- helper function(s)

function tableComp(a, b) --algorithm is O(n log n), due to table growth.
  if #a ~= #b then
    return false
  end -- unequal length of tables

  --[[
  print("--a--")
  for i = 1, 2 do
    print(a[i])
  end

  print("--b--")
  for i = 1, 2 do
    print(b[i])
  end
  --]]

  table.sort(a)
  table.sort(b)

  for i = 1, #a do
    if a[i] ~= b[i] then
      return false
    end
  end



  return true
end



return LattinMellon
