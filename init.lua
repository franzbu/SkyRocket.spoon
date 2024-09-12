local function scriptPath()
  local str = debug.getinfo(2, "S").source:sub(2)
  return str:match("(.*/)")
end


local LattinMellon = {}

LattinMellon.author = "Franz B. <csaa6335@gmail.com>"
LattinMellon.homepage = "https://github.com/franzbu/LattinMellon.spoon"
LattinMellon.license = "MIT"
LattinMellon.name = "LattinMellon"
LattinMellon.version = "0.2"
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
--     resizer = LattinMellon:new({
--     margin = 30,
--     moveModifiers = {'alt'},
--     moveMouseButton = 'left',
--     resizeModifiers = {'alt'},
--     resizeMouseButton = 'right',
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

  local resizer = {
    disabledApps = tableToMap(options.disabledApps or {}),
    dragging = false,
    dragType = nil,
    moveStartMouseEvent = buttonNameToEventType(options.moveMouseButton or 'left', 'moveMouseButton'),
    moveModifiers = options.moveModifiers or { 'cmd', 'shift' },
    resizeStartMouseEvent = buttonNameToEventType(options.resizeMouseButton or 'left', 'resizeMouseButton'),
    resizeModifiers = options.resizeModifiers or { 'ctrl', 'shift' },
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
      movedNotResized = true
      return true
    elseif self:isResizing() then
      movedNotResized = false
      local currentSize = win:size()           -- win:frame
      local current = win:topLeft()
      if mH <= -m and mV <= m and mV > -m then -- 9 o'clock
        win:move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h), nil, false, 0)
      elseif mH <= -m and mV <= -m then        -- 10:30
        if dy < 0 then -- avoid window being extended downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false,
              0)
          end
        else
          win:move(hs.geometry.new(current.x + dx, current.y + dy, currentSize.w - dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > -m and mH <= m and mV <= -m then -- 12 o'clock
        if dy < 0 then -- avoid window being extended downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
          end
        else
          win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV <= -m then -- 1:30
        if dy < 0 then -- avoid window being extended downwards when cursor enters menubar
          if current.y > heightMB then
            win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
          end
        else
          win:move(hs.geometry.new(current.x, current.y + dy, currentSize.w + dx, currentSize.h - dy), nil, false, 0)
        end
      elseif mH > m and mV > -m and mV <= m then -- 3 o'clock
        win:move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h), nil, false, 0)
      elseif mH > m and mV > m then              -- 4:30
        win:move(hs.geometry.new(current.x, current.y, currentSize.w + dx, currentSize.h + dy), nil, false, 0)
      elseif mV > m and mH <= m and mH > -m then -- 6 o'clock
        win:move(hs.geometry.new(current.x, current.y, currentSize.w, currentSize.h + dy), nil, false, 0)
      elseif mH <= -m and mV > m then            -- 7:30
        win:move(hs.geometry.new(current.x + dx, current.y, currentSize.w - dx, currentSize.h + dy), nil, false, 0)
      else                                       -- middle
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
    self:afterMovingResizing()
    self:stop()
  end
end

function LattinMellon:afterMovingResizing()
  if not self.targetWindow then return end

  local frame = win:frame()
  local point = win:topLeft()

  -- window is not allowed to extend boundaries of screen
  local win = hs.window.focusedWindow()
  local max = win:screen():frame() -- max.x = 0; max.y = 0; max.w = screen width; max.h = screen height
  local xNew = point.x
  local wNew = frame.w
  local maxWithMB = win:screen():fullFrame()
  heightMB = maxWithMB.h - max.h -- height menu bar
  local yNew = point.y
  local hNew = frame.h

  if movedNotResized then -- if window has been moved (and not resized) beyond screen boundaries, move window back within boundaries of screen
    if point.x < 0 then -- window moved past left screen border
      xNew = 0
    elseif point.x + frame.w > max.w then -- window moved past right screen border
      wNew = frame.w
      xNew = max.w - wNew
    end
    -- if window has been moved past bottom of screen
    if point.y + hNew > maxWithMB.h then
      yNew = maxWithMB.h - hNew
    end
  else                  -- if window has been resized (and not moved)
    if point.x < 0 then -- window resized past left screen border
      wNew = frame.w + point.x
      xNew = 0
    elseif point.x + frame.w > max.w then -- window resized past right screen border
      wNew = max.w - point.x
      xNew = max.w - wNew
    end
    -- if window has been resized past beginning of menu bar, height of window is corrected accordingly
    if point.y < heightMB then
      hNew = frame.h + point.y - heightMB
      yNew = heightMB
    end
  end

  self.targetWindow:move(hs.geometry.new(xNew, yNew, wNew, hNew), nil, false, 0)
end

function LattinMellon:handleClick()
  return function(event)
    if self.dragging then return true end

    local flags = event:getFlags()
    local eventType = event:getType()

    local isMoving = eventType == self.moveStartMouseEvent and flags:containExactly(self.moveModifiers)
    local isResizing = eventType == self.resizeStartMouseEvent and flags:containExactly(self.resizeModifiers)

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
      local maxWithMB = win:screen():fullFrame()
      heightMB = maxWithMB.h - max.h   -- height menu bar

      local xOrg = point.x
      local yOrg = point.y
      local wOrg = frame.w
      local hOrg = frame.h

      local mousePos = hs.mouse.absolutePosition()
      local mx = wOrg + xOrg - mousePos.x -- distance between right border of window and cursor
      local dmah = wOrg / 2 - mx          -- absolute delta: mid window - cursor
      mH = dmah * 100 / wOrg              -- delta from mid window: -50(left border of window) to 50 (left border)

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

return LattinMellon
