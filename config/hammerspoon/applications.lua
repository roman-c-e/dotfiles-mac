
local MEH = {"lShift", "lCtrl", "lOpt"}
local HYPER = {"lShift", "lCtrl", "lOpt", "lCmd"}


function setupSpaces()
    return function()
        local screen_count = 0
        local screens = hs.screen.allScreens()
            for _, _ in pairs(screens) do
                screen_count = screen_count + 1
            end
       if screen_count == 1 then
           setupScreen(screens[1], 10)
           local app_spaces = {
               {app = "Firefox Nightly", space = 2, maximize = false},
               {app = "IntelliJ Idea", space = 3, maximize = true},
               {app = "kitty", space = 4, maximize = false},
               {app = "Mail", space = 5, maximize = false},
               {app = "Calendar", space = 5, maximize = false},
               {app = "GoodNotes", space = 6, maximize = false},
               {app = "Slack", space = 7, maximize = false},
               {app = "Discord", space = 7, maximize = false},
               {app = "Spotify", space = 8, maximize = false},
               {app = "Todoist", space = 9, maximize = false},
               {app = "Marta", space = 10, maximize = false},

           }
              for _, app_space in pairs(app_spaces) do
                moveWindowToSpace(app_space.app, screens[1], app_space.space, app_space.maximize)
              end

           return
       end

    end
end


function setupScreen(screen, spaces)
    local spaces_now = getSpaces(screen)
    for i = spaces_now, spaces, 1 do
        hs.spaces.addSpaceToScreen(screen)
    end
end

function getSpaceID(screen, space)
    local spaces = hs.spaces.spacesForScreen(screen)
    return spaces[space]
end

function getSpaces(screen)
    local spaces = hs.spaces.spacesForScreen(screen)
    local space_count = 0
    for _, _ in pairs(spaces) do
        space_count = space_count + 1
    end
    return space_count
end


function moveWindowToSpace(app, screen, space, maximize)
  local win = hs.application.find(app)
  if win == nil then
    return
  end
  local mainWindow = win:mainWindow()
  if mainWindow == nil then
    return
  end
--  space_id = getSpaceID(screen, space)
--  hs.spaces.moveWindowToSpace(mainWindow, space_id)
    if maximize then
      mainWindow:maximize(0)
    end
end

function moveWindowToScreen(app, screen, maximize)
  local win = hs.application.find(app)
  if win == nil then
    return
  end
  -- print("Found window for " .. app)
  local mainWindow = win:mainWindow()
  if mainWindow == nil then
    return
  end
  -- print("Moving " .. app .. " to " .. screen:name())
  mainWindow:moveToScreen(screen, true, true, 0)
  if maximize then
    mainWindow:maximize(0)
  end
end

--spoon.LeftRightHotkey:bind(HYPER, "A", setupSpaces())



-- APPS
spoon.LeftRightHotkey:bind(MEH, "2", function() hs.application.launchOrFocus("Firefox Nightly") end)
spoon.LeftRightHotkey:bind(MEH, "3", function()hs.application.launchOrFocus("IntelliJ Idea") end)
spoon.LeftRightHotkey:bind(MEH, "4", function() hs.application.launchOrFocus("kitty") end)
spoon.LeftRightHotkey:bind(MEH, "5", function()
    hs.application.launchOrFocus("Mail")
    hs.application.open("Calendar")
end)
spoon.LeftRightHotkey:bind(MEH, "6", function() hs.application.launchOrFocus("GoodNotes") end)
spoon.LeftRightHotkey:bind(MEH, "7", function()
    hs.application.launchOrFocus("Slack")
    hs.application.open("Discord")
end)
spoon.LeftRightHotkey:bind(MEH, "8", function() hs.application.launchOrFocus("Spotify") end)
spoon.LeftRightHotkey:bind(MEH, "9", function() hs.application.launchOrFocus("Todoist") end)
spoon.LeftRightHotkey:bind(MEH, "0", function() hs.application.launchOrFocus("Marta") end)
-- Editor, Clipboard History