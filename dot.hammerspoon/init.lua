hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

require("hs.ipc")

hs.window.animationDuration = 0

local widthRatios = { 1 / 3, 1 / 2, 2 / 3 }
local ratioTolerance = 0.01
local edgeThreshold = 50

local function findNearestRatio(ratio, ratioList)
  local nearest = ratioList[1]
  local nearestDiff = math.abs(ratio - nearest)
  for i = 2, #ratioList do
    local diff = math.abs(ratio - ratioList[i])
    if diff < nearestDiff then
      nearestDiff = diff
      nearest = ratioList[i]
    end
  end
  return nearest
end

local function getNextRatio(current, ratioList)
  for i, v in ipairs(ratioList) do
    if math.abs(current - v) <= ratioTolerance then
      local nextIndex = (i % #ratioList) + 1
      return ratioList[nextIndex]
    end
  end
  return ratioList[1]
end

local function isNearRightEdge(winFrame, screenFrame)
  local winRight = winFrame.x + winFrame.w
  local screenRight = screenFrame.x + screenFrame.w
  return math.abs(winRight - screenRight) < edgeThreshold
end

local function isNearLeftEdge(winFrame, screenFrame)
  return math.abs(winFrame.x - screenFrame.x) < edgeThreshold
end

local function stepRight()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end

  local screen = win:screen()
  local sFrame = screen:frame()
  local wFrame = win:frame()

  local currentRatio = wFrame.w / sFrame.w

  if isNearRightEdge(wFrame, sFrame) then
    local nearest = findNearestRatio(currentRatio, widthRatios)
    local nextR = getNextRatio(nearest, widthRatios)
    wFrame.w = sFrame.w * nextR
    wFrame.x = sFrame.x + sFrame.w - wFrame.w
  else
    local firstR = widthRatios[1]
    wFrame.w = sFrame.w * firstR
    wFrame.x = sFrame.x + sFrame.w - wFrame.w
  end

  wFrame.y = sFrame.y
  wFrame.h = sFrame.h

  win:setFrame(wFrame)
end

local function stepLeft()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end

  local screen = win:screen()
  local sFrame = screen:frame()
  local wFrame = win:frame()

  local currentRatio = wFrame.w / sFrame.w

  if isNearLeftEdge(wFrame, sFrame) then
    local nearest = findNearestRatio(currentRatio, widthRatios)
    local nextR = getNextRatio(nearest, widthRatios)
    wFrame.w = sFrame.w * nextR
    wFrame.x = sFrame.x
  else
    local firstR = widthRatios[1]
    wFrame.w = sFrame.w * firstR
    wFrame.x = sFrame.x
  end

  wFrame.y = sFrame.y
  wFrame.h = sFrame.h

  win:setFrame(wFrame)
end

local function moveWindowToRightScreenAndStepRight()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local nextScreen = screen:toEast()
  if nextScreen then
    win:moveToScreen(nextScreen)
  end
  stepRight()
end

local function moveWindowToLeftScreenAndStepLeft()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local prevScreen = screen:toWest()
  if prevScreen then
    win:moveToScreen(prevScreen)
  end
  stepLeft()
end

local function maximizeWindowSize()
  local win = hs.window.focusedWindow()
  if not win then
    return
  end
  local screen = win:screen()
  local sFrame = screen:frame()
  win:setFrame(sFrame)
end

hs.hotkey.bind({ "cmd", "alt" }, "Right", stepRight)
hs.hotkey.bind({ "cmd", "alt" }, "Left", stepLeft)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", moveWindowToRightScreenAndStepRight)
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", moveWindowToLeftScreenAndStepLeft)
hs.hotkey.bind({ "cmd", "alt" }, "f", maximizeWindowSize)
