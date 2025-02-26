-- https://github.com/mogenson/Swipe.spoon
Swipe = hs.loadSpoon("Swipe")

local config = {
  fingers = 3,
  -- 0.1 = swipe distance > 10% of trackpad
  threshold = 0.08,
  showAlert = false,
  alertDuration = 0.4
}

local AEROSPACE = "/usr/local/bin/aerospace"
function aerospaceExec(cmd)
  os.execute("nohup " .. AEROSPACE .. " " .. cmd .. " &")

  if config.showAlert then
    hs.alert.show("AeroSpace: " .. cmd, config.alertDuration)
  end
end

local current_id, threshold
-- use 4-fingers swipe to switch workspace
Swipe:start(config.fingers, function(direction, distance, id)
  if id == current_id then
    if distance > threshold then
      -- only trigger once per swipe
      threshold = math.huge
      if direction == "left" then
          aerospaceExec("workspace --wrap-around next")
      elseif direction == "right" then
         aerospaceExec("workspace --wrap-around prev")
      end
    end
  else
    current_id = id
    threshold = config.threshold
  end
end)