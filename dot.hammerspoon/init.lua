hs.loadSpoon("EmmyLua")
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

hs.window.animationDuration = 0

local layoutSteps = {
  { ratio = 30 / 100, right = hs.layout.right30, left = hs.layout.left30, next_index = 2 },
  { ratio = 50 / 100, right = hs.layout.right50, left = hs.layout.left50, next_index = 3 },
  { ratio = 70 / 100, right = hs.layout.right70, left = hs.layout.left70, next_index = 1 },
}
local edgeThreshold = 50

local function expectFocusedWindow(callback)
  return function()
    if hs.window.focusedWindow() then
      callback()
    end
  end
end

local function focusWindowByApplication(hint)
  local app = hs.application.find(hint)
  if app then
    local window = app:allWindows()[1]
    if window then
      window:focus()
    end
  end
end

local function applyLayoutToWindow(window, layout)
  if not window then
    return
  end
  local app = window:application()
  local screen = window:screen()
  hs.layout.apply({
    { app, window, screen, layout, nil, nil },
  })
end

local function findNearestLayoutStep(winFrame, screenFrame)
  local ratio = winFrame.w / screenFrame.w
  local nearest = layoutSteps[1]
  local nearestDiff = math.abs(ratio - nearest.ratio)
  for i = 2, #layoutSteps do
    local diff = math.abs(ratio - layoutSteps[i].ratio)
    if diff < nearestDiff then
      nearestDiff = diff
      nearest = layoutSteps[i]
    end
  end
  return nearest
end

local function isNearRightEdge(winFrame, screenFrame)
  local winRight = winFrame.x + winFrame.w
  local screenRight = screenFrame.x + screenFrame.w
  return math.abs(winRight - screenRight) < edgeThreshold
end

local function isNearLeftEdge(winFrame, screenFrame)
  return math.abs(winFrame.x - screenFrame.x) < edgeThreshold
end

local function applyRightLayoutStep()
  local win = hs.window.focusedWindow()
  local sFrame = win:screen():frame()
  local wFrame = win:frame()

  if isNearRightEdge(wFrame, sFrame) then
    local nearest = findNearestLayoutStep(wFrame, sFrame)
    applyLayoutToWindow(win, layoutSteps[nearest.next_index].right)
  else
    applyLayoutToWindow(win, hs.layout.right30)
  end
end

local function applyLeftLayoutStep()
  local win = hs.window.focusedWindow()
  local sFrame = win:screen():frame()
  local wFrame = win:frame()

  if isNearLeftEdge(wFrame, sFrame) then
    local nearest = findNearestLayoutStep(wFrame, sFrame)
    applyLayoutToWindow(win, layoutSteps[nearest.next_index].left)
  else
    applyLayoutToWindow(win, hs.layout.left30)
  end
end

local function moveWindowToRightScreenAndStepRight()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local nextScreen = screen:toEast()
  if nextScreen then
    win:moveToScreen(nextScreen)
  end
  applyRightLayoutStep()
end

local function moveWindowToLeftScreenAndStepLeft()
  local win = hs.window.focusedWindow()
  local westScreen = win:screen():toWest()
  if westScreen then
    win:moveToScreen(westScreen)
  end
  applyLeftLayoutStep()
end

local function maximizeWindowSize()
  applyLayoutToWindow(hs.window.focusedWindow(), hs.layout.maximized)
end

local function onMarkdownPreviewLaunch(win)
  local screen = win:screen()
  hs.layout.apply({
    { "deno", "Peek preview", screen, hs.layout.right30, nil, nil },
    { "Ghostty", nil, screen, hs.layout.left70, nil, nil },
  })
  focusWindowByApplication("Ghostty")
end

local function applicationWatcher(appName, eventType, app)
  if eventType == hs.application.watcher.launched then
    if appName == "deno" and app:allWindows()[1]:title() == "Peek preview" then
      onMarkdownPreviewLaunch(app:allWindows()[1])
    end
  end
end

hs.hotkey.bind({ "cmd", "alt" }, "Right", expectFocusedWindow(applyRightLayoutStep))
hs.hotkey.bind({ "cmd", "alt" }, "Left", expectFocusedWindow(applyLeftLayoutStep))
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", expectFocusedWindow(moveWindowToRightScreenAndStepRight))
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", expectFocusedWindow(moveWindowToLeftScreenAndStepLeft))
hs.hotkey.bind({ "cmd", "alt" }, "f", expectFocusedWindow(maximizeWindowSize))

local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
