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

local function moveWindowToRightScreen()
  local win = hs.window.focusedWindow()
  local screen = win:screen()
  local nextScreen = screen:toEast()
  if nextScreen then
    win:moveToScreen(nextScreen)
  end
end

local function moveWindowToLeftScreen()
  local win = hs.window.focusedWindow()
  local westScreen = win:screen():toWest()
  if westScreen then
    win:moveToScreen(westScreen)
  end
end

local function maximizeWindowSize()
  applyLayoutToWindow(hs.window.focusedWindow(), hs.layout.maximized)
end

local function raiseMainWindowByAppName(appName, maybeWinTitle)
  local app = hs.application.find(appName)
  if app then
    local win = app:mainWindow()
    if win then
      if maybeWinTitle then
        if win:title() == maybeWinTitle then
          win:raise()
        end
      else
        win:raise()
      end
    end
  end
end

local function focusMainWindowByAppName(appName, maybeWinTitle)
  local app = hs.application.find(appName)
  if app then
    local win = app:mainWindow()
    if win then
      if maybeWinTitle then
        if win:title() == maybeWinTitle then
          win:focus()
        end
      else
        win:focus()
      end
    end
  end
end

local function applicationWatcher(appName, eventType, app)
  if eventType == hs.application.watcher.launched then
    if appName == "deno" then
      local win = app and app:mainWindow()
      if win and win:title() == "Peek preview" then
        local screen = win:screen()
        hs.layout.apply({
          { "deno", "Peek preview", screen, hs.layout.right30, nil, nil },
          { "Ghostty", nil, screen, hs.layout.left70, nil, nil },
        })
        focusMainWindowByAppName("Ghostty")
      end
    end
  end
end

local function windowFocusedWatcher(win, appName)
  if appName == "Ghostty" then
    raiseMainWindowByAppName("deno", "Peek preview")
  elseif appName == "deno" and win:title() == "Peek preview" then
    raiseMainWindowByAppName("Ghostty")
  end
end

hs.hotkey.bind({ "cmd", "alt" }, "Right", expectFocusedWindow(applyRightLayoutStep))
hs.hotkey.bind({ "cmd", "alt" }, "Left", expectFocusedWindow(applyLeftLayoutStep))
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Right", expectFocusedWindow(moveWindowToRightScreen))
hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "Left", expectFocusedWindow(moveWindowToLeftScreen))
hs.hotkey.bind({ "cmd", "alt" }, "f", expectFocusedWindow(maximizeWindowSize))

AppWatcher = hs.application.watcher.new(applicationWatcher)
AppWatcher:start()

WindowFocusedWatcher = hs.window.filter.new(false):setDefaultFilter()
WindowFocusedWatcher:subscribe(hs.window.filter.windowFocused, windowFocusedWatcher)
