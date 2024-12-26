function yabai(args, completion)
	local yabai_output = ""
	local yabai_error = ""
	-- Runs in background very fast
	local yabai_task = hs.task.new("/usr/local/bin/yabai",nil, function(task, stdout, stderr)
		--print("stdout:"..stdout, "stderr:"..stderr)
		if stdout ~= nil then yabai_output = yabai_output..stdout end
		if stderr ~= nil then yabai_error = yabai_error..stderr end
		return true
	end, args)
	if type(completion) == "function" then
		yabai_task:setCallback(function() completion(yabai_output, yabai_error) end)
	end
	yabai_task:start()
end

local MEH = {"lShift", "lCtrl", "lOpt"}
local HYPER = {"lShift", "lCtrl", "lOpt", "lCmd"}

local MOVING = {"lShift", "lOpt"}
local FOCUSING = {"alt"}

-- FOCUSING
-- WINDOW
spoon.LeftRightHotkey:bind(HYPER, "H", function() yabai({"-m", "window", "--focus", "west"}) end)
spoon.LeftRightHotkey:bind(HYPER, "J", function() yabai({"-m", "window", "--focus", "south"}) end)
spoon.LeftRightHotkey:bind(HYPER, "K", function() yabai({"-m", "window", "--focus", "north"}) end)
spoon.LeftRightHotkey:bind(HYPER, "L", function() yabai({"-m", "window", "--focus", "east"}) end)
-- DISPLAY
spoon.LeftRightHotkey:bind(HYPER, "1", function() yabai({"-m", "display", "--focus", "1"}) end)
spoon.LeftRightHotkey:bind(HYPER, "2", function() yabai({"-m", "display", "--focus", "2"}) end)
spoon.LeftRightHotkey:bind(HYPER, "3", function() yabai({"-m", "display", "--focus", "3"}) end)

-- MOVING
-- WINDOW
spoon.LeftRightHotkey:bind(MOVING, "H", function() yabai({"-m", "window", "--swap", "west"}) end)
spoon.LeftRightHotkey:bind(MOVING, "J", function() yabai({"-m", "window", "--swap", "south"}) end)
spoon.LeftRightHotkey:bind(MOVING, "K", function() yabai({"-m", "window", "--swap", "north"}) end)
spoon.LeftRightHotkey:bind(MOVING, "L", function() yabai({"-m", "window", "--swap", "east"}) end)
-- DISPLAY
spoon.LeftRightHotkey:bind(MOVING, "up", function()
    yabai({"-m", "window", "--display", "next"})
    yabai({"-m", "display", "--focus", "next"})
end)
spoon.LeftRightHotkey:bind(MOVING, "down", function()
     yabai({"-m", "window", "--display", "prev"})
     yabai({"-m", "display", "--focus", "prev"})
 end)
-- SPACE
spoon.LeftRightHotkey:bind(MOVING, "left", function() yabai({"-m", "window", "--space", "prev"}) end)
spoon.LeftRightHotkey:bind(MOVING, "right", function() yabai({"-m", "window", "--space", "next"}) end)

spoon.LeftRightHotkey:bind(HYPER, "F", function() yabai({"-m", "window", "--toggle", "zoom-fullscreen"}) end)
spoon.LeftRightHotkey:bind(HYPER, "T", function()
    yabai({"-m", "window", "--toggle", "float"})
    yabai({"-m", "window", "--grid", "4:4:1:1:2:2"})
end)
